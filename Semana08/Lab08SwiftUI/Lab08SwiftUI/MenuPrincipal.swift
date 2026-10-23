// Desarrollado por: Diego Nina Malqui

import SwiftUI

struct MenuPrincipal: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    ContentView()
                } label: {
                    Label("Actividad 01 – Stacks", systemImage: "square.stack.3d.up.fill")
                }

                NavigationLink {
                    Ventana02()
                } label: {
                    Label("Ventana 02 – Contenedores", systemImage: "person.crop.circle.fill")
                }

                NavigationLink {
                    Ventana03()
                } label: {
                    Label("Ventana 03 – Peso ideal", systemImage: "scalemass.fill")
                }
            }
            .navigationTitle("Lab08 SwiftUI")
        }
    }
}

#Preview {
    MenuPrincipal()
}
