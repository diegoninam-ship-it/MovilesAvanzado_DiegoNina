// Desarrollado por: Diego Nina Malqui

import SwiftUI

struct TarjetaUsuario: View {

    let nombre: String
    let correo: String

    private var inicial: String {
        String(nombre.first ?? "?").uppercased()
    }

    var body: some View {
        HStack(spacing: Espaciado.md) {
            Circle()
                .fill(Colores.colorAvatar(para: nombre))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(inicial)
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: Espaciado.xs) {
                Text(nombre)
                    .font(Tipografia.tituloFila)
                    .foregroundStyle(.primary)
                Text(correo)
                    .font(Tipografia.caption)
                    .foregroundStyle(Colores.textoSecundario)
            }

            Spacer()
        }
        .padding(Espaciado.md)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: Espaciado.radioTarjeta, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    TarjetaUsuario(nombre: "Leanne Graham", correo: "leanne@example.com")
        .padding()
}
