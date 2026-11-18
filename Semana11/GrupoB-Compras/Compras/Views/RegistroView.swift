import SwiftUI
import SwiftData

struct RegistroView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SesionUsuario.self) private var sesion
    @Environment(\.dismiss) private var dismiss

    @State private var nombre = ""
    @State private var usuario = ""
    @State private var clave = ""
    @State private var confirmacion = ""
    @State private var rol = "Comprador"

    @State private var mostrarAlerta = false
    @State private var mensajeAlerta = ""

    private let roles = ["Comprador", "Supervisor"]

    var body: some View {
        Form {
            Section("Datos personales") {
                TextField("Nombre completo", text: $nombre)
                TextField("Usuario", text: $usuario)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("Clave", text: $clave)
                SecureField("Confirmar clave", text: $confirmacion)
                Picker("Rol", selection: $rol) {
                    ForEach(roles, id: \.self) { Text($0) }
                }
            }

            Button("Registrarme") {
                registrar()
            }
        }
        .navigationTitle("Crear cuenta")
        .alert("Aviso", isPresented: $mostrarAlerta) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(mensajeAlerta)
        }
    }

    private func registrar() {
        guard !nombre.trimmingCharacters(in: .whitespaces).isEmpty,
              !usuario.trimmingCharacters(in: .whitespaces).isEmpty else {
            mensajeAlerta = "Completa nombre y usuario."
            mostrarAlerta = true
            return
        }
        guard clave.count >= 6 else {
            mensajeAlerta = "La clave debe tener al menos 6 caracteres."
            mostrarAlerta = true
            return
        }
        guard clave == confirmacion else {
            mensajeAlerta = "Las claves no coinciden."
            mostrarAlerta = true
            return
        }

        let usuarioTexto = usuario.lowercased()
        let descriptor = FetchDescriptor<Usuario>(
            predicate: #Predicate { $0.usuario == usuarioTexto }
        )
        let cantidadExistente = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard cantidadExistente == 0 else {
            mensajeAlerta = "Ese usuario ya existe."
            mostrarAlerta = true
            return
        }

        let nuevoUsuario = Usuario(nombre: nombre, usuario: usuarioTexto, clave: clave, rol: rol)
        modelContext.insert(nuevoUsuario)
        sesion.usuarioActual = nuevoUsuario
    }
}
