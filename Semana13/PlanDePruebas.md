# Plan de pruebas — Lab 13

Ejecutado contra el simulador fijo iPhone 18 Pro (`63F4BBC7-A04D-4782-8ABC-0E07E76C4095`, iOS 27.2) con `xcodebuild test`. Todas las pruebas pasaron (0 fallas) en la ultima ejecucion.

## Actividad 1 — `Semana13_ConsumoAPI`

### `filteredUsers` (caja negra: particion de equivalencia)

| # | Caso | Clase/valor limite cubierto | Resultado esperado | Resultado obtenido |
|---|------|------------------------------|---------------------|---------------------|
| 1 | `searchText` vacio | Particion: texto vacio | Devuelve todos los usuarios | OK |
| 2 | `searchText` sin coincidencias | Particion: sin coincidencias | Lista vacia | OK |
| 3 | `searchText` coincide con `name` de un usuario | Particion: coincidencia unica por name | Esa unica fila | OK |
| 4 | `searchText` coincide con `username` (no `name`) | Particion: coincidencia unica por username | Esa unica fila | OK |
| 5 | `searchText` coincide con varios usuarios | Particion: coincidencia multiple | Todas las coincidencias, ninguna de mas | OK |
| 6 | Mismo texto en mayus/minus mezcladas | Valor limite: sensibilidad a mayusculas | Mismo resultado que en minusculas | OK |

### `fetchUsers()` con `SesionDeRedSimulada`

| # | Caso | Clase/valor limite cubierto | Resultado esperado | Resultado obtenido |
|---|------|------------------------------|---------------------|---------------------|
| 7 | Respuesta exitosa, JSON valido (3 usuarios) | Particion: respuesta exitosa | `users` queda con esos 3 usuarios | OK |
| 8 | Error de red simulado | Particion: fallo de red | `users` vacio, sin crash | OK |
| 9 | JSON corrupto/no decodificable | Valor limite: payload invalido con status exitoso | `users` no se actualiza, sin crash | OK |

### Integracion (API real)

| # | Caso | Resultado esperado | Resultado obtenido |
|---|------|---------------------|---------------------|
| 10 | `fetchUsers()` real contra jsonplaceholder | Lista no vacia; primer usuario con `id`, `name`, `email` no vacios | OK |

### UI (`BusquedaUITests`)

| # | Caso | Resultado esperado | Resultado obtenido |
|---|------|---------------------|---------------------|
| 11 | Lista tras cargar | Al menos una fila visible | OK |
| 12 | Busqueda sin coincidencias | Aparece el estado vacio ("Sin resultados") | OK |
| 13 | Busqueda con coincidencia ("Leanne") | La lista se reduce a esa fila | OK |

**Subtotal Actividad 1: 13 pruebas, 13 OK, 0 fallas.**

## Actividad 2 — `Semana13_MetodosAPI` (CRUD)

> Nota: `UserViewModel` de `MetodosAPI` ya habia sido migrado por completo a `async`/`await` en el prompt de desarrollo (no quedo una ruta `dataTask` separada en produccion). Los casos de CRUD de este bloque y los de regresion de la Actividad 3 ejercitan, por lo tanto, la misma implementacion `async` — ver la nota en `UserViewModelTests.swift`.

### CRUD con `SesionDeRedSimulada` (caja negra: valores limite en codigos de respuesta)

| # | Caso | Clase/valor limite cubierto | Resultado esperado | Resultado obtenido |
|---|------|------------------------------|---------------------|---------------------|
| 1 | `fetchUsers()` con 200 y JSON valido | Valor limite: codigo exitoso 200 | `users` se llena correctamente | OK |
| 2 | `addUser(_:)` con 201 | Valor limite: codigo exitoso de creacion 201 | El usuario nuevo se agrega a `users` | OK |
| 3 | `addUser(_:)` con error simulado | Particion: respuesta de error | `users` no cambia | OK |
| 4 | `updateUser(_:)` con 200 | Valor limite: codigo exitoso 200 | Se actualiza el usuario correcto por `id` (no el primero) | OK |
| 5 | `deleteUser(_:)` con 200 | Valor limite: codigo exitoso 200 | El usuario desaparece de `users` | OK |
| 6 | Verbo HTTP y URL por metodo | Particion: GET/POST/PUT/DELETE, `/users` vs `/users/{id}` | Cada metodo usa el verbo y la URL correctos | OK |

### Validacion de formulario (`formularioEsValido`, caja negra: particion de equivalencia + valores limite)

| # | Caso | Clase/valor limite cubierto | Resultado esperado | Resultado obtenido |
|---|------|------------------------------|---------------------|---------------------|
| 7 | Los 3 campos vacios | Particion: todo vacio | Invalido | OK |
| 8 | Nombre vacio, resto lleno | Particion: un campo vacio | Invalido | OK |
| 9 | Todos los campos con contenido | Particion: todo lleno | Valido | OK |
| 10 | Campo con solo espacios (`" "`) | Valor limite: ni vacio ni contenido real | Invalido (se recorta con `trimmingCharacters` antes de evaluar) | OK |

**Subtotal CRUD + validacion: 10 pruebas, 10 OK, 0 fallas.**

## Actividad 3 — Regresion `async`/`await` vs Actividad 2 (`UserViewModelAsyncTests`)

| # | Caso | Resultado esperado | Resultado obtenido |
|---|------|---------------------|---------------------|
| 1 | `fetchUsers()` async | Mismo resultado que el caso 1 de Actividad 2 | OK |
| 2 | `addUser(_:)` async, 201 | Mismo resultado que el caso 2 | OK |
| 3 | `addUser(_:)` async, error | Mismo resultado que el caso 3 | OK |
| 4 | `updateUser(_:)` async, 200 | Mismo resultado que el caso 4 | OK |
| 5 | `deleteUser(_:)` async, 200 | Mismo resultado que el caso 5 | OK |

**Subtotal regresion: 5 pruebas, 5 OK, 0 fallas.**

## Integracion `MetodosAPI` (API real)

| # | Caso | Resultado esperado | Resultado obtenido |
|---|------|---------------------|---------------------|
| 1 | GET real `/users` | Status 200, body decodifica a `[User]` no vacio | OK |
| 2 | POST real `/users` | Status 201, body decodifica a `User` | OK |
| 3 | PUT real `/users/1` | Status 200 (el mock no persiste el cambio) | OK |
| 4 | DELETE real `/users/1` | Status 200 (el mock no persiste el cambio) | OK |

**Subtotal integracion MetodosAPI: 4 pruebas, 4 OK, 0 fallas.**

## UI `MetodosAPI` (`CrudUITests`)

| # | Caso | Resultado esperado | Resultado obtenido |
|---|------|---------------------|---------------------|
| 1 | Tocar boton agregar | Aparece el formulario (`.sheet`) con sus 3 campos | OK |
| 2 | Llenar formulario valido y guardar | La nueva fila aparece en la lista | OK |
| 3 | Deslizar una fila y tocar eliminar | La fila desaparece de la lista | OK |

**Subtotal UI MetodosAPI: 3 pruebas, 3 OK, 0 fallas.**

## Resumen general

| Proyecto | Unitarias | Integracion | UI | Total |
|----------|-----------|-------------|----|-------|
| Semana13_ConsumoAPI | 9 | 1 | 3 | 13 |
| Semana13_MetodosAPI | 15 (10 CRUD/validacion + 5 regresion) | 4 | 3 | 22 |
| **Total** | **24** | **5** | **6** | **35** |

**35 de 35 pruebas pasaron (0 fallas) en la ultima ejecucion contra el simulador fijo.**
