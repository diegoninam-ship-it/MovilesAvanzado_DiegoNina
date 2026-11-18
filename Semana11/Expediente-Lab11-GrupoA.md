# Expediente del Trabajo de la Semana — Laboratorio 11
## Grupo A · Caso Ventas (UIKit + Core Data)

**Curso:** Programación en Móviles Avanzado — Tecsup
**Docente:** Juan Leon

---

## 1. Integrantes y caso

- **Integrante:** Diego Nina Malqui
- **Grupo:** A
- **Nombre de la app:** Ventas

---

## 2. Modelo de datos

### Entidades, atributos y tipos

| Entidad | Atributos | Tipo |
|---|---|---|
| **Usuario** | nombre, usuario, clave | String |
| | rol | String ("Vendedor" o "Supervisor") |
| **Producto** | nombre, categoria | String |
| | precio | Double |
| | stock | Int |
| **Cliente** | nombre, documento | String |
| **Venta** | fecha | Date |
| | cantidad | Int |
| | precioUnitario, descuento, igv, total | Double |
| | anulada | Bool |
| | motivoAnulacion | String (opcional) |

### Relaciones y delete rules

Todas las relaciones son 1 a N desde Usuario/Producto/Cliente hacia Venta. Las tres usan **Deny** como delete rule: Core Data impide borrar un Usuario, Producto o Cliente mientras tenga al menos una Venta asociada, en línea con la regla de negocio de borrado.

| Relación | Desde | Hacia | Tipo | Delete Rule |
|---|---|---|---|---|
| ventas | Usuario | Venta | To Many | Deny |
| ventas | Producto | Venta | To Many | Deny |
| ventas | Cliente | Venta | To Many | Deny |
| vendedor | Venta | Usuario | To One | — |
| producto | Venta | Producto | To One | — |
| cliente | Venta | Cliente | To One | — |

### Dibujo de cajas y flechas

```
┌────────────┐
│  Usuario   │◄──────────┐ vendedor (1 a N, Deny)
│ (Vendedor/ │           │
│ Supervisor)│           │
└────────────┘           │
                          │
┌────────────┐           │        ┌───────────────┐
│  Producto  │◄──────────┼────────┤     Venta     │
│            │ producto  │        │ fecha, cantidad,│
└────────────┘ (1 a N,   │        │ precioUnitario, │
               Deny)     │        │ descuento, igv, │
┌────────────┐           │        │ total, anulada, │
│  Cliente   │◄──────────┘        │ motivoAnulacion │
│            │ cliente            └───────────────┘
└────────────┘ (1 a N, Deny)
```

*(Boceto en texto; se puede redibujar a mano o con el Core Data Model Editor de Xcode para la entrega física si el docente lo pide.)*

---

## 3. Roles y permisos

### Pestañas por rol

| Rol | Pestañas (UITabBarController) |
|---|---|
| **Vendedor** | Productos, Clientes, Venta, Mis ventas, Cuenta |
| **Supervisor** | Resumen, Ventas, Productos, Clientes, Cuenta |

### Qué puede hacer cada rol

| Sección | Vendedor | Supervisor |
|---|---|---|
| Productos | Solo consultar y buscar | Crear, editar y borrar |
| Clientes | Crear, editar y consultar | Crear, editar, consultar y borrar |
| Ventas | Registrar y ver solo las suyas (predicate por vendedor) | Ver todas, filtrar por vendedor y anular con motivo |
| Resumen | No lo ve (pestaña ausente) | Panel con indicadores, gráfico y ranking |
| Cuenta | Nombre, usuario, rol y botón Cerrar sesión | Nombre, usuario, rol y botón Cerrar sesión |

Cada venta guarda quién la registró (relación `vendedor: To One ▸ Usuario`), lo que permite tanto el filtro "ver solo las suyas" del Vendedor como el filtro "por vendedor" del Supervisor.

---

## 4. Reglas de negocio

**1. Categoría del cliente** (calculada, no guardada) — Regular si lo comprado (ventas no anuladas) es menor a S/ 1,000; Frecuente desde S/ 1,000; VIP desde S/ 5,000.
Ejemplo: cliente con S/ 5,200.00 en ventas no anuladas → categoría **VIP**.

**2. Descuento** — VIP recibe 10 % del subtotal; los demás 0 %.
Ejemplo: 2 Laptop a S/ 200.00 a cliente VIP → subtotal = 400.00 → descuento = 400.00 × 0.10 = **S/ 40.00**.

