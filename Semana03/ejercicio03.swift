// Desarrollado por: [Diego Nina]
import Foundation
// ===== TODO 8: Eliminar duplicados =====
var numeros: [Int] = []
for i in 1...8 {
    print("Número \(i):")
    let n = Int(readLine() ?? "") ?? 0
    numeros.append(n)
}
print("Con duplicados: \(numeros)")
let sinDuplicados = Array(Set(numeros)).sorted()
print("Sin duplicados: \(sinDuplicados)")
// ===== TODO 9: Comparar asistencia =====
// Pide 4 lunes, 4 martes
// Muestra: ambos días, solo lunes, solo martes

var diasLunes: set<String> = []

print("Ingresa 4 lunes: ")
for i in 1...4 {
    let n = String(readLine() ?? "") ?? ""
    diasLunes.insert(n)
}

var diasMartes: set<String> = []

print("Ingresa 4 lunes: ")
for i in 1...4 {
    let n = String(readLine() ?? "") ?? ""
    diasMartes.insert(n)
}


let todos = diasLunes.union(diasMartes)
let soloLunes = diasLunes.subtracting(diasMartes)
let soloMartes = diasMartes.subtracting(diasLunes)

print("\n===== RESULTADOS =====")
print("En ambos: \(enAmbos)")
print("Solo Lunes: \(soloLunes)")
print("Solo Martes: \(soloMartes)")
