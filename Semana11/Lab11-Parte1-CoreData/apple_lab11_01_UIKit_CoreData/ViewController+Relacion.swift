// Desarrollado por: Diego Nina Malqui

import UIKit
import CoreData

extension ViewController {

    func buscarContactos(texto: String) -> [Contacto] {
        let contexto = conexion()
        let peticion: NSFetchRequest<Contacto> = Contacto.fetchRequest()
        peticion.predicate = NSPredicate(format: "nombre CONTAINS[cd] %@", texto)

        do {
            return try contexto.fetch(peticion)
        } catch {
            print("Error al buscar contactos: \(error)")
            return []
        }
    }

}
