//
//  ClienteModel.swift
//  lab06_02
//
//  Created by Tecsup on 30/09/26.
//

import UIKit

class ClienteModel: NSObject {
    var Codigo: Int32=0
    var Apellido:String=""
    var Nombre: String=""
    var Dni: String=""

    override init() {
        self.Codigo = 0
        self.Apellido = ""
        self.Nombre = ""
        self.Dni = ""
    }

    init(Codigo: Int32, Apellido: String, Nombre: String, Dni: String) {
        self.Codigo = Codigo
        self.Apellido = Apellido
        self.Nombre = Nombre
        self.Dni = Dni
    }
}
