enum EstadoLinea {
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