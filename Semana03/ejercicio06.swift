// Desarrollado por: Diego Nina
// Herramienta usada: Claude
import Foundation // Importa funcionalidades base de Swift (String, Double, etc.)

var alumnos: [String: [Double]] = [:] // Diccionario: clave = nombre del alumno, valor = array de sus 3 notas

let sep = String(repeating: "=", count: 45) // Crea una línea separadora de 45 signos "="
print(sep) // Imprime la línea separadora
print(" GESTION DE NOTAS") // Imprime el título del programa
print(sep) // Imprime otra línea separadora

print("¿Cuantos alumnos va a ingresar?") // Pregunta cuántos alumnos se van a registrar
let cantidad = Int(readLine() ?? "") ?? 0 // Lee la respuesta y la convierte a Int; si falla, usa 0

for i in 1...cantidad { // Repite una vez por cada alumno a ingresar
    print("\nAlumno \(i) - Nombre:") // Pregunta el nombre del alumno actual
    let nombre = readLine() ?? "" // Lee el nombre; si falla, usa string vacío
    for j in 1...3 { // Repite 3 veces para pedir las 3 notas de este alumno
        print("Nota \(j) - \(nombre):") // Pregunta la nota número j del alumno
        let nota = Double(readLine() ?? "") ?? 0 // Lee la nota y la convierte a Double; si falla, usa 0
        alumnos[nombre, default: []].append(nota) // Agrega la nota al array del alumno (lo crea vacío si no existía)
    }
}

print("\n\(sep)") // Imprime salto de línea + separador
print(" PROMEDIO POR ALUMNO") // Imprime título de la sección de promedios
print(sep) // Imprime separador

var promedios: [String: Double] = [:] // Diccionario que guardará el promedio ya calculado de cada alumno

for (nombre, notas) in alumnos { // Recorre cada alumno junto con su array de notas
    let promedio = notas.reduce(0, +) / Double(notas.count) // Suma todas las notas y divide entre la cantidad (promedio)
    promedios[nombre] = promedio // Guarda el promedio calculado en el diccionario de promedios

    var categoria = "" // Variable donde se guardará la clasificación del alumno
    switch promedio { // Evalúa en qué rango cae el promedio
    case 18...: categoria = "Excelente" // Si el promedio es 18 o más
    case 15..<18: categoria = "Bueno" // Si el promedio está entre 15 y 17.99
    case 13..<15: categoria = "Aprobado" // Si el promedio está entre 13 y 14.99
    default: categoria = "Desaprobado" // Cualquier otro caso (menor a 13)
    }

    print("Alumno: \(nombre) - Promedio: \(promedio) - \(categoria)") // Imprime el resultado del alumno actual
}

// ===== TODO 10: Estadísticas =====
print("\n\(sep)") // Imprime salto de línea + separador
print(" ESTADISTICAS GENERALES") // Imprime título de la sección de estadísticas
print(sep) // Imprime separador

let listaPromedios = Array(promedios.values) // Convierte los valores del diccionario de promedios en un array
let promedioGeneral = listaPromedios.reduce(0, +) / Double(listaPromedios.count) // Calcula el promedio de todos los promedios
let notaMasAlta = listaPromedios.max() ?? 0 // Obtiene el promedio más alto; si el array está vacío usa 0
let notaMasBaja = listaPromedios.min() ?? 0 // Obtiene el promedio más bajo; si el array está vacío usa 0
let totalAprobados = listaPromedios.filter { $0 >= 13 }.count // Cuenta cuántos promedios son 13 o más (aprobados)
let porcentajeAprobados = Double(totalAprobados) / Double(listaPromedios.count) * 100 // Calcula el % de aprobados

print("Promedio general: \(promedioGeneral)") // Imprime el promedio general de la clase
print("Nota más alta: \(notaMasAlta)") // Imprime el promedio más alto entre todos los alumnos
print("Nota más baja: \(notaMasBaja)") // Imprime el promedio más bajo entre todos los alumnos
print("Porcentaje de aprobados: \(porcentajeAprobados)%") // Imprime el porcentaje de alumnos aprobados

// ===== TODO 11: Ordenar por promedio =====
print("\n\(sep)") // Imprime salto de línea + separador
print(" RANKING POR PROMEDIO") // Imprime título de la sección de ranking
print(sep) // Imprime separador

let ranking = promedios.sorted { $0.value > $1.value } // Ordena los pares (nombre, promedio) de mayor a menor promedio

for (nombre, promedio) in ranking { // Recorre el ranking ya ordenado
    print("\(nombre): \(promedio)") // Imprime el nombre y promedio de cada alumno en orden
}