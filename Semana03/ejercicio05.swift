// Desarrollado por: [Diego Nina]
import Foundation
// ===== CARRITO DE COMPRAS 2.0 =====
var nombres: [String] = []
var precios: [Double] = []
var cantidades: [Int] = []
// TODO 11: Pedir productos
print("¿Cuántos productos va a comprar?")
let totalProductos = Int(readLine() ?? "") ?? 0
for i in 1...totalProductos {
    print("\nProducto \(i) - Nombre:")
    nombres.append(readLine() ?? "")
    print("Precio unitario:")
    precios.append(Double(readLine() ?? "") ?? 0)
    print("Cantidad:")
    cantidades.append(Int(readLine() ?? "") ?? 0)
}
