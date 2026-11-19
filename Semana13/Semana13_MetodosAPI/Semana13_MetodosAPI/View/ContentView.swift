// Desarrollado por: Diego Nina Malqui

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = UserViewModel()
    @State private var editingUser: User? = nil
    @State private var showingForm = false

    var body: some View {
        NavigationStack {
            List(viewModel.users) { user in
                VStack(alignment: .leading) {
                    Text(user.name)
                        .font(.headline)
                        .foregroundColor(.accentColor)
                    Text(user.email)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .swipeActions {
                    Button(role: .destructive) {
                        viewModel.deleteUser(user)
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }

                    Button {
                        editingUser = user
                        showingForm = true
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    .tint(.orange)
                }
            }
            .navigationTitle("Usuarios")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        editingUser = nil
                        showingForm = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .onAppear {
                viewModel.fetchUsers()
            }
            .sheet(isPresented: $showingForm) {
                UserFormView(userToEdit: editingUser) { user in
                    if editingUser != nil {
                        viewModel.updateUser(user)
                    } else {
                        viewModel.addUser(user)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
