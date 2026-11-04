// Desarrollado por: Diego Nina Malqui

import SwiftUI
import SwiftData

@main
struct apple_lab11_02_SwiftUI_SwiftDataApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(ModelContainerProvider.shared.container)
    }
}
