// Desarrollado por: Diego Nina Malqui

import SwiftUI
import SwiftData

struct EditarAlumnoView: View {
    @Bindable var alumno: Alumno
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Datos del alumno") {
                    TextField("Apellido", text: $alumno.apellido)
                    TextField("Nombre", text: $alumno.nombre)
                    TextField("DNI", text: $alumno.dni)
                }
            }
            .navigationTitle("Editar Alumno")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    EditarAlumnoView(alumno: Alumno(apellido: "Perez", nombre: "Juan", dni: "12345678"))
        .modelContainer(for: Alumno.self, inMemory: true)
}
