//
//  VentaModel.swift
//  Lab06VentaPlazos
//

import Foundation

// Se usa class (no struct) porque el modelo se pasa por referencia entre
// NuevaVentaViewController y ResultadoViewController a traves de prepare(for:sender:),
// igual que ClienteModel en lab06_02.
class VentaModel: NSObject {

    var nombreProducto: String
    var subtotal: Double
    var igv: Double
    var base: Double
    var intereses: Double
    var total: Double
    var cuota: Double

    override init() {
        self.nombreProducto = ""
        self.subtotal = 0.0
        self.igv = 0.0
        self.base = 0.0
        self.intereses = 0.0
        self.total = 0.0
        self.cuota = 0.0
        super.init()
    }

    init(nombreProducto: String, subtotal: Double, igv: Double, base: Double, intereses: Double, total: Double, cuota: Double) {
        self.nombreProducto = nombreProducto
        self.subtotal = subtotal
        self.igv = igv
        self.base = base
        self.intereses = intereses
        self.total = total
        self.cuota = cuota
        super.init()
    }
}
