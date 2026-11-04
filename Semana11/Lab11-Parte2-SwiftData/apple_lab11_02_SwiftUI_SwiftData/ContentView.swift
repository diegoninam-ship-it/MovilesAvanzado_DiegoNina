// Desarrollado por: Diego Nina Malqui

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Alumno.apellido) private var alumnos: [Alumno]

    @State private var mostrarNuevoAlumno = false
    @State private var alumnoAEditar: Alumno?

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(alumnos) { alumno in
                    NavigationLink {
                        VStack(alignment: .leading) {
                            Text("\(alumno.apellido), \(alumno.nombre) - DNI: \(alumno.dni)")
                            Button("Editar") {
                                alumnoAEditar = alumno
                            }
                        }
                    } label: {
                        Text("\(alumno.apellido), \(alumno.nombre)")
                    }
                }
                .onDelete(perform: deleteAlumnos)
            }
            .navigationTitle("Alumnos")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("Nuevo Alumno", systemImage: "plus") {
                        mostrarNuevoAlumno = true
                    }
                }
            }
            .sheet(isPresented: $mostrarNuevoAlumno) {
                NuevoAlumnoView()
            }
            .sheet(item: $alumnoAEditar) { alumno in
                EditarAlumnoView(alumno: alumno)
            }
        } detail: {
            Text("Selecciona un alumno")
        }
    }

    private func deleteAlumnos(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(alumnos[index])
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Alumno.self], inMemory: true)
}
