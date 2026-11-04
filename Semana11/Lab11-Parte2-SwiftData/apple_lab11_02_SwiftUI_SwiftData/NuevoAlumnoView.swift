// Desarrollado por: Diego Nina Malqui

import SwiftUI
import SwiftData

struct NuevoAlumnoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var apellido = ""
    @State private var nombre = ""
    @State private var dni = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Datos del alumno") {
                    TextField("Apellido", text: $apellido)
                    TextField("Nombre", text: $nombre)
                    TextField("DNI", text: $dni)
                }
            }
            .navigationTitle("Nuevo Alumno")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar Alumno") {
                        guardarAlumno()
                    }
                    .disabled(apellido.isEmpty || nombre.isEmpty || dni.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func guardarAlumno() {
        let nuevoAlumno = Alumno(apellido: apellido, nombre: nombre, dni: dni)
        modelContext.insert(nuevoAlumno)

        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Error al guardar alumno: \(error)")
        }
    }
}

#Preview {
    NuevoAlumnoView()
        .modelContainer(for: Alumno.self, inMemory: true)
}
