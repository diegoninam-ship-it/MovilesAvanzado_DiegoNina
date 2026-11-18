import SwiftUI

struct TarjetaGlass<Contenido: View>: View {
    @ViewBuilder var contenido: Contenido

    var body: some View {
        contenido
            .padding(Espaciado.l)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radio.cardGrande, style: .continuous))
    }
}

/// Anima la aparición de una fila con un pequeño retraso proporcional a su índice,
/// para que las listas "entren" de forma escalonada en vez de aparecer todas a la vez.
private struct AparicionEscalonada: ViewModifier {
    let indice: Int
    @State private var aparecio = false

    func body(content: Content) -> some View {
        content
            .opacity(aparecio ? 1 : 0)
            .offset(y: aparecio ? 0 : 12)
            .onAppear {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.8).delay(Double(indice) * 0.05)) {
                    aparecio = true
                }
            }
    }
}

extension View {
    func apareceEscalonado(indice: Int) -> some View {
        modifier(AparicionEscalonada(indice: indice))
    }
}
