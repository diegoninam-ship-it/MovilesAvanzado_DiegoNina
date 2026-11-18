import SwiftUI

/// Muestra una cifra en formato "S/. %.2f" que cuenta hacia su valor al aparecer o cambiar.
struct CifraAnimada: View {
    let valor: Double
    var fuente: Font = Tipografia.cifraDestacada

    var body: some View {
        Text(String(format: "S/. %.2f", valor))
            .font(fuente)
            .contentTransition(.numericText(value: valor))
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: valor)
    }
}
