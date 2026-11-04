// Desarrollado por: Diego Nina Malqui

import Foundation
import SwiftData

@MainActor
class ModelContainerProvider {
    static let shared = ModelContainerProvider()

    let container: ModelContainer

    private init() {
        let schema = Schema([Alumno.self, Curso.self])
        let configuracion = ModelConfiguration(
            "AlumnosData",
            schema: schema,
            url: URL.applicationSupportDirectory.appending(path: "AlumnosData.sqlite")
        )

        do {
            container = try ModelContainer(for: schema, configurations: [configuracion])
            print("Base de datos SQLite en: \(URL.applicationSupportDirectory.appending(path: "AlumnosData.sqlite"))")
        } catch {
            fatalError("No se pudo crear el ModelContainer: \(error)")
        }
    }
}
