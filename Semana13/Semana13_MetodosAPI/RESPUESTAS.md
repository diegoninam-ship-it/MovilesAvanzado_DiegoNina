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