**3. IGV** — 18 % sobre (subtotal − descuento).
Ejemplo (mismo caso): base = 400.00 − 40.00 = 360.00 → igv = 360.00 × 0.18 = **S/ 64.80**.

**4. Total** — subtotal − descuento + igv.
Ejemplo (mismo caso): total = 400.00 − 40.00 + 64.80 = **S/ 424.80**.

**5. Stock** — al registrar una venta baja el stock; si la cantidad supera el stock, se muestra una alerta y no se registra.
Ejemplo: stock de Laptop 40 → tras vender 2 → **38**. Intento de vender 50 con stock 40 → se bloquea, stock queda en **40**.

**6. Anulación** (solo Supervisor) — exige motivo obligatorio, marca anulada, devuelve stock, deja de contar en reportes y en la categoría del cliente.
Ejemplo: se anula la venta del punto 2-4 (S/ 424.80, 2 Laptop) → stock vuelve a **40**; el resumen baja en **S/ 424.80**; sin motivo, el botón Anular está deshabilitado.

**7. Visibilidad** — el Vendedor solo ve sus propias ventas (predicate `vendedor == %@`); el Supervisor ve todas.
Ejemplo: "jperez" con 3 ventas de un total de 10 → su pantalla "Mis ventas" muestra **3**; "Ventas" del Supervisor muestra **10**.

**8. Borrado** (delete rule Deny) — no se puede borrar un Producto, Cliente o Usuario con ventas asociadas.
Ejemplo: "Laptop" con 5 ventas → el Supervisor intenta borrarlo → Core Data lo deniega con una alerta.

---

## 5. Pantallas

| Pant. | Propósito | Qué dato lee | Qué dato escribe |
|---|---|---|---|
| **A1 — Login** | Autenticar al usuario y dar acceso a la app o a Registro | usuario, clave ingresados (comparados contra Usuario) | Nada (solo valida) |
| **A2 — Registro** | Crear una cuenta nueva y entrar directo a la app | nombre completo, usuario, clave, confirmación, rol | Nuevo registro Usuario |
| **A3 — Productos** | Consultar/gestionar catálogo, con stock en color y filtro por categoría | lista de Producto (predicate de búsqueda/categoría) | Supervisor: crear, editar, borrar Producto |
| **A4 — Clientes** | Consultar/gestionar clientes con su categoría y total comprado | lista de Cliente + ventas no anuladas (para calcular categoría/total) | Crear/editar Cliente (ambos roles); borrar (solo Supervisor) |
| **A5 — Nueva Venta** | Registrar una venta con cálculo en vivo | Cliente, Producto (stock disponible), vendedor de sesión | Nuevo registro Venta; baja de stock del Producto |
| **A6 — Mis Ventas** | El Vendedor ve y filtra sus propias ventas | ventas donde vendedor == usuario de sesión | Nada (solo consulta/búsqueda) |
| **A7 — Ventas (Supervisor)** | Ver todas las ventas, filtrar por vendedor, iniciar anulación | todas las Venta, filtradas por vendedor | Inicia flujo de anulación (navega a A8) |
| **A8 — Anular Venta** | Confirmar anulación con motivo obligatorio | datos de la Venta a anular | anulada = true, motivoAnulacion; devuelve stock al Producto |
| **A9 — Resumen (Supervisor)** | Panel de indicadores, gráfico y ranking | agregados de Venta (hoy/mes, por vendedor) y stock bajo de Producto | Nada (solo consulta) |

*(Pestaña Cuenta, ambos roles: nombre, usuario, rol y botón Cerrar sesión — no forma parte de las 9 pantallas numeradas pero está requerida.)*

---

## 6. Casos de prueba

