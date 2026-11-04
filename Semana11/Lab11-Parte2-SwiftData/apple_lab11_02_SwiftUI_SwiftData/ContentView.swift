// Desarrollado por: Diego Nina Malqui

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Alumno.apellido) private var alumnos: [Alumno]

    @State private var mostrarNuevoAlumno = false
    @State private var alumnoAEditar: Alumno?
    @State private var busqueda = ""

    private var alumnosFiltrados: [Alumno] {
        if busqueda.isEmpty {
            return alumnos
        }
        return alumnos.filter { $0.apellido.localizedCaseInsensitiveContains(busqueda) }
    }

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(alumnosFiltrados) { alumno in
                    NavigationLink {
                        VStack(alignment: .leading) {
                            Text("\(alumno.apellido), \(alumno.nombre) - DNI: \(alumno.dni)")
                            Text("Curso: \(alumno.curso?.nombre ?? "Sin curso")")
                            Button("Editar") {
                                alumnoAEditar = alumno
                            }
                            Button("Asignar Curso Demo") {
                                asignarCursoDemo(a: alumno)
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
            .searchable(text: $busqueda, prompt: "Buscar por apellido")
        } detail: {
            Text("Selecciona un alumno")
        }
    }

    private func deleteAlumnos(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(alumnosFiltrados[index])
        }
    }

    private func asignarCursoDemo(a alumno: Alumno) {
        let curso = Curso(nombre: "Moviles Avanzado")
        modelContext.insert(curso)
        alumno.curso = curso

        do {
            try modelContext.save()
        } catch {
            print("Error al asignar curso: \(error)")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Alumno.self, Curso.self], inMemory: true)
}
