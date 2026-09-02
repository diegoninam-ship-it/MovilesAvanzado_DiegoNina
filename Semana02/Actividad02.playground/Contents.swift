import Foundation

print("Ingrese el nombre del producto: ")
let nombreProducto = readLine() ?? "sin nombre"

print("Ingrese el precio unitario: ")
let precioUnitario = Double(readLine() ?? "0") ?? 0

print("Ingrese la cantidad en inventario: ")
let cantidad = Double(readLine() ?? "0") ?? 0

let montoTotal = precioUnitario * cantidad


func columna(_ texto: String, ancho: Int) -> String {
    if texto.count >= ancho {
        return texto
    }
    let espacios = String(repeating: " ", count: ancho - texto.count)
    return texto + espacios
}
 
func imprimirTablaAmortizacion(meses: Int, montoFinal: Double, pagoMensual: Double) {
    let anchoMes = 8
    let anchoMonto = 18
    let anchoCosto = 18
    let anchoResta = 18
 
    print("")
    print(columna("Mes", ancho: anchoMes)
        + columna("Monto inicial", ancho: anchoMonto)
        + columna("Costo mensual", ancho: anchoCosto)
        + columna("Resta por pagar", ancho: anchoResta))
 
    let anchoTotal = anchoMes + anchoMonto + anchoCosto + anchoResta
    print(String(repeating: "-", count: anchoTotal))
 
    var montoInicial = montoFinal
 
    for mes in 1...meses {
        let resta = montoInicial - pagoMensual
 
        let filaMes = columna("\(mes)", ancho: anchoMes)
        let filaMontoInicial = columna(String(format: "%.2f", montoInicial), ancho: anchoMonto)
        let filaCostoMensual = columna(String(format: "%.2f", pagoMensual), ancho: anchoCosto)
        let filaResta = columna(String(format: "%.2f", resta), ancho: anchoResta)
 
        print(filaMes + filaMontoInicial + filaCostoMensual + filaResta)
 
        montoInicial = resta
    }
}


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

        imprimirTablaAmortizacion(meses: meses, montoFinal: montoFinal, pagoMensual: pagoMensual)
        
        break
    } else {
        print("Opción inválida. Intente de nuevo.")
    }
}


    


