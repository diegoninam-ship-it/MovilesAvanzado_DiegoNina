// Desarrollado por: Diego Nina Malqui

import SwiftUI

struct EstadoCargando: View {

    var mensaje: String = "Cargando usuarios..."

    var body: some View {
        VStack(spacing: Espaciado.sm) {
            ProgressView()
                .controlSize(.large)
                .tint(Colores.acentoPrimario)

            Text(mensaje)
                .font(Tipografia.caption)
                .foregroundStyle(Colores.textoSecundario)
        }
        .padding(Espaciado.lg)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EstadoCargando()
}
