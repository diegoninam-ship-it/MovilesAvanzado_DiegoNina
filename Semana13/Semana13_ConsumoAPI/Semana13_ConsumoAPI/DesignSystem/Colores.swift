// Desarrollado por: Diego Nina Malqui

import SwiftUI

enum Colores {

    static let fondo = Color("ColorFondo")
    static let superficie = Color("ColorSuperficie")
    static let acentoPrimario = Color("ColorAcentoPrimario")
    static let exito = Color("ColorExito")
    static let advertencia = Color("ColorAdvertencia")
    static let peligro = Color("ColorPeligro")
    static let textoSecundario = Color("ColorTextoSecundario")

    // Paleta fija para avatares (derivada por hash del nombre).
    static let avatares: [Color] = [
        Color(red: 0.98, green: 0.42, blue: 0.42),
        Color(red: 0.98, green: 0.62, blue: 0.25),
        Color(red: 0.95, green: 0.80, blue: 0.20),
        Color(red: 0.35, green: 0.78, blue: 0.55),
        Color(red: 0.25, green: 0.70, blue: 0.85),
        Color(red: 0.45, green: 0.50, blue: 0.95),
        Color(red: 0.75, green: 0.45, blue: 0.90),
        Color(red: 0.92, green: 0.45, blue: 0.70)
    ]

    static func colorAvatar(para texto: String) -> Color {
        let hash = abs(texto.hashValue)
        return avatares[hash % avatares.count]
    }
}
