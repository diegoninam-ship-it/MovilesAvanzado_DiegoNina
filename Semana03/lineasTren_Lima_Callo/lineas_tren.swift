enum EstadoLinea: Equatable {
    case operativa
    case enConstruccion
    case proyectada
}

struct Linea {
    let identificador: String
    let estaciones: [String]
    let estado: EstadoLinea
}

struct Correspondencia {
    let lineaA: String
    let lineaB: String
    let estacionA: String   // nombre de la estación en lineaA
    let estacionB: String   // nombre de la estación en lineaB (puede ser distinto)
    let estado: EstadoLinea
}

let lineas: [Linea] = [
    Linea(
        identificador: "Línea 1",
        estaciones: [
            "Villa El Salvador", "Parque Industrial", "Pumacahua", "Villa María",
            "María Auxiliadora", "San Juan", "Atocongo", "Jorge Chávez", "Ayacucho",
            "Cabitos", "Angamos", "San Borja Sur", "La Cultura", "Arriola", "Gamarra",
            "Miguel Grau", "El Ángel", "Presbítero Maestro", "Caja de Agua",
            "Pirámide del Sol", "Los Jardines", "Los Postes", "San Carlos",
            "San Martín", "Santa Rosa", "Bayóvar"
        ],
        estado: .operativa
    ),
    Linea(
        identificador: "Línea 2",
        estaciones: [
            "Puerto del Callao", "Buenos Aires", "Juan Pablo II", "Insurgentes",
            "Carmen de La Legua", "Óscar R. Benavides", "San Marcos", "Elio",
            "La Alborada", "Tingo María", "Parque Murillo", "Plaza Bolognesi",
            "Estación Central", "Plaza Manco Cápac", "Cangallo", "28 de Julio",
            "Nicolás Ayllón", "Circunvalación", "San Juan de Dios", "Evitamiento",
            "Óvalo Santa Anita", "Colectora Industrial", "Hermilio Valdizán",
            "Mercado Santa Anita", "Vista Alegre", "Prolongación Javier Prado",
            "Municipalidad de Ate"
        ],
        estado: .enConstruccion
    ),
    Linea(identificador: "Línea 3", estaciones: [], estado: .proyectada),
    Linea(identificador: "Línea 4", estaciones: [], estado: .proyectada),
    Linea(identificador: "Línea 5", estaciones: [], estado: .proyectada),
    Linea(identificador: "Línea 6", estaciones: [], estado: .proyectada)
]

let correspondencias: [Correspondencia] = [
    Correspondencia(
        lineaA: "Línea 1",
        lineaB: "Línea 2",
        estacionA: "Gamarra",
        estacionB: "28 de Julio",
        estado: .proyectada
    )
]


enum ResultadoConsultaLinea {
    case estaciones([String])
    case sinEstacionesRegistradas
    case lineaNoRegistrada
}

func estacionesDeLinea(_ identificadorIngresado: String) -> ResultadoConsultaLinea {
    let identificador = identificadorIngresado.trimmingCharacters(in: .whitespacesAndNewlines)

    guard let linea = lineas.first(where: {
        $0.identificador.compare(identificador, options: .caseInsensitive) == .orderedSame
    }) else {
        return .lineaNoRegistrada
    }

    if linea.estaciones.isEmpty {
        return .sinEstacionesRegistradas
    }

    return .estaciones(linea.estaciones)
}

func mensajeParaConsultaLinea(_ identificador: String) -> String {
    switch estacionesDeLinea(identificador) {
    case .estaciones(let estaciones):
        return "\(identificador) → \(estaciones.joined(separator: ", "))"
    case .sinEstacionesRegistradas:
        return "\(identificador) está registrada pero aún no tiene estaciones definidas (proyecto en fase de planificación)."
    case .lineaNoRegistrada:
        return "La línea \"\(identificador)\" no está registrada."
    }
}

enum ResultadoConsultaCorrespondencia {
    case encontrada(Correspondencia)
    case sinCorrespondencia
    case mismaLinea
    case lineaNoRegistrada(String)
}

func correspondenciaEntre(_ lineaIngresadaA: String, _ lineaIngresadaB: String) -> ResultadoConsultaCorrespondencia {
    let idA = lineaIngresadaA.trimmingCharacters(in: .whitespacesAndNewlines)
    let idB = lineaIngresadaB.trimmingCharacters(in: .whitespacesAndNewlines)

    guard let lineaA = lineas.first(where: {
        $0.identificador.compare(idA, options: .caseInsensitive) == .orderedSame
    }) else {
        return .lineaNoRegistrada(idA)
    }

    guard let lineaB = lineas.first(where: {
        $0.identificador.compare(idB, options: .caseInsensitive) == .orderedSame
    }) else {
        return .lineaNoRegistrada(idB)
    }

    if lineaA.identificador == lineaB.identificador {
        return .mismaLinea
    }

    if let correspondencia = correspondencias.first(where: {
        ($0.lineaA == lineaA.identificador && $0.lineaB == lineaB.identificador) ||
        ($0.lineaA == lineaB.identificador && $0.lineaB == lineaA.identificador)
    }) {
        return .encontrada(correspondencia)
    }

    return .sinCorrespondencia
}

