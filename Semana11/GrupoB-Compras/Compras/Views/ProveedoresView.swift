import SwiftUI
import SwiftData

struct ProveedoresView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SesionUsuario.self) private var sesion
    @Query(sort: \Proveedor.nombre) private var proveedores: [Proveedor]

    @State private var mostrarNuevo = false
    @State private var errorBorrado: String?

    private var esSupervisor: Bool { sesion.usuarioActual?.rol == "Supervisor" }

    var body: some View {
        List {
            ForEach(proveedores) { proveedor in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(proveedor.nombre)
                            .font(.headline)
                        Spacer()
                        insignia(proveedor)
                    }
                    Text("RUC: \(proveedor.ruc)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Total comprado: " + String(format: "S/. %.2f", totalComprado(proveedor)))
                        .font(.caption)
                }
            }
            .onDelete(perform: esSupervisor ? borrar : nil)
        }
        .navigationTitle("Proveedores")
        .menuCuenta()
        .toolbar {
            if esSupervisor {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        mostrarNuevo = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $mostrarNuevo) {
            NuevoProveedorSheet()
        }
        .alert("No se pudo borrar", isPresented: Binding(get: { errorBorrado != nil }, set: { if !$0 { errorBorrado = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorBorrado ?? "")
        }
    }

    private func totalComprado(_ proveedor: Proveedor) -> Double {
        proveedor.compras.reduce(0) { $0 + $1.total }
    }

    @ViewBuilder
    private func insignia(_ proveedor: Proveedor) -> some View {
        let tienePorPagar = proveedor.compras.contains { !$0.pagada }
        Text(tienePorPagar ? "Por pagar" : "Al día")
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(tienePorPagar ? Color.red.opacity(0.15) : Color.green.opacity(0.15))
            .foregroundStyle(tienePorPagar ? .red : .green)
            .clipShape(Capsule())
    }

    private func borrar(at offsets: IndexSet) {
        for indice in offsets {
            let proveedor = proveedores[indice]
            modelContext.delete(proveedor)
            do {
                try modelContext.save()
            } catch {
                modelContext.rollback()
                errorBorrado = "El proveedor \"\(proveedor.nombre)\" tiene compras asociadas y no se puede eliminar."
            }
        }
    }
}

private struct NuevoProveedorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var ruc = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $nombre)
                TextField("RUC", text: $ruc)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("Nuevo proveedor")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guard !nombre.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        let proveedor = Proveedor(nombre: nombre, ruc: ruc)
                        modelContext.insert(proveedor)
                        dismiss()
                    }
                }
            }
        }
    }
}
