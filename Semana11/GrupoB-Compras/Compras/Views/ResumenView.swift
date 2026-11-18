import SwiftUI
import SwiftData
import Charts

struct ResumenView: View {
    @Query private var productos: [Producto]
    @Query private var compras: [Compra]
    @Query(sort: \Proveedor.nombre) private var proveedores: [Proveedor]

    private var valorInventario: Double {
        productos.reduce(0) { $0 + Double($1.stock) * $1.costoPromedio }
    }

    private var comprasAprobadas: [Compra] { compras.filter { $0.estado == "Aprobada" } }
    private var creditoFiscal: Double {
        comprasAprobadas.reduce(0) { $0 + $1.igv }
    }

    private var comprasPendientes: [Compra] { compras.filter { $0.estado == "Pendiente" } }
    private var importePendiente: Double {
        comprasPendientes.reduce(0) { $0 + $1.total }
    }

    private var rankingProveedores: [(proveedor: Proveedor, total: Double)] {
        proveedores
            .map { ($0, $0.compras.reduce(0) { $0 + $1.total }) }
            .filter { $0.1 > 0 }
            .sorted { $0.1 > $1.1 }
    }

    private let columnas = [GridItem(.adaptive(minimum: 160), spacing: Espaciado.m)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Espaciado.l) {
                LazyVGrid(columns: columnas, spacing: Espaciado.m) {
                    TarjetaEstadistica(
                        icono: "shippingbox.fill",
                        titulo: "Valor del inventario",
                        valor: valorInventario,
                        color: .acentoPrimario
                    )
                    TarjetaEstadistica(
                        icono: "percent",
                        titulo: "Crédito fiscal",
                        valor: creditoFiscal,
                        color: .exito
                    )
                    TarjetaEstadistica(
                        icono: "clock.badge.exclamationmark.fill",
                        titulo: "Por aprobar (\(comprasPendientes.count))",
                        valor: importePendiente,
                        color: .advertencia
                    )
                }

                TarjetaGlass {
                    VStack(alignment: .leading, spacing: Espaciado.m) {
                        Text("Total comprado por proveedor")
                            .font(Tipografia.tituloTarjeta)

                        if rankingProveedores.isEmpty {
                            EstadoVacio(icono: "chart.bar", titulo: "Sin compras aún", subtitulo: "El ranking aparecerá cuando haya compras registradas.")
                        } else {
                            Chart(rankingProveedores, id: \.proveedor.id) { item in
                                BarMark(
                                    x: .value("Total", item.total),
                                    y: .value("Proveedor", item.proveedor.nombre)
                                )
                                .foregroundStyle(Color.acentoPrimario.gradient)
                                .cornerRadius(6)
                            }
                            .chartXAxis {
                                AxisMarks { _ in
                                    AxisGridLine()
                                    AxisValueLabel()
                                }
                            }
                            .frame(height: CGFloat(rankingProveedores.count) * 44 + 20)
                        }
                    }
                }
            }
            .padding(Espaciado.l)
        }
        .background(Color.fondoApp)
        .navigationTitle("Resumen")
        .menuCuenta()
    }
}

private struct TarjetaEstadistica: View {
    let icono: String
    let titulo: String
    let valor: Double
    let color: Color

    var body: some View {
        TarjetaGlass {
            VStack(alignment: .leading, spacing: Espaciado.s) {
                HStack {
                    Image(systemName: icono)
                        .foregroundStyle(color)
                    Spacer()
                }
                Text(titulo)
                    .font(Tipografia.caption)
                    .foregroundStyle(Color.textoSecundario)
                CifraAnimada(valor: valor, fuente: .system(size: 22, weight: .bold, design: .rounded))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
