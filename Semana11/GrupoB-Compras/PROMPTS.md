# Prompts — Lab 11, Trabajo de la semana (Grupo B, extracurricular)

## Herramienta: Claude Code

## CTRFE

**Contexto:** Laboratorio 11 del curso (GLAB-S11-JLEONS-2026-02), caso Compras del Grupo B, construido como práctica extracurricular en el mismo repositorio donde ya vive la entrega evaluada del Grupo A (`Semana11/GrupoA-Ventas/`), sin tocarla.

**Tarea:** Construir desde cero, en `Semana11/GrupoB-Compras/`, una app iOS con SwiftUI + SwiftData (sin librerías externas) que modele el flujo de compras: registro/login, roles Comprador/Supervisor, catálogo de productos y proveedores, registro de una nueva compra con aprobación automática o manual según el monto, aprobación/rechazo con costo promedio ponderado, control de cuentas por pagar con detección de vencidas, y un resumen ejecutivo para el Supervisor.

**Rol:** Claude actuó como desarrollador Swift, escribiendo los 4 modelos `@Model`, las 10 vistas SwiftUI, la sesión `@Observable`, y los 9 casos de prueba con `ModelContainer` en memoria, siguiendo las convenciones de código ya usadas en el Grupo A (camelCase, `guard let`, `// MARK: -`, formato de moneda `S/. %.2f`).

**Formato:** Un commit de Conventional Commits en español por checkpoint, en el orden exacto indicado en el prompt original, verificando con `xcodebuild build` (y `xcodebuild test` en el checkpoint final) antes de cada commit.

**Ejemplos/Restricciones:** No se usaron librerías externas (solo SwiftUI y SwiftData). Las relaciones "To Many" (`Usuario.compras`, `Proveedor.compras`, `Producto.compras`) usan `deleteRule: .deny`, por lo que borrar un producto o proveedor con compras asociadas falla al guardar; la UI captura ese error con un `do/catch` + `rollback()` y muestra una alerta en vez de crashear. No se hizo `git push`; todos los commits quedaron locales en `ai-assisted`.

## Reflexión: qué hizo distinto la IA

- **Manejo del error `.deny`:** en vez de solo confiar en la relación para "proteger" los datos, se decidió explícitamente capturar el error de `modelContext.save()` con `try/catch`, hacer `modelContext.rollback()` para no dejar el contexto en un estado inconsistente, y traducir el error en un mensaje legible para el usuario ("tiene compras asociadas y no se puede eliminar") en lugar de dejar que SwiftData lance una excepción no controlada.
- **Barras del ranking sin librerías:** el ranking de "total comprado por proveedor" en `ResumenView` se dibuja con un `GeometryReader` + `RoundedRectangle` cuyo ancho es proporcional al máximo del conjunto (`item.total / maximoRanking`), replicando el mismo criterio simple que ya se usó en el gráfico de 7 días del Grupo A, sin tocar ninguna librería de charts.
- **Lógica de vencidas:** una compra a crédito se considera "Vencida" solo si **no** está pagada y su fecha `vence` ya pasó (`!compra.pagada && compra.vence < Date()`); esto se centralizó en una sola función `esVencida(_:)` dentro de `PorPagarView` para que el segmented control (Pendientes/Vencidas/Pagadas) y la etiqueta "VENCIDA" en cada fila usen siempre el mismo criterio y no se desincronicen.
- **`FetchDescriptor` + variable intermedia para predicados:** siguiendo el patrón pedido en el enunciado, antes de usar un valor dentro de un `#Predicate` (el texto de usuario en minúsculas, el `Usuario` de sesión) se guarda primero en una constante local (`usuarioTexto`, `usuarioDeSesion`) porque el macro `#Predicate` no puede capturar expresiones computadas directamente.
- **Aprobación automática vs. manual en el mismo flujo:** `NuevaCompraView` calcula el total en vivo y decide en el momento de guardar si la compra queda `Aprobada` (aplicando de inmediato stock y costo promedio ponderado) o `Pendiente` (sin tocar el producto), reutilizando la misma fórmula de costo promedio ponderado que después usa `AprobarView` para no duplicar lógica de negocio.

## Nota

Este trabajo es extracurricular, no forma parte de la entrega evaluada del Grupo A.
