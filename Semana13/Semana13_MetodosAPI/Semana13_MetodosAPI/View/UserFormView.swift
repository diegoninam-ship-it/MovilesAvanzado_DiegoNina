// Desarrollado por: Diego Nina Malqui

import SwiftUI

struct UserFormView: View {

    let userToEdit: User?
    let onSave: (User) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var username: String = ""
    @State private var email: String = ""

    private var isEditing: Bool { userToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Datos del usuario") {
                    TextField("Nombre", text: $name)
                    TextField("Usuario", text: $username)
                    TextField("Correo", text: $email)
                        .keyboardType(.emailAddress)
                }
            }
            .navigationTitle(isEditing ? "Editar usuario" : "Nuevo usuario")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        let user = User(
                            id: userToEdit?.id ?? 0,
                            name: name,
                            username: username,
                            email: email
                        )
                        onSave(user)
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let userToEdit {
                    name = userToEdit.name
                    username = userToEdit.username
                    email = userToEdit.email
                }
            }
        }
    }
}

#Preview {
    UserFormView(userToEdit: nil, onSave: { _ in })
}
