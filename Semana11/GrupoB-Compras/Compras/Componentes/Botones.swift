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

struct BotonPrimarioStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        EstiloBotonAnimado(colorFondo: .acentoPrimario, colorTexto: .white).makeBody(configuration: configuration)
    }
}

struct BotonSecundarioStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        EstiloBotonAnimado(colorFondo: Color.acentoPrimario.opacity(0.12), colorTexto: .acentoPrimario).makeBody(configuration: configuration)
    }
}

extension ButtonStyle where Self == BotonPrimarioStyle {
    static var primario: BotonPrimarioStyle { BotonPrimarioStyle() }
}

extension ButtonStyle where Self == BotonSecundarioStyle {
    static var secundario: BotonSecundarioStyle { BotonSecundarioStyle() }
}
