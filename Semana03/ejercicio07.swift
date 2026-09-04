// Desarrollado por: Diego Nina
import Foundation

var nombres: [String] = []
var precios: [Double] = []
var stocks: [Int] = []

print("¿Cuántos productos va a registrar?")
let totalProductos = Int(readLine() ?? "") ?? 0

for i in 1...totalProductos {
    print("\nProducto \(i) - Nombre:")
    nombres.append(readLine() ?? "")
    print("Precio:")
    precios.append(Double(readLine() ?? "") ?? 0)
    print("Stock:")
    stocks.append(Int(readLine() ?? "") ?? 0)
}

var opcion = ""

while opcion != "5" {
    print("\n1) Ver inventario")
    print("2) Buscar producto")
    print("3) Stock bajo")
    print("4) Valor total")
    print("5) Salir")
    print("Elige una opción:")
    opcion = readLine() ?? ""

    if opcion == "1" {
        for i in 0..<nombres.count {
            print("\(nombres[i]) - Precio: S/. \(precios[i]) - Stock: \(stocks[i])")
        }
    } else if opcion == "2" {
        print("Nombre del producto a buscar:")
        let buscar = readLine() ?? ""
        var encontrado = false
        for i in 0..<nombres.count {
            if nombres[i] == buscar {
                print("\(nombres[i]) - Precio: S/. \(precios[i]) - Stock: \(stocks[i])")
                encontrado = true
            }
        }
        if !encontrado {
            print("Producto no encontrado")
        }
    } else if opcion == "3" {
        for i in 0..<nombres.count {
            if stocks[i] < 5 {
                print("\(nombres[i]): \(stocks[i]) unidades")
            }
        }
    } else if opcion == "4" {
        var valorTotal = 0.0
        for i in 0..<nombres.count {
            valorTotal += precios[i] * Double(stocks[i])
        }
        print("Valor total: S/. \(valorTotal)")
    } else if opcion == "5" {
        print("¡Hasta luego!")
    } else {
        print("Opción inválida")
    }
}