| N.º | Caso | Resultado esperado |
|---|---|---|
| 1 | Registrar a "lparedes" como Supervisor e intentar registrar otro "LPAREDES" | Se crea el primero y entra a la app; el segundo se rechaza por usuario repetido |
| 2 | Registrar con claves distintas o de 4 caracteres | Mensaje de error; no se crea el usuario |
| 3 | Login con clave incorrecta | Mensaje "Usuario o clave incorrectos"; no entra |
| 4 | Vendedor registra la venta de 2 Laptop a S/ 200.00 a un cliente VIP | Subtotal 400.00 · descuento 40.00 · IGV 64.80 · total 424.80 · stock 40 a 38 |
| 5 | Vendedor registra 3 Mouse de S/ 35.00 a un cliente Regular | Subtotal 105.00 · IGV 18.90 · total 123.90 |
| 6 | Venta de 50 unidades con stock 40 | Alerta y no se registra; el stock no cambia |
| 7 | Un vendedor abre Mis ventas | Solo aparecen sus ventas y ninguna fila permite Anular |
| 8 | El supervisor anula la venta del caso 4 sin escribir motivo, y luego con motivo | Sin motivo no se puede; con motivo queda anulada, el stock vuelve a 40 y el resumen baja en 424.80 |
| 9 | Borrar un cliente que tiene ventas | Se impide y se muestra un mensaje |
| 10 *(propio)* | Un cliente acumula exactamente S/ 1,000.00 en ventas no anuladas | Su categoría pasa de Regular a **Frecuente** (el umbral "desde S/ 1,000" es inclusivo) |
| 11 *(propio)* | El vendedor intenta registrar una venta con cantidad 0 o con el campo cantidad vacío | Se muestra una alerta de validación y la venta no se registra |

---

## 7. Plan de commits

| # | Commit | Etapa (cronograma) |
|---|---|---|
| 1 | `feat:` Modelo de datos Core Data (Usuario, Producto, Cliente, Venta) con relaciones y delete rules | Días 3-4 |
| 2 | `feat:` Registro de usuario con validación de usuario único (sin distinguir mayúsculas) y clave | Días 3-4 |
| 3 | `feat:` Login y manejo de sesión (usuario conectado mientras la app está abierta) | Días 3-4 |
| 4 | `feat:` UITabBarController con pestañas según rol | Días 3-4 |
| 5 | `feat:` Pantalla Productos (listar, buscar, chips de categoría; crear/editar/borrar para Supervisor) | Días 5-6 |
| 6 | `feat:` Pantalla Clientes (categoría y total calculados; crear/editar/borrar) | Días 5-6 |
| 7 | `feat:` Pantalla Nueva Venta (cálculo de subtotal, descuento, IGV, total; baja de stock) | Días 5-6 |
| 8 | `feat:` Pantalla Mis Ventas (Vendedor) | Días 5-6 |
| 9 | `feat:` Pantalla Ventas con filtro por vendedor y anulación con motivo (Supervisor) | Días 5-6 |
| 10 | `feat:` Pantalla Resumen con indicadores, gráfico de 7 días y ranking (Supervisor) | Días 5-6 |
| 11 | `feat:` AppIcon y Display Name "Ventas" | Días 5-6 |
| 12 | `docs:` PROMPTS.md con el registro de consultas a la IA | Días 5-6 |
| 13 | `test:` Verificación de los 11 casos de prueba en el simulador | Días 5-6 |

Regla recordatoria del propio laboratorio: commit y push al terminar cada pantalla — un solo commit final se considera trabajo no documentado.

---

## 8. Plan de uso de IA

**Qué se pedirá a la IA (rama `ia-asistida`):**
- Construcción de las entidades y relaciones de Core Data a partir del modelo ya definido en la Sección 2 de este expediente.
- Código de UI por programación (Auto Layout, tablas, formularios) para las 9 pantallas, siguiendo las leyendas de maqueta del laboratorio.
- Fetch requests con `NSPredicate` para los filtros (por vendedor, por categoría, por búsqueda).
- Implementación de las fórmulas de la Sección 4 (ya resueltas a mano aquí, para que la IA solo las traduzca a código, no las derive).
- Manejo del `UITabBarController` condicionado por rol.

**Qué se hará a mano (rama `manual`):**
- Este expediente completo (entidades, reglas, pantallas, casos de prueba, plan de commits), elaborado antes de abrir la IA.
- Verificación de que cada pantalla generada corresponda a la maqueta y a las reglas de negocio.
- Ejecución y comprobación de los 11 casos de prueba en el simulador.
- Preparación para la defensa oral: revisión línea por línea del código entregado, para poder explicarlo sin ayuda.

**Cómo se verificarán las respuestas de la IA:**
1. Compilación con `xcodebuild` tras cada checkpoint (BUILD SUCCEEDED como condición para continuar).
2. Instalación y apertura en el simulador, revisando que no truene (crash logs).
3. Comparación de los resultados contra los valores exactos ya calculados a mano en la Sección 4 y los 11 casos de la Sección 6.
4. Lectura y comprensión del código generado antes de aceptarlo, descartando o pidiendo ajuste de cualquier parte que no se pueda explicar en la defensa oral.

---

## 9. Visto bueno

- **Fecha:** 17/11/2026
- **Confirmación:** Visto bueno del docente obtenido previamente, según indicación del alumno.

---
