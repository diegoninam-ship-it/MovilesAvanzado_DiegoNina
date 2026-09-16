import Foundation

enum CategoriaElectro {
    case lineaBlanca, tecnologia, pequenos
}

struct Electrodomestico {
    let nombre: String
    let marca: String
    let precioLista: Double
    let categoria: CategoriaElectro
}

class SucursalLima: Sucursal {
    override func descuento() -> Double {
        return 0.10
    }

    override func costoEnvio(monto: Double) -> Double {
        if monto >= 1500 {
            return 0.0
        } else {
            return 30.0
        }
    }
}

class SucursalProvincia: Sucursal {
    // No se sobreescribe descuento(): hereda el 0.05 de la clase base

    override func costoEnvio(monto: Double) -> Double {
        let envioCalculado = monto * 0.08
        if envioCalculado < 50.0 {
            return 50.0
        } else {
            return envioCalculado
        }
    }
}

class SucursalOutlet: Sucursal {
    override func descuento() -> Double {
        return 0.25
    }

    override func costoEnvio(monto: Double) -> Double {
        return 0.0
    }
}

class SucursalOnline: Sucursal {
    override func costoEnvio(monto: Double) -> Double {
        return 15.0
    }
}


class SucursalMall: Sucursal {
    override func descuento() -> Double {
        return 0.12
    }
}

 // FIX 7: no compila. Que palabra clave falta y por que Swift la exige? Porque falta Override, sin esa palabra reservada swift no es capaz de indentificar si quiero reemplazar el método de la superclase o si accidentalmente escribiste un método nuevo

class SucursalExpress: Sucursal {
    let radioKm: Int

    init(nombre: String, ciudad: String, radioKm: Int) {
        self.radioKm = radioKm
        super.init(nombre: nombre, ciudad: ciudad)
    }
}

// FIX 8: no compila. Que llamada falta al final del init? Porque a medias tintas inicializo el constructor, ya que hacía falta delegar la super clase para que termine de inicializar lo heredado.


let refrigeradora = Electrodomestico(nombre: "Refrigeradora", marca: "Frost", precioLista: 2000.0, categoria: .lineaBlanca)
let licuadora = Electrodomestico(nombre: "Licuadora", marca: "Mix", precioLista: 250.0, categoria: .pequenos)

let sucursales: [Sucursal] = [
    SucursalLima(nombre: "Lima Centro", ciudad: "Lima"),
    SucursalProvincia(nombre: "Provincia Cusco", ciudad: "Cusco"),
    SucursalOutlet(nombre: "Outlet Ate", ciudad: "Lima"),
    SucursalOnline(nombre: "Tienda Online", ciudad: "Nacional")
]

print("===== Refrigeradora (S/ 2000.0) =====")
for sucursal in sucursales {
    sucursal.cotizar(item: refrigeradora)
}

print("===== Licuadora (S/ 250.0) =====")
for sucursal in sucursales {
    sucursal.cotizar(item: licuadora)
}

// Responde en un comentario: cuantas lineas nuevas necesitaste? 5 lineas

let misteriosa: Sucursal = SucursalLima(nombre: "Lima Centro", ciudad: "Lima")
print(misteriosa.descuento())               // PREDICT 6 → 0.1
let monto = 2000.0 * (1 - misteriosa.descuento())
print(misteriosa.costoEnvio(monto: monto))  // PREDICT 7 → 0.0