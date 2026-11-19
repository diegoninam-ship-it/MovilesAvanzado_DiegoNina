// Desarrollado por: Diego Nina Malqui

import Foundation

func formularioEsValido(nombre: String, username: String, correo: String) -> Bool {
    let nombreValido = !nombre.trimmingCharacters(in: .whitespaces).isEmpty
    let usuarioValido = !username.trimmingCharacters(in: .whitespaces).isEmpty
    let correoValido = !correo.trimmingCharacters(in: .whitespaces).isEmpty
    return nombreValido && usuarioValido && correoValido
}
