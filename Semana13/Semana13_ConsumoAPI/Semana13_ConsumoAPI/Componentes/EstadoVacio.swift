// Desarrollado por: Diego Nina Malqui

import SwiftUI

struct EstadoVacio: View {

    let icono: String
    let titulo: String
    let mensaje: String

    var body: some View {
        VStack(spacing: Espaciado.sm) {
            Image(systemName: icono)
                .font(.system(size: 48))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Colores.acentoPrimario)
                .accessibilityHidden(true)

            Text(titulo)
                .font(Tipografia.tituloFila)
                .foregroundStyle(.primary)

            Text(mensaje)
                .font(Tipografia.cuerpo)
                .foregroundStyle(Colores.textoSecundario)
                .multilineTextAlignment(.center)
        }
        .padding(Espaciado.lg)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    EstadoVacio(
        icono: "magnifyingglass",
        titulo: "Sin resultados",
        mensaje: "No encontramos usuarios que coincidan con tu busqueda."
    )
}
