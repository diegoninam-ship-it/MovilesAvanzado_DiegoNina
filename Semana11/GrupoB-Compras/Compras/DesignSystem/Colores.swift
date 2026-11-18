import SwiftUI

extension Color {
    /// Crea un color que cambia automáticamente entre Light y Dark Mode.
    init(light: Color, dark: Color) {
        self = Color(UIColor { trait in
            trait.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    // MARK: - Paleta semántica "Compras"
    // Acento: verde-azulado profundo, con caracter propio (no el azul de sistema).

    static let fondoApp = Color(
        light: Color(red: 0.96, green: 0.97, blue: 0.97),
        dark: Color(red: 0.06, green: 0.08, blue: 0.09)
    )

    static let superficieCard = Color(
        light: Color.white.opacity(0.7),
        dark: Color(red: 0.12, green: 0.15, blue: 0.16).opacity(0.6)
    )

    static let acentoPrimario = Color(
        light: Color(red: 0.03, green: 0.42, blue: 0.40),
        dark: Color(red: 0.22, green: 0.70, blue: 0.64)
    )

    static let exito = Color(
        light: Color(red: 0.12, green: 0.55, blue: 0.35),
        dark: Color(red: 0.30, green: 0.78, blue: 0.52)
    )

    static let advertencia = Color(
        light: Color(red: 0.80, green: 0.52, blue: 0.08),
        dark: Color(red: 0.95, green: 0.70, blue: 0.25)
    )

    static let peligro = Color(
        light: Color(red: 0.75, green: 0.18, blue: 0.20),
        dark: Color(red: 0.95, green: 0.40, blue: 0.40)
    )

    static let textoSecundario = Color(
        light: Color.black.opacity(0.55),
        dark: Color.white.opacity(0.6)
    )
}
