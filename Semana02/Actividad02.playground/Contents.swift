import Foundation

print("Ingrese el nombre del producto: ")
let nombreProducto = readLine() ?? "sin nombre"

print("Ingrese el precio unitario: ")
let precioUnitario = Double(readLine() ?? "0") ?? 0

print("Ingrese la cantidad en inventario: ")
let cantidad = Double(readLine() ?? "0") ?? 0

let montoTotal = precioUnitario * cantidad




while true {
    print("Elige el plan de pago (6, 12, 24) en meses: ")
    let meses: Int = Int(readLine() ?? "0") ?? 0

    if meses == 6 || meses == 12 || meses == 24 {
        let tasaInteres: Double
        switch meses {
        case 6:
            tasaInteres = 0.2
        case 12:
            tasaInteres = 0.4
        default:
            tasaInteres = 0.6
        }

        let interes = montoTotal * tasaInteres
        let montoFinal = montoTotal + interes
        let pagoMensual = montoFinal / Double(meses)
        
        print("")
        print("Producto: \(nombreProducto)")
        print("Monto total (sin interés): \(montoTotal)")
        print("Interés aplicado: \(interes)")
        print("Monto final a pagar: \(montoFinal)")
        print("Pago mensual: \(pagoMensual)")
        
        break
    } else {
        print("Opción inválida. Intente de nuevo.")
    }
}


    


