// Desarrollado por: [Diego Nina]
import Foundation
// Pide N productos con nombre, precio y stock
// Calcula valor total y muestra stock bajo
var precios: [String: Double] = [:]
var stocks: [String: Int] = [:]
print("¿Cuántos productos?")
let n = Int(readLine() ?? "") ?? 0
for i in 1...n {
    print("Producto \(i) - Nombre:")
    let nombre = readLine() ?? ""
    print("Precio:")
    let precio = Double(readLine() ?? "") ?? 0
    print("Stock:")
    let stock = Int(readLine() ?? "") ?? 0
    precios[nombre] = precio
    stocks[nombre] = stock
}
// TODO: Calcular valor total (precio × stock)
var resultado = 0.0
for (nombre, precio) in precios{
    for (nombre, stock) in stocks{
        var resultado += precio * Double(stock) 
    }
}

// TODO: Mostrar productos con stock < 5
print("\n===== STOCK BAJO (< 5 unidades) =====")
for (nombre, stock) in stocks{
    if stock < 5{
        print("\(nombre): \(stock) unidades")
    } 
}
