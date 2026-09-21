// ===== CASO 2 — PARTE B: BIBLIOTECA (CON IA) =====

enum EstadoLibro { // define los dos estados posibles de un libro
    case disponible // el libro puede prestarse
    case prestado // el libro ya fue prestado
}

struct Libro { // struct: es un dato que se copia sin problema (valor)
    let titulo: String // identificador usado para buscar el libro
    let autor: String // solo se usa para mostrar en el inventario
    var estado: EstadoLibro = .disponible // todo libro nuevo empieza disponible
}

class Biblioteca { // class: debe ser una única instancia compartida (referencia)
    var libros: [Libro] = [] // colección mutable, empieza vacía

    func agregar(libro: Libro) { 
        libros.append(libro) 
    }

    func prestar(titulo: String) -> Bool { // intenta marcar un libro como prestado
        for i in 0..<libros.count { // recorre por índice para poder modificar el array
            if libros[i].titulo == titulo { // compara el título buscado con el del índice actual
                if libros[i].estado == .disponible { // solo se puede prestar si está disponible
                    libros[i].estado = .prestado // modifica el struct dentro del array directamente
                    print("Préstamo aprobado: \(titulo)") // confirma la operación
                    return true // corta el flujo con éxito
                } else {
                    print("Error: \(titulo) ya está prestado") // ya estaba prestado
                    return false // corta el flujo con fallo
                }
            }
        }
        print("Error: no existe \(titulo)") // el bucle terminó sin encontrar coincidencia
        return false // indica que no se pudo prestar
    }

    func devolver(titulo: String) -> Bool { // misma lógica que prestar, invertida
        for i in 0..<libros.count { // recorre por índice
            if libros[i].titulo == titulo { // encuentra el libro por título
                if libros[i].estado == .prestado { // solo se puede devolver si estaba prestado
                    libros[i].estado = .disponible // regresa el estado a disponible
                    print("Devolución registrada: \(titulo)") // confirma la operación
                    return true
                } else {
                    print("Error: \(titulo) ya está disponible") // ya estaba disponible
                    return false
                }
            }
        }
        print("Error: no existe \(titulo)") // no se encontró el libro
        return false
    }

    func inventario() { // imprime el estado de todos los libros
        print("===== INVENTARIO =====") // encabezado fijo
        for libro in libros { // aquí no se modifica nada, un for-in simple basta
            switch libro.estado { // switch exhaustivo sobre el enum
            case .disponible:
                print("\(libro.titulo) (\(libro.autor)) - disponible") // formato para disponible
            case .prestado:
                print("\(libro.titulo) (\(libro.autor)) - prestado") // formato para prestado
            }
        }
    }
}

let biblioteca = Biblioteca() // instancia única
biblioteca.agregar(libro: Libro(titulo: "Cien años de soledad", autor: "Gabriel García Márquez"))
biblioteca.agregar(libro: Libro(titulo: "La ciudad y los perros", autor: "Mario Vargas Llosa"))
biblioteca.agregar(libro: Libro(titulo: "El Quijote", autor: "Miguel de Cervantes"))

biblioteca.prestar(titulo: "La ciudad y los perros") // debe aprobarse
biblioteca.prestar(titulo: "La ciudad y los perros") // debe fallar, ya prestado
biblioteca.devolver(titulo: "La ciudad y los perros") // devuelve
biblioteca.prestar(titulo: "El Quijote") // presta otro libro
biblioteca.prestar(titulo: "El Principito") // debe fallar, no existe
biblioteca.inventario() // muestra el estado final