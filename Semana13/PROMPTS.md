# Prompts — Lab 13

## Docente: Tecsup
## Herramienta: Claude Code

### CTRFE

- **Contexto:** Laboratorio 13 del curso Programación en Móviles Avanzado (Tecsup), formalmente en grupo de 2 pero desarrollado en solitario por Diego Nina Malqui, siguiendo la convención usada en labs anteriores del repositorio. El repo ya estaba clonado y configurado (Xcode 27.2, identidad de git local, simulador iPhone 18 Pro iOS 27.2). Trabajo sobre la rama `main`, en una carpeta nueva `Semana13/`.
- **Tarea:** Consumir la API pública `https://jsonplaceholder.typicode.com/users` desde dos apps SwiftUI con arquitectura MVVM (`Model/`, `View/`, `ViewModel/`): `Semana13_ConsumoAPI` (GET + búsqueda con `.searchable`) y `Semana13_MetodosAPI` (CRUD completo con `dataTask`, formulario, `.swipeActions`, `.sheet`, y luego refactor de todo el CRUD a `async/await`).
- **Restricciones:** Un commit por checkpoint (Conventional Commits en español), sin sobre-ingeniería más allá de lo que pide el enunciado (sin SOLID forzado ni patrones extra), sin `git push`, sin tocar otras semanas, compilar y probar en el simulador antes de cada commit, y sin tomar capturas de pantalla todavía (eso va en un prompt posterior, después del rediseño visual).
- **Formato esperado:** Siete checkpoints concretos (modelo y GET, búsqueda, estructura del segundo proyecto, CRUD con `dataTask`, formulario y gestos de UI, refactor a `async/await`, y documentación de cierre), cada uno con su propio mensaje de commit y, donde corresponde, su propio `RESPUESTAS.md` con las preguntas conceptuales del enunciado.
- **Entregable:** Siete commits locales en `main` dentro de `Semana13/`, con los dos proyectos Xcode compilando contra el simulador fijo, sus respectivos `RESPUESTAS.md`, y este `PROMPTS.md` junto con `Conclusiones.md`.

### Reflexión: qué hizo distinto la IA

A diferencia de simplemente pegar código de ejemplo, Claude Code generó ambos proyectos Xcode completos desde cero (incluyendo `project.pbxproj`, esquema y assets) usando como plantilla la estructura de un proyecto SwiftUI ya existente en el repositorio (`Semana08/Lab08SwiftUI`), en vez de depender de la interfaz gráfica de Xcode. Compiló con `xcodebuild` y lanzó cada checkpoint en el simulador fijo para detectar errores reales (por ejemplo, un error de compilación por `@Published` sin `import Combine`, que exige el modo `SWIFT_UPCOMING_FEATURE_MEMBER_IMPORT_VISIBILITY` habilitado por Xcode 27) antes de hacer cada commit, en vez de asumir que el código compilaba. También separó deliberadamente el checkpoint de `dataTask` del checkpoint de refactor a `async/await`, para que el historial de commits muestre la evolución pedida por el enunciado en lugar de entregar el resultado final de una sola vez.
