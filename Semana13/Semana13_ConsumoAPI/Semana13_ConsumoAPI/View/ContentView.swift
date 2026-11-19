// Desarrollado por: Diego Nina Malqui

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = UserViewModel()
    @State private var estaCargando = true

    var body: some View {
        NavigationStack {
            ZStack {
                Colores.fondo.ignoresSafeArea()

                if estaCargando {
                    EstadoCargando()
                } else if viewModel.filteredUsers.isEmpty {
                    if viewModel.searchText.isEmpty {
                        EstadoVacio(
                            icono: "person.slash",
                            titulo: "Sin usuarios",
                            mensaje: "Todavia no hay usuarios para mostrar."
                        )
                    } else {
                        EstadoVacio(
                            icono: "magnifyingglass",
                            titulo: "Sin resultados",
                            mensaje: "No encontramos usuarios que coincidan con \"\(viewModel.searchText)\"."
                        )
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: Espaciado.sm) {
                            ForEach(Array(viewModel.filteredUsers.enumerated()), id: \.element.id) { indice, usuario in
                                TarjetaUsuario(nombre: usuario.name, correo: usuario.email)
                                    .padding(.horizontal, Espaciado.md)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                    .animation(
                                        .spring(response: 0.45, dampingFraction: 0.8)
                                            .delay(Double(indice) * 0.04),
                                        value: viewModel.filteredUsers.count
                                    )
                                    .accessibilityIdentifier("userRow_\(usuario.id)")
                            }
                        }
                        .padding(.vertical, Espaciado.sm)
                    }
                }
            }
            .navigationTitle("Usuarios")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $viewModel.searchText, prompt: "Buscar por nombre o usuario")
            .onAppear {
                viewModel.fetchUsers()
            }
            .onChange(of: viewModel.users.count) { _, nuevaCantidad in
                if nuevaCantidad > 0 {
                    withAnimation {
                        estaCargando = false
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
