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
                EstadoVacio(icono: "person.crop.circle.badge.questionmark", titulo: "Inicia sesión para ver tus compras.")
            }
        }
        .navigationTitle("Mis Compras")
        .menuCuenta()
        .safeAreaInset(edge: .top) {
            Picker("Filtro", selection: $filtro) {
                ForEach(FiltroCompra.allCases, id: \.self) { Text($0.rawValue) }
            }
            .pickerStyle(.segmented)
            .padding(Espaciado.l)
            .background(.ultraThinMaterial)
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
            if comprasFiltradas.isEmpty {
                EstadoVacio(icono: "cart", titulo: "Sin compras", subtitulo: "Aún no hay compras registradas para este filtro.")
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }

            ForEach(Array(comprasFiltradas.enumerated()), id: \.element.id) { indice, compra in
                TarjetaGlass {
                    HStack(alignment: .top, spacing: Espaciado.m) {
                        Image(systemName: "cart.fill")
                            .font(.title3)
                            .foregroundStyle(Color.acentoPrimario)
                            .frame(width: 32)

                        VStack(alignment: .leading, spacing: Espaciado.xs) {
                            HStack {
                                Text(compra.producto?.nombre ?? "—")
                                    .font(Tipografia.tituloTarjeta)
                                InsigniaEstado(texto: compra.estado, color: colorEstado(compra.estado))
                            }
                            Text("Proveedor: \(compra.proveedor?.nombre ?? "—")")
                                .font(Tipografia.caption)
                                .foregroundStyle(Color.textoSecundario)
                            Text("Cantidad: \(compra.cantidad) · Total: " + String(format: "S/. %.2f", compra.total))
                                .font(Tipografia.caption)
                            if compra.estado == "Rechazada", let motivo = compra.motivoRechazo {
                                Text("Motivo: \(motivo)")
                                    .font(Tipografia.caption)
                                    .foregroundStyle(Color.peligro)
                            }
                        }
                        Spacer()
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
    }

    private func colorEstado(_ estado: String) -> Color {
        switch estado {
        case "Aprobada": return .exito
        case "Rechazada": return .peligro
        default: return .advertencia
        }
    }
}
