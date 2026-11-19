// Desarrollado por: Diego Nina Malqui

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = UserViewModel()
    @State private var editingUser: User? = nil
    @State private var showingForm = false
    @State private var estaCargando = true

    var body: some View {
        NavigationStack {
            ZStack {
                Colores.fondo.ignoresSafeArea()

                if estaCargando {
                    EstadoCargando()
                } else if viewModel.users.isEmpty {
                    EstadoVacio(
                        icono: "person.2.slash",
                        titulo: "Sin usuarios",
                        mensaje: "Agrega tu primer usuario con el boton +."
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: Espaciado.sm) {
                            ForEach(Array(viewModel.users.enumerated()), id: \.element.id) { indice, user in
                                TarjetaUsuario(nombre: user.name, correo: user.email)
                                    .padding(.horizontal, Espaciado.md)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                                    .animation(
                                        .spring(response: 0.45, dampingFraction: 0.8)
                                            .delay(Double(indice) * 0.04),
                                        value: viewModel.users.count
                                    )
                                    .swipeActions {
                                        Button(role: .destructive) {
                                            Task {
                                                await viewModel.deleteUser(user)
                                            }
                                        } label: {
                                            Label("Eliminar", systemImage: "trash")
                                        }
                                        .tint(Colores.peligro)
                                        .accessibilityLabel("Eliminar a \(user.name)")

                                        Button {
                                            editingUser = user
                                            showingForm = true
                                        } label: {
                                            Label("Editar", systemImage: "pencil")
                                        }
                                        .tint(Colores.acentoPrimario)
                                        .accessibilityLabel("Editar a \(user.name)")
                                    }
                                    .accessibilityIdentifier("userRow_\(user.id)")
                            }
                        }
                        .padding(.vertical, Espaciado.sm)
                    }
                }
            }
            .navigationTitle("Usuarios")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        Task {
                            await viewModel.fetchUsers()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel("Actualizar lista de usuarios")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingUser = nil
                        showingForm = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Colores.acentoPrimario)
                    }
                    .accessibilityLabel("Agregar nuevo usuario")
                    .accessibilityIdentifier("botonAgregar")
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchUsers()
                    withAnimation {
                        estaCargando = false
                    }
                }
            }
            .sheet(isPresented: $showingForm) {
                UserFormView(userToEdit: editingUser) { user in
                    Task {
                        if editingUser != nil {
                            await viewModel.updateUser(user)
                        } else {
                            await viewModel.addUser(user)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
