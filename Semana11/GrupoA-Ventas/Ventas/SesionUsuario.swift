//
//  SesionUsuario.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import Foundation

/// Unico punto donde se guarda quien inicio sesion mientras la app esta abierta (no se persiste entre lanzamientos).
final class SesionUsuario {

    static let shared = SesionUsuario()

    private init() {}

    var usuarioActual: Usuario?

    func cerrarSesion() {
        usuarioActual = nil
    }
}
