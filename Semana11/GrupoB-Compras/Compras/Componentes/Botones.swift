import SwiftUI

private struct EstiloBotonAnimado: ButtonStyle {
    let colorFondo: Color
    let colorTexto: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.body.bold())
            .padding(.vertical, Espaciado.m)
            .frame(maxWidth: .infinity)
            .background(colorFondo, in: RoundedRectangle(cornerRadius: Radio.cardPequena, style: .continuous))
            .foregroundStyle(colorTexto)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == EstiloBotonAnimado {
    static var primario: EstiloBotonAnimado {
        EstiloBotonAnimado(colorFondo: .acentoPrimario, colorTexto: .white)
    }

    static var secundario: EstiloBotonAnimado {
        EstiloBotonAnimado(colorFondo: Color.acentoPrimario.opacity(0.12), colorTexto: .acentoPrimario)
    }
}
