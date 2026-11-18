import SwiftUI
import SwiftData

/// Modifica el offset horizontal con un "shake" cuando `intentos` cambia.
private struct Shake: GeometryEffect {
    var intentos: CGFloat
    var amplitud: CGFloat = 8

    var animatableData: CGFloat {
        get { intentos }
        set { intentos = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let traslacion = amplitud * sin(intentos * .pi * 3)
        return ProjectionTransform(CGAffineTransform(translationX: traslacion, y: 0))
    }
}

struct LoginView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(SesionUsuario.self) private var sesion

    @State private var usuario = ""
    @State private var clave = ""
    @State private var intentosFallidos: CGFloat = 0
    @State private var anguloGradiente = false
    @State private var mostrarError = false

    var body: some View {
        NavigationStack {
            ZStack {
                fondoAnimado

                ScrollView {
                    VStack(spacing: Espaciado.xl) {
                        VStack(spacing: Espaciado.m) {
                            Image(systemName: "cart.fill")
                                .font(.system(size: 56))
                                .foregroundStyle(.white)
                                .padding(Espaciado.l)
                                .background(.ultraThinMaterial, in: Circle())

                            Text("Compras")
                                .font(Tipografia.tituloPantalla)
                                .foregroundStyle(.white)
                        }
                        .padding(.top, Espaciado.xxl)

                        TarjetaGlass {
                            VStack(spacing: Espaciado.m) {
                                TextField("Usuario", text: $usuario)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled()
                                SecureField("Clave", text: $clave)
                            }
                        }
                        .modifier(Shake(intentos: intentosFallidos))

                        if mostrarError {
                            Text("Usuario o clave incorrectos")
                                .font(Tipografia.caption)
                                .foregroundStyle(.white)
                                .padding(.horizontal, Espaciado.m)
                                .padding(.vertical, Espaciado.s)
                                .background(Color.peligro.opacity(0.85), in: Capsule())
                                .transition(.opacity.combined(with: .scale))
                        }

                        Button("Ingresar") {
                            ingresar()
                        }
                        .buttonStyle(.primario)

                        NavigationLink {
                            RegistroView()
                        } label: {
                            Text("Crear cuenta")
                                .foregroundStyle(.white)
                                .font(.subheadline.bold())
                        }
                    }
                    .padding(Espaciado.l)
                }
            }
            .onAppear {
                withAnimation(.easeInOut(duration: 6).repeatForever(autoreverses: true)) {
                    anguloGradiente.toggle()
                }
            }
        }
    }

    private var fondoAnimado: some View {
        LinearGradient(
            colors: [Color.acentoPrimario, Color.acentoPrimario.opacity(0.6), Color.fondoApp],
            startPoint: anguloGradiente ? .topLeading : .bottomLeading,
            endPoint: anguloGradiente ? .bottomTrailing : .topTrailing
        )
        .ignoresSafeArea()
    }

    private func ingresar() {
        let usuarioTexto = usuario.lowercased()
        let claveTexto = clave
        let descriptor = FetchDescriptor<Usuario>(
            predicate: #Predicate { $0.usuario == usuarioTexto }
        )
        guard let usuarioEncontrado = try? modelContext.fetch(descriptor).first,
              usuarioEncontrado.clave == claveTexto else {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.3)) {
                intentosFallidos += 1
                mostrarError = true
            }
            return
        }
        mostrarError = false
        sesion.usuarioActual = usuarioEncontrado
    }
}
