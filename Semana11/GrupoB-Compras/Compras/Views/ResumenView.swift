import SwiftUI
import SwiftData

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
            .sorted { $0.1 > $1.1 }
    }

    private var maximoRanking: Double {
        rankingProveedores.map(\.total).max() ?? 0
    }

    var body: some View {
        List {
            Section("Inventario") {
                HStack { Text("Valor del inventario"); Spacer(); Text(String(format: "S/. %.2f", valorInventario)).bold() }
            }

            Section("Crédito fiscal") {
                HStack { Text("Crédito fiscal acumulado"); Spacer(); Text(String(format: "S/. %.2f", creditoFiscal)).bold() }
                Text("Suma del IGV de las compras aprobadas.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Section("Compras por aprobar") {
                HStack { Text("Cantidad"); Spacer(); Text("\(comprasPendientes.count)") }
                HStack { Text("Importe"); Spacer(); Text(String(format: "S/. %.2f", importePendiente)) }
            }

            Section("Total comprado por proveedor") {
                ForEach(rankingProveedores, id: \.proveedor.id) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.proveedor.nombre)
                            Spacer()
                            Text(String(format: "S/. %.2f", item.total))
                                .font(.caption)
                        }
                        GeometryReader { geometria in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.accentColor)
                                .frame(width: maximoRanking > 0 ? geometria.size.width * (item.total / maximoRanking) : 0, height: 8)
                        }
                        .frame(height: 8)
                    }
                }
            }
        }
        .navigationTitle("Resumen")
        .menuCuenta()
    }
}
