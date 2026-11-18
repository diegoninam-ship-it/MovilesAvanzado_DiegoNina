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
                TarjetaGlass {
                    HStack {
                        VStack(alignment: .leading, spacing: Espaciado.xs) {
                            Text("Total por pagar")
                                .font(Tipografia.caption)
                                .foregroundStyle(Color.textoSecundario)
                            CifraAnimada(valor: totalPorPagar, fuente: .system(size: 26, weight: .bold, design: .rounded))
                        }
                        Spacer()
                        Image(systemName: "banknote.fill")
                            .font(.title)
                            .foregroundStyle(Color.advertencia)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }

            if comprasFiltradas.isEmpty {
                EstadoVacio(icono: "checkmark.circle", titulo: "Nada por aquí", subtitulo: "No hay compras en este filtro.")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(Array(comprasFiltradas.enumerated()), id: \.element.id) { indice, compra in
                TarjetaGlass {
                    HStack(alignment: .top, spacing: Espaciado.m) {
                        Image(systemName: "building.columns.fill")
                            .font(.title3)
                            .foregroundStyle(Color.acentoPrimario)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: Espaciado.xs) {
                            HStack {
                                Text(compra.proveedor?.nombre ?? "—")
                                    .font(Tipografia.tituloTarjeta)
                                if esVencida(compra) {
                                    InsigniaEstado(texto: "Vencida", color: .peligro)
                                }
                            }
                            Text("Producto: \(compra.producto?.nombre ?? "—")")
                                .font(Tipografia.caption)
                                .foregroundStyle(Color.textoSecundario)
                            Text("Total: " + String(format: "S/. %.2f", compra.total) + " · Vence: \(compra.vence.formatted(date: .abbreviated, time: .omitted))")
                                .font(Tipografia.caption)
                        }
                        Spacer()
                    }
                }
                .apareceEscalonado(indice: indice)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .swipeActions {
                    if !compra.pagada {
                        Button {
                            compra.pagada = true
                        } label: {
                            Label("Pagar", systemImage: "checkmark.circle.fill")
                        }
                        .tint(.exito)
                    }
                }
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.fondoApp)
        .navigationTitle("Por Pagar")
        .menuCuenta()
        .safeAreaInset(edge: .top) {
            Picker("Filtro", selection: $filtro) {
                ForEach(FiltroPorPagar.allCases, id: \.self) { Text($0.rawValue) }
            }
            .pickerStyle(.segmented)
            .padding(Espaciado.l)
            .background(.ultraThinMaterial)
        }
    }
}
