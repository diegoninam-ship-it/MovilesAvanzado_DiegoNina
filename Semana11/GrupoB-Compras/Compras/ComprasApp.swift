import SwiftUI
import SwiftData

@main
struct ComprasApp: App {
    let modelContainer: ModelContainer
    @State private var sesion = SesionUsuario()

    init() {
        do {
            modelContainer = try ModelContainer(for: Usuario.self, Proveedor.self, Producto.self, Compra.self)
        } catch {
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RaizView()
                .environment(sesion)
        }
        .modelContainer(modelContainer)
    }
}

struct RaizView: View {
    @Environment(SesionUsuario.self) private var sesion

    var body: some View {
        if sesion.usuarioActual != nil {
            TabViewPrincipal()
        } else {
            LoginView()
        }
    }
}
