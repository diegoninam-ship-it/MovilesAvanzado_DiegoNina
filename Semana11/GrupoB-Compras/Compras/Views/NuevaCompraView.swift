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
    @State private var compraRegistrada = 0

    private let umbralAprobacion = 5000.0

    private var costoUnitario: Double { productoSeleccionado?.costoPromedio ?? 0 }
    private var subtotal: Double { Double(cantidad) * costoUnitario }
    private var igv: Double { subtotal * 0.18 }
    private var total: Double { subtotal + igv }
    private var requiereAprobacion: Bool { total >= umbralAprobacion }

    var body: some View {
        ScrollView {
            VStack(spacing: Espaciado.l) {
                PasoCompra(numero: 1, titulo: "Proveedor") {
                    Picker("Proveedor", selection: $proveedorSeleccionado) {
                        Text("Selecciona").tag(Proveedor?.none)
                        ForEach(proveedores) { proveedor in
                            Text(proveedor.nombre).tag(Optional(proveedor))
                        }
                    }
                    .pickerStyle(.menu)
                }

                PasoCompra(numero: 2, titulo: "Producto, cantidad y condición") {
                    VStack(alignment: .leading, spacing: Espaciado.m) {
                        Picker("Producto", selection: $productoSeleccionado) {
                            Text("Selecciona").tag(Producto?.none)
                            ForEach(productos) { producto in
                                Text(producto.nombre).tag(Optional(producto))
                            }
                        }
                        .pickerStyle(.menu)

                        Stepper("Cantidad: \(cantidad)", value: $cantidad, in: 1...100000)
                        Toggle("Al crédito (30 días)", isOn: $alCredito)
                    }
                }

                PasoCompra(numero: 3, titulo: "Resumen") {
                    VStack(spacing: Espaciado.m) {
                        filaResumen(titulo: "Subtotal", valor: subtotal)
                        filaResumen(titulo: "IGV (18%)", valor: igv)
                        Divider()
                        HStack {
                            Text("Total")
                                .font(Tipografia.tituloTarjeta)
                            Spacer()
                            CifraAnimada(valor: total)
                        }

                        if requiereAprobacion {
                            BannerAdvertencia(texto: "El total supera S/. 5,000.00: la compra se enviará a aprobación del supervisor.")
                        }
                    }
                }

                Button(requiereAprobacion ? "Enviar a aprobación" : "Registrar compra") {
                    registrarCompra()
                }
                .buttonStyle(.primario)
                .disabled(proveedorSeleccionado == nil || productoSeleccionado == nil)
                .sensoryFeedback(.success, trigger: compraRegistrada)
            }
            .padding(Espaciado.l)
        }
        .background(Color.fondoApp)
        .navigationTitle("Nueva Compra")
        .menuCuenta()
        .alert("Compra registrada", isPresented: $mostrarConfirmacion) {
            Button("OK", role: .cancel) { limpiar() }
        } message: {
            Text(mensajeConfirmacion)
        }
    }

    @ViewBuilder
    private func filaResumen(titulo: String, valor: Double) -> some View {
        HStack {
            Text(titulo)
                .foregroundStyle(Color.textoSecundario)
            Spacer()
            CifraAnimada(valor: valor, fuente: .system(.body, design: .rounded, weight: .semibold))
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
        compraRegistrada += 1
        mostrarConfirmacion = true
    }

    private func limpiar() {
        proveedorSeleccionado = nil
        productoSeleccionado = nil
        cantidad = 1
        alCredito = false
    }
}

/// Un paso numerado del flujo de "Nueva Compra", dentro de su propia TarjetaGlass.
private struct PasoCompra<Contenido: View>: View {
    let numero: Int
    let titulo: String
    @ViewBuilder var contenido: Contenido

    var body: some View {
        TarjetaGlass {
            VStack(alignment: .leading, spacing: Espaciado.m) {
                HStack(spacing: Espaciado.s) {
                    Text("\(numero)")
                        .font(.caption.bold())
                        .frame(width: 22, height: 22)
                        .background(Color.acentoPrimario, in: Circle())
                        .foregroundStyle(.white)
                    Text(titulo)
                        .font(Tipografia.tituloTarjeta)
                }
                contenido
            }
        }
    }
}

private struct BannerAdvertencia: View {
    let texto: String

    var body: some View {
        HStack(spacing: Espaciado.s) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Color.advertencia)
            Text(texto)
                .font(Tipografia.caption)
        }
        .padding(Espaciado.m)
        .background(Color.advertencia.opacity(0.15), in: RoundedRectangle(cornerRadius: Radio.cardPequena, style: .continuous))
    }
}
