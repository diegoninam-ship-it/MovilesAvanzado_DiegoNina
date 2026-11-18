//
//  PersistenceController.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import CoreData

/// Contenedor Core Data compartido por toda la app (patron singleton).
final class PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    /// `inMemory` permite usar un store en memoria para los tests unitarios, sin tocar datos reales.
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Ventas")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("No se pudo cargar Core Data: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    func guardar() {
        guard viewContext.hasChanges else { return }
        do {
            try viewContext.save()
        } catch {
            fatalError("Error al guardar el contexto: \(error)")
        }
    }
}
