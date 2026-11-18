import SwiftUI

/// Escala tipográfica de la app. Usa San Francisco (sistema) con pesos y tracking
/// definidos para que ningún lugar de la UI invente su propio tamaño de fuente.
enum Tipografia {
    static let tituloPantalla = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let tituloTarjeta = Font.system(.headline, design: .rounded, weight: .semibold)
    static let cuerpo = Font.system(.body, design: .default, weight: .regular)
    static let caption = Font.system(.caption, design: .default, weight: .medium)
    /// Para cifras grandes (Resumen): tabular para que no "bailen" al animar.
    static let cifraDestacada = Font.system(size: 34, weight: .bold, design: .rounded).monospacedDigit()
}

extension Text {
    func tituloPantalla() -> Text { self.font(Tipografia.tituloPantalla) }
    func tituloTarjeta() -> Text { self.font(Tipografia.tituloTarjeta) }
    func cuerpo() -> Text { self.font(Tipografia.cuerpo) }
    func caption() -> Text { self.font(Tipografia.caption) }
    func cifraDestacada() -> Text { self.font(Tipografia.cifraDestacada) }
}
