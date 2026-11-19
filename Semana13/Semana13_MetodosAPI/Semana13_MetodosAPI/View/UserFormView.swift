// Desarrollado por: Diego Nina Malqui

import SwiftUI

struct UserFormView: View {

    let userToEdit: User?
    let onSave: (User) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var botonPresionado = false

    private var isEditing: Bool { userToEdit != nil }

    private var nombreVacio: Bool { name.trimmingCharacters(in: .whitespaces).isEmpty }
    private var usuarioVacio: Bool { username.trimmingCharacters(in: .whitespaces).isEmpty }
    private var correoVacio: Bool { email.trimmingCharacters(in: .whitespaces).isEmpty }
    private var formularioValido: Bool {
        formularioEsValido(nombre: name, username: username, correo: email)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Colores.fondo.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: Espaciado.md) {
                        VStack(alignment: .leading, spacing: Espaciado.md) {
                            campoFormulario(
                                titulo: "Nombre",
                                texto: $name,
                                vacio: nombreVacio,
                                ayuda: "El nombre es obligatorio",
                                identificador: "campoNombre"
                            )
                            campoFormulario(
                                titulo: "Usuario",
                                texto: $username,
                                vacio: usuarioVacio,
                                ayuda: "El usuario es obligatorio",
                                identificador: "campoUsuario"
                            )
                            campoFormulario(
                                titulo: "Correo",
                                texto: $email,
                                vacio: correoVacio,
                                ayuda: "El correo es obligatorio",
                                teclado: .emailAddress,
                                identificador: "campoCorreo"
                            )
                        }
                        .padding(Espaciado.md)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Espaciado.radioTarjeta, style: .continuous))

                        Button {
                            let user = User(
                                id: userToEdit?.id ?? 0,
                                name: name,
                                username: username,
                                email: email
                            )
                            onSave(user)
                            dismiss()
                        } label: {
                            Text("Guardar")
                                .font(Tipografia.tituloFila)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, Espaciado.sm)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.white)
                        .background(
                            formularioValido ? Colores.acentoPrimario : Colores.textoSecundario,
                            in: RoundedRectangle(cornerRadius: Espaciado.radioBoton, style: .continuous)
                        )
                        .scaleEffect(botonPresionado ? 0.96 : 1.0)
                        .disabled(!formularioValido)
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in botonPresionado = true }
                                .onEnded { _ in botonPresionado = false }
                        )
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: botonPresionado)
                        .animation(.easeInOut(duration: 0.2), value: formularioValido)
                        .accessibilityIdentifier("botonGuardar")
                    }
                    .padding(Espaciado.md)
                }
            }
            .navigationTitle(isEditing ? "Editar usuario" : "Nuevo usuario")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") { dismiss() }
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
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func campoFormulario(
        titulo: String,
        texto: Binding<String>,
        vacio: Bool,
        ayuda: String,
        teclado: UIKeyboardType = .default,
        identificador: String
    ) -> some View {
        VStack(alignment: .leading, spacing: Espaciado.xs) {
            Text(titulo)
                .font(Tipografia.caption)
                .foregroundStyle(Colores.textoSecundario)

            TextField(titulo, text: texto)
                .keyboardType(teclado)
                .padding(Espaciado.sm)
                .background(Colores.superficie, in: RoundedRectangle(cornerRadius: Espaciado.radioBoton, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: Espaciado.radioBoton, style: .continuous)
                        .strokeBorder(vacio ? Colores.advertencia : Color.clear, lineWidth: 1.5)
                )
                .accessibilityIdentifier(identificador)

            if vacio {
                Text(ayuda)
                    .font(Tipografia.caption)
                    .foregroundStyle(Colores.advertencia)
            }
        }
    }
}

#Preview {
    UserFormView(userToEdit: nil, onSave: { _ in })
}
