import SwiftUI
import SwiftData

struct NuevaCompraView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SesionUsuario.self) private var sesion
    @Query(sort: \Proveedor.nombre) private var proveedores: [Proveedor]
    @Query(sort: \Producto.nombre) private var productos: [Producto]

    @State private var proveedorSeleccionado: Proveedor?
    @State private var productoSeleccionado: Producto?
    @State private var cantidad = 1
    @State private var alCredito = false
    @State private var mostrarConfirmacion = false
    @State private var mensajeConfirmacion = ""

    private let umbralAprobacion = 5000.0

    private var costoUnitario: Double { productoSeleccionado?.costoPromedio ?? 0 }
    private var subtotal: Double { Double(cantidad) * costoUnitario }
    private var igv: Double { subtotal * 0.18 }
    private var total: Double { subtotal + igv }
    private var requiereAprobacion: Bool { total >= umbralAprobacion }

    var body: some View {
        Form {
            Section("Proveedor") {
                Picker("Proveedor", selection: $proveedorSeleccionado) {
                    Text("Selecciona").tag(Proveedor?.none)
                    ForEach(proveedores) { proveedor in
                        Text(proveedor.nombre).tag(Optional(proveedor))
                    }
                }
            }

            Section("Producto") {
                Picker("Producto", selection: $productoSeleccionado) {
                    Text("Selecciona").tag(Producto?.none)
                    ForEach(productos) { producto in
                        Text(producto.nombre).tag(Optional(producto))
                    }
                }
                Stepper("Cantidad: \(cantidad)", value: $cantidad, in: 1...100000)
                Toggle("Al crédito (30 días)", isOn: $alCredito)
            }

            Section("Cálculo") {
                HStack { Text("Subtotal"); Spacer(); Text(String(format: "S/. %.2f", subtotal)) }
                HStack { Text("IGV (18%)"); Spacer(); Text(String(format: "S/. %.2f", igv)) }
                HStack { Text("Total"); Spacer(); Text(String(format: "S/. %.2f", total)).bold() }

                if requiereAprobacion {
                    Text("El total supera S/. 5,000.00: la compra se enviará a aprobación del supervisor.")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }

            Button(requiereAprobacion ? "Enviar a aprobación" : "Registrar compra") {
                registrarCompra()
            }
            .disabled(proveedorSeleccionado == nil || productoSeleccionado == nil)
        }
        .navigationTitle("Nueva Compra")
        .menuCuenta()
        .alert("Compra registrada", isPresented: $mostrarConfirmacion) {
            Button("OK", role: .cancel) { limpiar() }
        } message: {
            Text(mensajeConfirmacion)
        }
    }

    private func registrarCompra() {
        guard let proveedor = proveedorSeleccionado, let producto = productoSeleccionado else { return }

        let ahora = Date()
        let vencimiento = Calendar.current.date(byAdding: .day, value: 30, to: ahora) ?? ahora
        let estadoInicial = requiereAprobacion ? "Pendiente" : "Aprobada"
        let pagadaInicial = alCredito ? false : true

        let compra = Compra(
            fecha: ahora,
            cantidad: cantidad,
            costoUnitario: costoUnitario,
            igv: igv,
            total: total,
            alCredito: alCredito,
            vence: vencimiento,
            estado: estadoInicial,
            pagada: pagadaInicial
        )
        compra.comprador = sesion.usuarioActual
        compra.proveedor = proveedor
        compra.producto = producto
        modelContext.insert(compra)

        if !requiereAprobacion {
            let stockActual = producto.stock
            let costoPromedioActual = producto.costoPromedio
            let nuevoCostoPromedio = (Double(stockActual) * costoPromedioActual + Double(cantidad) * costoUnitario) / Double(stockActual + cantidad)
            producto.stock += cantidad
            producto.costoPromedio = nuevoCostoPromedio
        }

        mensajeConfirmacion = requiereAprobacion
            ? "La compra quedó pendiente de aprobación por el supervisor."
            : "La compra fue registrada y aprobada automáticamente."
        mostrarConfirmacion = true
    }

    private func limpiar() {
        proveedorSeleccionado = nil
        productoSeleccionado = nil
        cantidad = 1
        alCredito = false
    }
}
