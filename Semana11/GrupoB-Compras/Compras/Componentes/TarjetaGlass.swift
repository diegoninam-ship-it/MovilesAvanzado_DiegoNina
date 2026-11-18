import SwiftUI

struct TarjetaGlass<Contenido: View>: View {
    @ViewBuilder var contenido: Contenido

    var body: some View {
        contenido
            .padding(Espaciado.l)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Radio.cardGrande, style: .continuous))
    }
}
