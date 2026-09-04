// Desarrollado por: Diego Nina
// Herramienta usada: Claude
import Foundation // Importa funcionalidades base de Swift

var nombres: [String] = [] // Array con los nombres de los productos
var precios: [Double] = [] // Array con los precios (mismo índice que nombres)
var stocks: [Int] = [] // Array con el stock (mismo índice que nombres)

let sep = String(repeating: "=", count: 45) // Línea separadora de 45 signos "="
print(sep) // Imprime separador
print(" INVENTARIO CON MENU") // Imprime título del programa
print(sep) // Imprime separador

print("¿Cuántos productos va a registrar?") // Pregunta cuántos productos cargar al inicio
let totalProductos = Int(readLine() ?? "") ?? 0 // Lee y convierte a Int; si falla usa 0

for i in 1...totalProductos { // Repite una vez por cada producto a registrar
    print("\nProducto \(i) - Nombre:") // Pregunta el nombre del producto actual
    nombres.append(readLine() ?? "") // Lee el nombre y lo agrega al array
    print("Precio:") // Pregunta el precio
    precios.append(Double(readLine() ?? "") ?? 0) // Lee, convierte a Double y agrega al array
    print("Stock:") // Pregunta el stock
    stocks.append(Int(readLine() ?? "") ?? 0) // Lee, convierte a Int y agrega al array
}

var opcion = "" // Variable que guardará la opción elegida por el usuario en el menú

while opcion != "5" { // Repite el menú mientras el usuario no elija la opción 5 (Salir)
    print("\n\(sep)") // Imprime salto de línea + separador antes del menú
    print(" MENU INVENTARIO") // Imprime título del menú
    print(sep) // Imprime separador
    print("1) Ver inventario") // Muestra opción 1
    print("2) Buscar producto") // Muestra opción 2
    print("3) Stock bajo") // Muestra opción 3
    print("4) Valor total") // Muestra opción 4
    print("5) Salir") // Muestra opción 5
    print("Elige una opción:") // Pide al usuario que escriba su elección
    opcion = readLine() ?? "" // Lee la opción elegida y la guarda; si falla queda string vacío

    switch opcion { // Evalúa qué opción escribió el usuario
    case "1": // Si eligió Ver inventario
        print("\n===== INVENTARIO =====") // Imprime título de la sección
        for i in 0..<nombres.count { // Recorre todos los productos por índice
            print("\(nombres[i]) - Precio: S/. \(precios[i]) - Stock: \(stocks[i])") // Imprime cada producto con sus datos
        }

    case "2": // Si eligió Buscar producto
        print("\nNombre del producto a buscar:") // Pide el nombre a buscar
        let buscar = readLine() ?? "" // Lee el nombre buscado
        if let index = nombres.firstIndex(of: buscar) { // Busca la posición del nombre en el array; si existe, la guarda en index
            print("\(nombres[index]) - Precio: S/. \(precios[index]) - Stock: \(stocks[index])") // Imprime el producto encontrado usando su índice
        } else { // Si firstIndex no encontró el nombre (devolvió nil)
            print("Producto no encontrado") // Informa que no existe
        }

    case "3": // Si eligió Stock bajo
        print("\n===== STOCK BAJO (< 5 unidades) =====") // Imprime título de la sección
        for i in 0..<nombres.count { // Recorre todos los productos por índice
            if stocks[i] < 5 { // Si el stock de este producto es menor a 5
                print("\(nombres[i]): \(stocks[i]) unidades") // Imprime el producto con stock bajo
            }
        }

    case "4": // Si eligió Valor total
        var valorTotal = 0.0 // Acumulador del valor total del inventario
        for i in 0..<nombres.count { // Recorre todos los productos por índice
            valorTotal += precios[i] * Double(stocks[i]) // Suma precio × stock de cada producto al total
        }
        print("\nValor total del inventario: S/. \(valorTotal)") // Imprime el valor total calculado

    case "5": // Si eligió Salir
        print("\n¡Hasta luego!") // Imprime mensaje de despedida

    default: // Si escribió algo que no es 1-5
        print("\nOpción inválida, intente de nuevo") // Informa que la opción no es válida
    }
}