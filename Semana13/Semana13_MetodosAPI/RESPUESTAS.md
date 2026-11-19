# Respuestas — Actividad 2 (Semana13_MetodosAPI)

## ¿Cuál es la finalidad de `resume()`?

Las `URLSessionTask` (incluidas las `dataTask`) se crean en estado de pausa (`suspended`); no empiezan a ejecutarse solas. `resume()` es el método que efectivamente arranca la tarea de red, enviando la petición al servidor. Si se olvida llamar a `resume()`, la petición nunca sale y el closure de finalización jamás se ejecuta.

## ¿Qué función cumple `DispatchQueue`?

`DispatchQueue` administra colas de ejecución de código (GCD). Las respuestas de `URLSession` llegan en una cola en segundo plano, pero SwiftUI/UIKit solo permite actualizar la UI desde el hilo principal. Por eso cada método del `UserViewModel` envuelve la actualización de `@Published var users` en `DispatchQueue.main.async { ... }`: así se garantiza que el cambio de estado que repinta la vista ocurra en el hilo principal.

## ¿Qué función cumple `JSONDecoder()`?

`JSONDecoder()` convierte (deserializa) los datos binarios JSON (`Data`) que llegan del servidor en instancias de tipos Swift que cumplen `Codable`, como `User` o `[User]`. Internamente mapea cada clave del JSON a la propiedad correspondiente de la struct. De forma simétrica, `JSONEncoder()` hace el proceso inverso: convierte un `User` en `Data` JSON para enviarlo en el cuerpo de una petición POST/PUT.

## Explica: `@State private var editingUser: User? = nil`

Es una propiedad de estado local de la vista `ContentView`, de tipo opcional `User?`. Guarda el usuario que se está editando en ese momento: `nil` significa que no hay edición en curso (por ejemplo, se va a crear un usuario nuevo), y un valor no nulo significa que el formulario debe abrirse en modo edición con los datos de ese usuario precargados. Al ser `@State`, SwiftUI vuelve a evaluar la vista cuando cambia.

## Explica: `@StateObject private var viewModel = UserViewModel()`

`@StateObject` crea y es dueña (owns) la instancia del `UserViewModel` durante todo el ciclo de vida de `ContentView`, garantizando que no se vuelva a crear en cada refresco de la vista (a diferencia de una propiedad normal). Como `UserViewModel` es `ObservableObject`, SwiftUI se suscribe a sus `@Published` y refresca la vista automáticamente cuando `users` cambia.

## Explica: `.swipeActions`

Es un modificador de SwiftUI que agrega acciones deslizables a una fila de una `List`. En `ContentView` se usa para mostrar, al deslizar una fila, un botón de "Eliminar" (rol `.destructive`, que llama a `viewModel.deleteUser`) y un botón de "Editar" (que abre el formulario con `editingUser` ya asignado). Permite acciones rápidas por fila sin necesitar botones visibles todo el tiempo.

## Explica: `.sheet(isPresented: $showingForm)`

Es un modificador que presenta una vista modal (una "hoja" que sube desde abajo) cuando el binding booleano `showingForm` es `true`, y la oculta automáticamente cuando vuelve a `false` (por ejemplo, al llamar `dismiss()` dentro de `UserFormView`). En este proyecto se usa para mostrar `UserFormView`, reutilizando la misma hoja tanto para crear un usuario nuevo (`editingUser == nil`) como para editar uno existente.

## Diferencia entre `URLSession.shared.data` y `URLSession.shared.dataTask`

`dataTask(with:completionHandler:)` es la API clásica basada en callbacks: crea un `URLSessionDataTask` que hay que arrancar manualmente con `resume()`, y el resultado (datos, respuesta, error) se recibe en un closure que se ejecuta en una cola en segundo plano, por lo que cualquier actualización de UI requiere saltar explícitamente a `DispatchQueue.main`. `URLSession.shared.data(from:)` / `data(for:)` es la API moderna basada en `async/await`: es una función `async throws` que se "suspende" hasta que la petición termina, devuelve directamente la tupla `(Data, URLResponse)` o lanza un error, y no necesita `resume()` ni un closure anidado — el código se lee de forma secuencial aunque siga siendo asíncrono.

## ¿Para qué sirve `await`?

`await` marca el punto donde el código se suspende para esperar el resultado de una función `async` (por ejemplo `URLSession.shared.data(from:)`) sin bloquear el hilo en el que se ejecuta. Mientras se espera la respuesta de red, el hilo queda libre para hacer otro trabajo, y cuando la respuesta llega, la ejecución continúa justo después del `await` con el valor obtenido (o se lanza el error con `try`).

## ¿Para qué sirve la estructura `Task`?

`Task { ... }` crea una nueva tarea asíncrona y la lanza de inmediato, permitiendo llamar funciones `async` (como `fetchUsers()`, `addUser(_:)`, `updateUser(_:)` o `deleteUser(_:)`) desde un contexto síncrono, como la acción de un botón o `.onAppear` en SwiftUI, que por sí mismos no pueden usar `await` directamente. En `ContentView` cada acción del usuario (refrescar, crear, actualizar, eliminar) se envuelve en su propio `Task` para poder invocar el método `async` correspondiente del `UserViewModel`.
