import SwiftUI
import SwiftData

struct AprobarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: #Predicate<Compra> { $0.estado == "Pendiente" }, sort: \Compra.fecha) private var pendientes: [Compra]

    @State private var compraParaRechazar: Compra?
    @State private var motivoRechazo = ""

    var body: some View {
        List {
            ForEach(pendientes) { compra in
                VStack(alignment: .leading, spacing: 6) {
                    Text(compra.producto?.nombre ?? "—")
                        .font(.headline)
                    Text("Solicitado por: \(compra.comprador?.nombre ?? "—")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Cantidad: \(compra.cantidad) · Total: " + String(format: "S/. %.2f", compra.total))
                        .font(.caption)

                    if let producto = compra.producto {
                        let stockActual = producto.stock
                        let costoActual = producto.costoPromedio
                        let nuevoCosto = (Double(stockActual) * costoActual + Double(compra.cantidad) * compra.costoUnitario) / Double(stockActual + compra.cantidad)
                        Divider()
                        Text("Vista previa")
                            .font(.caption.bold())
                        Text("Stock: \(stockActual) → \(stockActual + compra.cantidad)")
                            .font(.caption2)
                        Text("Costo promedio: " + String(format: "S/. %.2f", costoActual) + " → " + String(format: "S/. %.2f", nuevoCosto))
                            .font(.caption2)
                    }

                    HStack {
                        Button("Rechazar", role: .destructive) {
                            compraParaRechazar = compra
                            motivoRechazo = ""
                        }
                        Spacer()
                        Button("Aprobar") {
                            aprobar(compra)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Aprobar")
        .menuCuenta()
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

    private func aprobar(_ compra: Compra) {
        guard let producto = compra.producto else { return }
        let stockActual = producto.stock
        let costoActual = producto.costoPromedio
        let nuevoCosto = (Double(stockActual) * costoActual + Double(compra.cantidad) * compra.costoUnitario) / Double(stockActual + compra.cantidad)
        producto.stock += compra.cantidad
        producto.costoPromedio = nuevoCosto
        compra.estado = "Aprobada"
        compra.pagada = compra.alCredito ? false : true
    }

    private func rechazar(_ compra: Compra) {
        guard !motivoRechazo.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        compra.estado = "Rechazada"
        compra.motivoRechazo = motivoRechazo
        compraParaRechazar = nil
    }
}