func mensajeParaCorrespondencia(_ lineaA: String, _ lineaB: String) -> String {
    switch correspondenciaEntre(lineaA, lineaB) {
    case .encontrada(let correspondencia):
        let estadoTexto: String
        switch correspondencia.estado {
        case .operativa: estadoTexto = "operativa"
        case .enConstruccion: estadoTexto = "en construcción"
        case .proyectada: estadoTexto = "proyectada, aún no operativa"
        }
        return "\(correspondencia.lineaA) + \(correspondencia.lineaB) → \(correspondencia.estacionA) (en \(correspondencia.lineaA)) conecta con \(correspondencia.estacionB) (en \(correspondencia.lineaB)) — correspondencia \(estadoTexto)."
    case .sinCorrespondencia:
        return "No se encontró una estación de correspondencia entre las líneas seleccionadas."
    case .mismaLinea:
        return "Debes ingresar dos líneas distintas para consultar una correspondencia."
    case .lineaNoRegistrada(let id):
        return "La línea \"\(id)\" no está registrada."
    }
}


print(mensajeParaCorrespondencia("Línea 1", "Línea 2"))   // con correspondencia (proyectada)
print(mensajeParaCorrespondencia("Línea 2", "Línea 1"))   // mismo caso, orden invertido
print(mensajeParaCorrespondencia("Línea 3", "Línea 4"))   // sin correspondencia
print(mensajeParaCorrespondencia("Línea 1", "Línea 1"))   // misma línea
print(mensajeParaCorrespondencia("Línea 1", "Línea 9"))   // línea inexistente
print(mensajeParaCorrespondencia("", "Línea 2"))          // entrada inválida


var pruebasFallidas = 0

func verificar(_ descripcion: String, _ condicion: Bool) {
    if condicion {
        print("✅ \(descripcion)")
    } else {
        print("❌ \(descripcion)")
        pruebasFallidas += 1
    }
}

// RF-01: línea existente
if case .estaciones(let estaciones) = estacionesDeLinea("Línea 1") {
    verificar("Línea 1 devuelve 26 estaciones", estaciones.count == 26)
} else {
    verificar("Línea 1 devuelve estaciones", false)
}

// RF-01: línea inexistente
if case .lineaNoRegistrada = estacionesDeLinea("Línea 9") {
    verificar("Línea 9 no está registrada", true)
} else {
    verificar("Línea 9 no está registrada", false)
}

// RF-01: línea registrada sin estaciones (proyectada)
if case .sinEstacionesRegistradas = estacionesDeLinea("Línea 3") {
    verificar("Línea 3 registrada sin estaciones", true)
} else {
    verificar("Línea 3 registrada sin estaciones", false)
}

// RF-02: dos líneas con correspondencia
if case .encontrada(let c) = correspondenciaEntre("Línea 1", "Línea 2") {
    verificar("Correspondencia L1-L2 es Gamarra/28 de Julio", c.estacionA == "Gamarra" && c.estacionB == "28 de Julio")
} else {
    verificar("Correspondencia L1-L2 encontrada", false)
}

// RF-02: mismo resultado en orden invertido
if case .encontrada = correspondenciaEntre("Línea 2", "Línea 1") {
    verificar("Correspondencia L2-L1 (orden invertido) encontrada", true)
} else {
    verificar("Correspondencia L2-L1 (orden invertido) encontrada", false)
}

// RF-02: dos líneas sin correspondencia
if case .sinCorrespondencia = correspondenciaEntre("Línea 3", "Línea 4") {
    verificar("Línea 3 y Línea 4 sin correspondencia", true)
} else {
    verificar("Línea 3 y Línea 4 sin correspondencia", false)
}

// RF-02: línea consigo misma
if case .mismaLinea = correspondenciaEntre("Línea 1", "Línea 1") {
    verificar("Línea 1 consigo misma detectada como caso inválido", true)
} else {
    verificar("Línea 1 consigo misma detectada como caso inválido", false)
}

// RF-02: entrada inválida
if case .lineaNoRegistrada = correspondenciaEntre("", "Línea 2") {
    verificar("Entrada vacía detectada como línea no registrada", true)
} else {
    verificar("Entrada vacía detectada como línea no registrada", false)
}

print("\nResumen: \(pruebasFallidas == 0 ? "todas las pruebas pasaron" : "\(pruebasFallidas) prueba(s) fallaron")")