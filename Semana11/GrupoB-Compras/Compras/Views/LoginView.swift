import SwiftUI
import SwiftData

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SesionUsuario.self) private var sesion

    @State private var usuario = ""
    @State private var clave = ""
    @State private var mostrarAlerta = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Image(systemName: "cart.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundStyle(.tint)

                Text("Compras")
                    .font(.largeTitle.bold())

                VStack(spacing: 12) {
                    TextField("Usuario", text: $usuario)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                    SecureField("Clave", text: $clave)
                        .textFieldStyle(.roundedBorder)
                }

                Button("Ingresar") {
                    ingresar()
                }
                .buttonStyle(.borderedProminent)

                NavigationLink("Crear cuenta") {
                    RegistroView()
                }
            }
            .padding()
            .alert("Usuario o clave incorrectos", isPresented: $mostrarAlerta) {
                Button("OK", role: .cancel) {}
            }
        }
    }

    private func ingresar() {
        let usuarioTexto = usuario.lowercased()
        let claveTexto = clave
        let descriptor = FetchDescriptor<Usuario>(
            predicate: #Predicate { $0.usuario == usuarioTexto }
        )
        guard let usuarioEncontrado = try? modelContext.fetch(descriptor).first,
              usuarioEncontrado.clave == claveTexto else {
            mostrarAlerta = true
            return
        }
        sesion.usuarioActual = usuarioEncontrado
    }
}
