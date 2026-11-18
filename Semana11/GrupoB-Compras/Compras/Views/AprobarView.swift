import SwiftUI
import SwiftData

struct AprobarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Compra> { $0.estado == "Pendiente" }, sort: \Compra.fecha) private var pendientes: [Compra]

    @State private var compraParaRechazar: Compra?
    @State private var motivoRechazo = ""

    var body: some View {
        List {
            if pendientes.isEmpty {
                EstadoVacio(icono: "checkmark.seal", titulo: "Sin pendientes", subtitulo: "No hay compras esperando aprobación.")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(Array(pendientes.enumerated()), id: \.element.id) { indice, compra in
                TarjetaGlass {
                    VStack(alignment: .leading, spacing: Espaciado.m) {
                        HStack {
                            VStack(alignment: .leading, spacing: Espaciado.xs) {
                                Text(compra.producto?.nombre ?? "—")
                                    .font(Tipografia.tituloTarjeta)
                                Text("Solicitado por: \(compra.comprador?.nombre ?? "—")")
                                    .font(Tipografia.caption)
                                    .foregroundStyle(Color.textoSecundario)
                            }
                            Spacer()
                            InsigniaEstado(texto: "Pendiente", color: .advertencia)
                        }

                        Text("Cantidad: \(compra.cantidad) · Total: " + String(format: "S/. %.2f", compra.total))
                            .font(Tipografia.caption)

                        if let producto = compra.producto {
                            ComparacionStockCosto(compra: compra, producto: producto)
                        }

                        HStack(spacing: Espaciado.m) {
                            Button("Rechazar") {
                                compraParaRechazar = compra
                                motivoRechazo = ""
                            }
                            .buttonStyle(.secundario)
                            .tint(.peligro)

                            Button("Aprobar") {
                                aprobar(compra)
                            }
                            .buttonStyle(.primario)
                        }
                    }
                }
                .apareceEscalonado(indice: indice)
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(Color.fondoApp)
        .navigationTitle("Aprobar")
        .menuCuenta()
        .sensoryFeedback(.success, trigger: ultimaAprobacion)
        .sensoryFeedback(.warning, trigger: ultimoRechazo)
        .sheet(item: $compraParaRechazar) { compra in
            NavigationStack {
                Form {
                    TextField("Motivo del rechazo", text: $motivoRechazo)
                }
                .navigationTitle("Rechazar compra")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") { compraParaRechazar = nil }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Confirmar") {
                            rechazar(compra)
                        }
                        .disabled(motivoRechazo.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
        }
    }

    @State private var ultimaAprobacion = 0
    @State private var ultimoRechazo = 0

    private func aprobar(_ compra: Compra) {
        guard let producto = compra.producto else { return }
        let stockActual = producto.stock
        let costoActual = producto.costoPromedio
        let nuevoCosto = (Double(stockActual) * costoActual + Double(compra.cantidad) * compra.costoUnitario) / Double(stockActual + compra.cantidad)
        producto.stock += compra.cantidad
        producto.costoPromedio = nuevoCosto
        compra.estado = "Aprobada"
        compra.pagada = compra.alCredito ? false : true
        ultimaAprobacion += 1
    }

    private func rechazar(_ compra: Compra) {
        guard !motivoRechazo.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        compra.estado = "Rechazada"
        compra.motivoRechazo = motivoRechazo
        compraParaRechazar = nil
        ultimoRechazo += 1
    }
}

/// Comparación visual "antes → después" de stock y costo promedio ponderado.
private struct ComparacionStockCosto: View {
    let compra: Compra
    let producto: Producto

    private var nuevoCosto: Double {
        let stockActual = producto.stock
        let costoActual = producto.costoPromedio
        return (Double(stockActual) * costoActual + Double(compra.cantidad) * compra.costoUnitario) / Double(stockActual + compra.cantidad)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Espaciado.s) {
            Text("Vista previa")
                .font(.caption2.bold())
                .foregroundStyle(Color.textoSecundario)

            HStack {
                columna(titulo: "Stock", valor: "\(producto.stock)")
                Image(systemName: "arrow.right")
                    .foregroundStyle(Color.textoSecundario)
                    .accessibilityHidden(true)
                columna(titulo: "Stock nuevo", valor: "\(producto.stock + compra.cantidad)", destacado: true)
            }

            HStack {
                columna(titulo: "Costo prom.", valor: String(format: "S/. %.2f", producto.costoPromedio))
                Image(systemName: "arrow.right")
                    .foregroundStyle(Color.textoSecundario)
                    .accessibilityHidden(true)
                columna(titulo: "Costo nuevo", valor: String(format: "S/. %.2f", nuevoCosto), destacado: true)
            }
        }
        .padding(Espaciado.m)
        .background(Color.fondoApp, in: RoundedRectangle(cornerRadius: Radio.cardPequena, style: .continuous))
    }

    @ViewBuilder
    private func columna(titulo: String, valor: String, destacado: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(titulo)
                .font(.caption2)
                .foregroundStyle(Color.textoSecundario)
            Text(valor)
                .font(.caption.bold())
                .foregroundStyle(destacado ? Color.acentoPrimario : Color.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
