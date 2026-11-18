import SwiftUI
import SwiftData

struct ProductosView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SesionUsuario.self) private var sesion
    @Query(sort: \Producto.nombre) private var productos: [Producto]

    @State private var busqueda = ""
    @State private var mostrarNuevo = false
    @State private var errorBorrado: String?

    private var esSupervisor: Bool { sesion.usuarioActual?.rol == "Supervisor" }

    private var productosFiltrados: [Producto] {
        guard !busqueda.isEmpty else { return productos }
        return productos.filter { $0.nombre.localizedCaseInsensitiveContains(busqueda) }
    }

    var body: some View {
        List {
            ForEach(productosFiltrados) { producto in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(producto.nombre)
                            .font(.headline)
                        Spacer()
                        Text(String(format: "S/. %.2f", producto.costoPromedio))
                    }
                    HStack {
                        Text("Stock: \(producto.stock)")
                            .foregroundStyle(colorStock(producto.stock))
                        Spacer()
                        Text("Valor inventario: " + String(format: "S/. %.2f", Double(producto.stock) * producto.costoPromedio))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .onDelete(perform: esSupervisor ? borrar : nil)
        }
        .searchable(text: $busqueda, prompt: "Buscar producto")
        .navigationTitle("Productos")
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
            NuevoProductoSheet()
        }
        .alert("No se pudo borrar", isPresented: Binding(get: { errorBorrado != nil }, set: { if !$0 { errorBorrado = nil } })) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorBorrado ?? "")
        }
    }

    private func colorStock(_ stock: Int) -> Color {
        if stock > 10 { return .green }
        if stock >= 6 { return .orange }
        return .red
    }

    private func borrar(at offsets: IndexSet) {
        for indice in offsets {
            let producto = productosFiltrados[indice]
            modelContext.delete(producto)
            do {
                try modelContext.save()
            } catch {
                modelContext.rollback()
                errorBorrado = "El producto \"\(producto.nombre)\" tiene compras asociadas y no se puede eliminar."
            }
        }
    }
}

private struct NuevoProductoSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var categoria = ""
    @State private var stock = 0
    @State private var costoPromedio = 0.0

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $nombre)
                TextField("Categoría", text: $categoria)
                Stepper("Stock: \(stock)", value: $stock, in: 0...100000)
                TextField("Costo promedio", value: $costoPromedio, format: .number)
                    .keyboardType(.decimalPad)
            }
            .navigationTitle("Nuevo producto")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        guard !nombre.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        let producto = Producto(nombre: nombre, categoria: categoria, stock: stock, costoPromedio: costoPromedio)
                        modelContext.insert(producto)
                        dismiss()
                    }
                }
            }
        }
    }
}
