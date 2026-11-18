import SwiftUI
import SwiftData

private enum FiltroCompra: String, CaseIterable {
    case todas = "Todas"
    case pendientes = "Pendientes"
    case rechazadas = "Rechazadas"
}

struct MisComprasView: View {
    @Environment(SesionUsuario.self) private var sesion
    @State private var filtro: FiltroCompra = .todas

    var body: some View {
        Group {
            if let usuario = sesion.usuarioActual {
                ComprasDelUsuarioView(usuario: usuario, filtro: filtro)
            } else {
                Text("Inicia sesión para ver tus compras.")
            }
        }
        .navigationTitle("Mis Compras")
        .menuCuenta()
        .safeAreaInset(edge: .top) {
            Picker("Filtro", selection: $filtro) {
                ForEach(FiltroCompra.allCases, id: \.self) { Text($0.rawValue) }
            }
            .pickerStyle(.segmented)
            .padding()
        }
    }
}

private struct ComprasDelUsuarioView: View {
    @Query private var compras: [Compra]
    private let filtro: FiltroCompra

    init(usuario: Usuario, filtro: FiltroCompra) {
        self.filtro = filtro
        let idUsuarioDeSesion = usuario.persistentModelID
        _compras = Query(
            filter: #Predicate<Compra> { $0.comprador?.persistentModelID == idUsuarioDeSesion },
            sort: \Compra.fecha,
            order: .reverse
        )
    }

    private var comprasFiltradas: [Compra] {
        switch filtro {
        case .todas: return compras
        case .pendientes: return compras.filter { $0.estado == "Pendiente" }
        case .rechazadas: return compras.filter { $0.estado == "Rechazada" }
        }
    }

    var body: some View {
        List {
            ForEach(comprasFiltradas) { compra in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(compra.producto?.nombre ?? "—")
                            .font(.headline)
                        Spacer()
                        Text(compra.estado)
                            .font(.caption.bold())
                    }
                    Text("Proveedor: \(compra.proveedor?.nombre ?? "—")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("Cantidad: \(compra.cantidad) · Total: " + String(format: "S/. %.2f", compra.total))
                        .font(.caption)
                    if compra.estado == "Rechazada", let motivo = compra.motivoRechazo {
                        Text("Motivo: \(motivo)")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
        }
    }
}
