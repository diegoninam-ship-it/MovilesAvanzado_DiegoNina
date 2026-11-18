import SwiftUI
import SwiftData

private enum FiltroPorPagar: String, CaseIterable {
    case pendientes = "Pendientes"
    case vencidas = "Vencidas"
    case pagadas = "Pagadas"
}

struct PorPagarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Compra> { $0.alCredito == true }, sort: \Compra.vence) private var comprasCredito: [Compra]

    @State private var filtro: FiltroPorPagar = .pendientes

    private var ahora: Date { Date() }

    private func esVencida(_ compra: Compra) -> Bool {
        !compra.pagada && compra.vence < ahora
    }

    private var comprasFiltradas: [Compra] {
        switch filtro {
        case .pendientes:
            return comprasCredito.filter { !$0.pagada && !esVencida($0) }
        case .vencidas:
            return comprasCredito.filter { esVencida($0) }
        case .pagadas:
            return comprasCredito.filter { $0.pagada }
        }
    }

    private var totalPorPagar: Double {
        comprasCredito.filter { !$0.pagada }.reduce(0) { $0 + $1.total }
    }

    var body: some View {
        List {
            Section {
                HStack {
                    Text("Total por pagar")
                    Spacer()
                    Text(String(format: "S/. %.2f", totalPorPagar)).bold()
                }
            }

            ForEach(comprasFiltradas) { compra in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(compra.proveedor?.nombre ?? "—")
                            .font(.headline)
                        Spacer()
                        if esVencida(compra) {
                            Text("VENCIDA")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.red.opacity(0.15))
                                .foregroundStyle(.red)
                                .clipShape(Capsule())
                        }
                    }
                    Text("Producto: \(compra.producto?.nombre ?? "—")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Total: " + String(format: "S/. %.2f", compra.total) + " · Vence: \(compra.vence.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                }
                .swipeActions {
                    if !compra.pagada {
                        Button("Pagar") {
                            compra.pagada = true
                        }
                        .tint(.green)
                    }
                }
            }
        }
        .navigationTitle("Por Pagar")
        .menuCuenta()
        .safeAreaInset(edge: .top) {
            Picker("Filtro", selection: $filtro) {
                ForEach(FiltroPorPagar.allCases, id: \.self) { Text($0.rawValue) }
            }
            .pickerStyle(.segmented)
            .padding()
        }
    }
}
