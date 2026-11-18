import SwiftUI

struct EstadoVacio: View {
    let icono: String
    let titulo: String
    var subtitulo: String?

    var body: some View {
        VStack(spacing: Espaciado.m) {
            Image(systemName: icono)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text(titulo)
                .font(Tipografia.tituloTarjeta)
                .multilineTextAlignment(.center)
            if let subtitulo {
                Text(subtitulo)
                    .font(Tipografia.caption)
                    .foregroundStyle(Color.textoSecundario)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Espaciado.xxl)
    }
}
