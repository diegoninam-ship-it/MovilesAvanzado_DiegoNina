# Prompts — Lab 11, Trabajo de la semana (Grupo A)

## Docente: Juan Leon — Tecsup
## Herramienta: Claude Code

---

## CTRFE

**Contexto:** Caso Ventas del Laboratorio 11, Grupo A. App UIKit + Core Data con dos roles (Vendedor y Supervisor), cuyo modelo de datos, reglas de negocio con ejemplos numéricos, pantallas y casos de prueba ya estaban resueltos a mano en `Semana11/Expediente-Lab11-GrupoA.md`. Se trabajó en la rama `ai-assisted`, dentro de `Semana11/GrupoA-Ventas/`, sin tocar ninguna otra semana ni las ramas `main`/`manual`.

**Tarea:** Traducir el expediente a código: 4 entidades Core Data con relaciones `Deny`, 9 pantallas (Login, Registro, Productos, Clientes, Nueva Venta, Mis Ventas, Ventas+Anulación, Resumen) más la pestaña Cuenta, toda la UI construida por código (UIStackView + Auto Layout), un `UITabBarController` que cambia de pestañas según el rol de la sesión activa, y un target de pruebas unitarias que verifique los 11 casos de prueba del expediente con un store de Core Data en memoria.

**Restricciones:** Solo UIKit y Core Data (nada de librerías externas). Un commit por checkpoint, en el orden exacto del plan de commits del expediente, con `xcodebuild` en verde y sin crash en el simulador antes de cada uno. Nombres de archivo, convención de código (camelCase, `// MARK: -`, `guard`) y moneda siempre como `String(format: "S/. %.2f", valor)`.

**Formato:** Proyecto Xcode (`Ventas.xcodeproj`) con Storyboard mínimo (solo punto de entrada) y el resto de la UI en Swift puro; `Ventas.xcdatamodeld` con `codeGenerationType="class"` en las 4 entidades.

**Ejemplo:** La fórmula de descuento/IGV/total de la Sección 4 del expediente (2 Laptop a S/ 200.00 a un cliente VIP → subtotal 400.00, descuento 40.00, IGV 64.80, total 424.80) se tradujo literalmente a `CalculoVenta.swift`, sin que la IA derivara ni ajustara los porcentajes.

---

## Reflexión: qué hizo distinto la IA

- **Gráfico de 7 días sin librerías:** en vez de buscar un framework de charts, se resolvió con un `UIStackView` horizontal de columnas, cada una con un `UIView` cuya altura es proporcional al total vendido ese día (altura mínima de 4pt para que el día sin ventas siga siendo visible como una barra, no como un hueco).
- **Error "Deny" al borrar:** Core Data no expone de antemano si un borrado va a fallar por la regla `Deny`; la decisión propia fue intentar `context.save()` dentro de un `do/catch`, y si falla, hacer `context.rollback()` y mostrar una alerta en vez de dejar que la app truene. Esto se repitió igual en Productos y en Clientes.
- **Chips de categoría:** se usaron `UIButton`s simples con `cornerRadius` dentro de un `UIStackView` horizontal en vez de un `UISegmentedControl`, porque la cantidad de categorías es dinámica (depende de lo que haya en el catálogo), y un segmented control fijo no se habría adaptado bien a una lista de longitud variable.
- **Secuencia de pantallas durante el desarrollo:** como Registro y Login (checkpoints 2 y 3) debían navegar al `UITabBarController` del rol, pero ese controlador recién se crea en el checkpoint 4, se escribieron los 9 `ViewController`s y el `MainTabBarController` en el disco desde antes, pero solo se los incluyó en el commit del checkpoint 4 — así cada checkpoint compiló en verde sin adelantar funcionalidad de otro commit.
- **Cálculos extraídos a `CalculoVenta.swift`:** las fórmulas de subtotal/descuento/IGV/total y la categoría del cliente se sacaron de los `ViewController`s a un `enum` sin estado, para poder probarlas con `XCTest` sin tener que montar una UI ni simular taps.
- **Verificación con el simulador:** cada checkpoint se instaló y abrió en el simulador (iPhone 18 Pro) manejando la app con taps reales (registro, login, crear producto/cliente, registrar venta, anular venta) para confirmar que los números mostrados coincidían exactamente con los ejemplos de la Sección 4 y los casos de la Sección 6 del expediente, no solo que compilara.

---

## Pendiente para la defensa oral

Revisar especialmente el manejo de errores Core Data (`Deny`) en `ProductosViewController.borrar(_:)` y `ClientesViewController.borrar(_:)`, y la lógica de `CalculoVenta.swift`, ya que son las partes donde la IA tomó decisiones de diseño no dictadas literalmente por el prompt.
