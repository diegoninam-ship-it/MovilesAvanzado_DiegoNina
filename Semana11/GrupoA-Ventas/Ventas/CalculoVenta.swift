//
//  CalculoVenta.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import Foundation

/// Fórmulas de la Sección 4 del expediente, en un solo lugar para poder probarlas con XCTest sin UI.
enum CalculoVenta {

    static let porcentajeDescuentoVIP = 0.10
    static let porcentajeIGV = 0.18
    static let umbralFrecuente = 1000.0
    static let umbralVIP = 5000.0

    static func subtotal(precioUnitario: Double, cantidad: Int) -> Double {
        precioUnitario * Double(cantidad)
    }

    /// VIP recibe 10% de descuento sobre el subtotal; los demás 0%.
    static func descuento(subtotal: Double, esVIP: Bool) -> Double {
        esVIP ? subtotal * porcentajeDescuentoVIP : 0
    }

    /// 18% de IGV sobre (subtotal - descuento).
    static func igv(subtotal: Double, descuento: Double) -> Double {
        (subtotal - descuento) * porcentajeIGV
    }

    static func total(subtotal: Double, descuento: Double, igv: Double) -> Double {
        subtotal - descuento + igv
    }

    /// Regular si lo comprado (ventas no anuladas) es menor a S/ 1,000; Frecuente desde S/ 1,000; VIP desde S/ 5,000.
    static func categoriaCliente(totalComprado: Double) -> String {
        if totalComprado >= umbralVIP { return "VIP" }
        if totalComprado >= umbralFrecuente { return "Frecuente" }
        return "Regular"
    }
}
