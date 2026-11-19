# Respuestas — Actividad 1 (Semana13_ConsumoAPI)

## ¿Cuál es la función de `@Published`?

`@Published` es un property wrapper de Combine que convierte una propiedad en observable. Cada vez que su valor cambia, emite una notificación automática a cualquier vista SwiftUI que esté observando el `ObservableObject` (a través de `@StateObject` u `@ObservedObject`), provocando que esa vista se vuelva a renderizar con el nuevo valor. En `UserViewModel` se usa en `users`, de modo que cuando `fetchUsers()` actualiza la lista, `ContentView` se refresca sola sin necesidad de código adicional.

## ¿Qué hace `filteredUsers`?

`filteredUsers` es una propiedad computada del `UserViewModel` que devuelve la lista de usuarios a mostrar según el texto de búsqueda (`searchText`). Si `searchText` está vacío, retorna la lista completa (`users`); si tiene texto, filtra `users` dejando solo los que contienen ese texto en el `name` o en el `username`, de forma case-insensitive (`localizedCaseInsensitiveContains`). La vista consume siempre `filteredUsers` en lugar de `users` directamente, para que la búsqueda se refleje en tiempo real.
