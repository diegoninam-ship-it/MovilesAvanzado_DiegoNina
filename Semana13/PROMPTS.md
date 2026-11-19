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

## Prompt 3: Plan de pruebas

### CTRFE

- **Contexto:** Tercer prompt sobre Lab 13, ejecutado despues del desarrollo funcional y del rediseño visual, sobre los mismos dos proyectos ya funcionales (`Semana13_ConsumoAPI` y `Semana13_MetodosAPI`, este ultimo ya migrado a `async`/`await`).
- **Tarea:** Cubrir las 3 actividades con pruebas unitarias, de integracion y de UI (XCUITest), aplicando caja negra (particion de equivalencia y valores limite) en la validacion de campos y de busqueda. Como paso previo indispensable, inyectar una abstraccion minima de `URLSession` (`SesionDeRed`) en `UserViewModel` para poder sustituirla por un doble de prueba (`SesionDeRedSimulada`) sin tocar el comportamiento real.
- **Restricciones:** Un commit por checkpoint, sin `git push`, sin tocar `RESPUESTAS.md`/`PROMPTS.md` previos ni otras semanas, y sin introducir patrones o capas mas alla del minimo necesario para que las pruebas sean deterministas.
- **Formato esperado:** Ocho checkpoints (inyeccion de sesion, doble de prueba, pruebas unitarias por proyecto, pruebas de regresion async vs dataTask, pruebas de integracion contra la API real, pruebas de UI, y reporte/documentacion final), cada uno compilado y ejecutado contra el simulador fijo antes de su commit.
- **Entregable:** Ocho commits locales en `main`, dos targets de pruebas unitarias y dos de UI Testing nuevos (uno de cada tipo por proyecto), 35 pruebas en total (24 unitarias, 5 de integracion, 6 de UI) y este `PlanDePruebas.md`.

### Reflexión: qué hizo distinto la IA

El reto tecnico principal no fue escribir las pruebas sino crear los cuatro targets de pruebas nuevos (dos unitarios, dos de UI Testing) editando directamente `project.pbxproj`, ya que no habia acceso a la interfaz grafica de Xcode para usar "Add Target". Claude Code escribió un generador que replica la estructura que Xcode genera normalmente (PBXNativeTarget, PBXTargetDependency/PBXContainerItemProxy hacia el target de la app, build settings de `TEST_HOST`/`BUNDLE_LOADER` o `TEST_TARGET_NAME` segun el tipo) y lo verificó corriendo `xcodebuild test` real contra el simulador fijo despues de cada cambio, no solo compilando. Ese proceso de verificación expuso y corrigió dos fallos reales de la primera versión del generador: el array `targets` del `PBXProject` no se actualizaba correctamente al agregar el segundo target por proyecto (bug de reemplazo de texto que solo coincidía la primera vez), y los targets de UI Testing no quedaban registrados como "testables" hasta agregar el atributo `TestTargetID` en `TargetAttributes`, algo que Xcode genera automáticamente desde la UI pero que no es obvio al editar el archivo a mano. También se detectó en la práctica que encadenar `.accessibilityIdentifier` después de `.searchable(...)` no llega al campo de búsqueda real (SwiftUI no expone ese enlace), por lo que las pruebas de UI usan `app.searchFields.firstMatch` en su lugar, y se dejó documentado por qué los Checkpoints 4 y 5 terminan probando la misma implementación `async`/`await`: `MetodosAPI` ya no tenía una ruta `dataTask` en producción desde el prompt de desarrollo, y la regla de este prompt prohibía reintroducirla solo para tener dos caminos que comparar.
