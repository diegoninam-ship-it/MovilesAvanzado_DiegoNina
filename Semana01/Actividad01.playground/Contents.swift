import Foundation

// calendario de pagos
// ingresar el nombre del producto, precio, cantidad

let igv = 0.18

func calcularDescuento(subtotal: Double, cantidad: Int) -> Double {
    if cantidad > 10 {
        return subtotal * 0.15
    } else if cantidad > 5 {
        return subtotal * 0.10
    } else {
        return 0.0
    }
}

print ("ingrese el nombre del producto: ")
let nombreProducto = readLine() ?? ""

print ("ingrese el precio del producto: ")
let precioProducto = Double(readLine() ?? "0") ?? 0.0

print ("ingrese la cantidad de productos: ")
let cantidadProducto = Int(readLine() ?? "0") ?? 0

let subtotal = precioProducto * Double(cantidadProducto)
let descuento = calcularDescuento(subtotal: subtotal, cantidad: cantidadProducto)

let montoBase = subtotal - descuento
let igvValue = montoBase * igv
let total = montoBase + igvValue

print ("el nombre del producto es: \(nombreProducto)")
print ("el precio del producto es: \(precioProducto)")
print ("la cantidad de productos es: \(cantidadProducto)")
print ("el subtotal es: \(subtotal)")
print ("el descuento es: \(descuento)")
print("el total es: \(total)")

// hallar el montobase : subtotal - descuento
// hallar el igv : montobase * igv
// total: montobase + igv
// commit
// mostrar los datos
