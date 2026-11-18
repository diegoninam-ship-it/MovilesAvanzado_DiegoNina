import SwiftUI

struct TabViewPrincipal: View {
    @Environment(SesionUsuario.self) private var sesion

    var body: some View {
        if sesion.usuarioActual?.rol == "Supervisor" {
            TabView {
                NavigationStack { ResumenView() }
                    .tabItem { Label("Resumen", systemImage: "chart.bar.fill") }
                NavigationStack { AprobarView() }
                    .tabItem { Label("Aprobar", systemImage: "checkmark.seal") }
                NavigationStack { PorPagarView() }
                    .tabItem { Label("Por pagar", systemImage: "banknote") }
                NavigationStack { ProductosView() }
                    .tabItem { Label("Productos", systemImage: "shippingbox") }
                NavigationStack { ProveedoresView() }
                    .tabItem { Label("Proveedores", systemImage: "building.2") }
            }
        } else {
            TabView {
                NavigationStack { ProductosView() }
                    .tabItem { Label("Productos", systemImage: "shippingbox") }
                NavigationStack { ProveedoresView() }
                    .tabItem { Label("Proveedores", systemImage: "building.2") }
                NavigationStack { NuevaCompraView() }
                    .tabItem { Label("Compra", systemImage: "cart.badge.plus") }
                NavigationStack { MisComprasView() }
                    .tabItem { Label("Mis compras", systemImage: "list.bullet.rectangle") }
            }
        }
    }
}

// MARK: - Menu de cuenta reutilizable (avatar + cerrar sesion)
struct MenuCuentaToolbar: ViewModifier {
    @Environment(SesionUsuario.self) private var sesion

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Cerrar sesión", role: .destructive) {
                            sesion.usuarioActual = nil
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
    }
}

extension View {
    func menuCuenta() -> some View {
        modifier(MenuCuentaToolbar())
    }
}
