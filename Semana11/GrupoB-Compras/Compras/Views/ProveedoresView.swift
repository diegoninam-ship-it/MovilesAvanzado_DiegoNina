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
            if proveedores.isEmpty {
                EstadoVacio(icono: "building.2", titulo: "Sin proveedores", subtitulo: "Aún no hay proveedores registrados.")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(Array(proveedores.enumerated()), id: \.element.id) { indice, proveedor in
                TarjetaGlass {
                    HStack(alignment: .top, spacing: Espaciado.m) {
                        Image(systemName: "building.2.fill")
                            .font(.title3)
                            .foregroundStyle(Color.acentoPrimario)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: Espaciado.xs) {
                            HStack {
                                Text(proveedor.nombre)
                                    .font(Tipografia.tituloTarjeta)
                                insignia(proveedor)
                            }
                            Text("RUC: \(proveedor.ruc)")
                                .font(Tipografia.caption)
                                .foregroundStyle(Color.textoSecundario)
                            Text("Total comprado: " + String(format: "S/. %.2f", totalComprado(proveedor)))
                                .font(.caption.bold())
                        }

                        Spacer()
                    }
                }
                .apareceEscalonado(indice: indice)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
            .onDelete(perform: esSupervisor ? borrar : nil)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.fondoApp)
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
                    .accessibilityLabel("Agregar proveedor")
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
        InsigniaEstado(texto: tienePorPagar ? "Por pagar" : "Al día", color: tienePorPagar ? .peligro : .exito)
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
