import SwiftUI

struct InsigniaEstado: View {
    let texto: String
    let color: Color

    var body: some View {
        Text(texto.uppercased())
            .font(.caption2.bold())
            .tracking(0.5)
            .padding(.horizontal, Espaciado.s)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
}
