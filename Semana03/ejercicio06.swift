// Desarrollado por: Diego Nina
import Foundation

var alumnos: [String: [Double]] = [:]

let sep = String(repeating: "=", count: 45)
print(sep)
print(" GESTION DE NOTAS")
print(sep)

print("¿Cuantos alumnos va a ingresar?")
let cantidad = Int(readLine() ?? "") ?? 0

for i in 1...cantidad {
    print("\nAlumno \(i) - Nombre:")
    let nombre = readLine() ?? ""
    for j in 1...3 {
        print("Nota \(j) - \(nombre):")
        let nota = Double(readLine() ?? "") ?? 0
        alumnos[nombre, default: []].append(nota)
    }
}

print("\n\(sep)")
print(" PROMEDIO POR ALUMNO")
print(sep)

var promedios: [String: Double] = [:]

for (nombre, notas) in alumnos {
    let promedio = notas.reduce(0, +) / Double(notas.count)
    promedios[nombre] = promedio

    var categoria = ""
    switch promedio {
    case 18...: categoria = "Excelente"
    case 15..<18: categoria = "Bueno"
    case 13..<15: categoria = "Aprobado"
    default: categoria = "Desaprobado"
    }

    print("Alumno: \(nombre) - Promedio: \(promedio) - \(categoria)")
}

// ===== TODO 10: Estadísticas =====
print("\n\(sep)")
print(" ESTADISTICAS GENERALES")
print(sep)

let listaPromedios = Array(promedios.values)
let promedioGeneral = listaPromedios.reduce(0, +) / Double(listaPromedios.count)
let notaMasAlta = listaPromedios.max() ?? 0
let notaMasBaja = listaPromedios.min() ?? 0
let totalAprobados = listaPromedios.filter { $0 >= 13 }.count
let porcentajeAprobados = Double(totalAprobados) / Double(listaPromedios.count) * 100

print("Promedio general: \(promedioGeneral)")
print("Nota más alta: \(notaMasAlta)")
print("Nota más baja: \(notaMasBaja)")
print("Porcentaje de aprobados: \(porcentajeAprobados)%")

// ===== TODO 11: Ordenar por promedio =====
print("\n\(sep)")
print(" RANKING POR PROMEDIO")
print(sep)

let ranking = promedios.sorted { $0.value > $1.value }

for (nombre, promedio) in ranking {
    print("\(nombre): \(promedio)")
}