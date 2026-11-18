import Foundation
import SwiftData

@Model
final class Proveedor {
    var nombre: String
    var ruc: String

    @Relationship(deleteRule: .deny, inverse: \Compra.proveedor)
    var compras: [Compra] = []

    init(nombre: String, ruc: String) {
        self.nombre = nombre
        self.ruc = ruc
    }
}
