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

    func probarRelacion() {
        let contexto = conexion()

        let grupo = NSEntityDescription.insertNewObject(forEntityName: "Grupo", into: contexto) as! Grupo
        grupo.nombre = "Familia"

        if let contacto = contactos.first {
            contacto.grupo = grupo
        }

        do {
            try contexto.save()
        } catch {
            print("Error al probar relacion: \(error)")
        }
    }

    func contactosDelGrupo(_ grupo: Grupo) -> [Contacto] {
        let conjunto = grupo.contactos as? Set<Contacto> ?? []
        return conjunto.sorted { ($0.nombre ?? "") < ($1.nombre ?? "") }
    }

}
