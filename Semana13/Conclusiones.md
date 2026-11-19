# Conclusiones — Lab 13

1. **Consumo de API:** Consumir una API REST real desde una app iOS se reduce, en esencia, a tres pasos repetibles: construir la `URLRequest` (URL, método, headers y body si aplica), decodificar la respuesta con `JSONDecoder`/codificarla con `JSONEncoder` contra structs `Codable`, y actualizar el estado observable en el hilo principal. Esa misma receta se aplicó igual para GET, POST, PUT y DELETE, cambiando solo el método HTTP y qué se hace con el resultado.

2. **MVVM:** Separar `Model`, `View` y `ViewModel` dejó las vistas (`ContentView`, `UserFormView`) enfocadas solo en mostrar datos y disparar acciones, mientras toda la lógica de red y de estado (filtrado, CRUD, manejo de errores) vivió en `UserViewModel` como `@Published`. Esto hizo que agregar la búsqueda o migrar a `async/await` fuera un cambio casi aislado al ViewModel, sin tocar la UI.

3. **`dataTask` vs `async/await`:** Ambas formas llaman a la misma `URLSession`, pero `async/await` elimina el anidamiento de closures y el salto manual a `DispatchQueue.main` para cada actualización de UI, haciendo que el código de red se lea de forma secuencial. El costo es que las funciones `async` solo se pueden llamar desde un contexto asíncrono, por lo que la UI necesita envolver cada acción en un `Task { }`.
