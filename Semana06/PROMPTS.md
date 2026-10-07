# Prompts — Lab 06
## Docente: Juan Leon — Tecsup
## Herramienta: Claude Code

## Actividad — Ejercicio 4: Calculadora de Venta a Plazos de Electrodoméstico
### Prompt (CTRFE):

**CONTEXTO:** Estudiante de iOS en semana 6 del curso Programación en Móviles
Avanzado, trabajando con Swift y UIKit (Storyboard, no SwiftUI). Ya se completó
en clase el lab06 (Navigation Controller + segue Show) y el lab06_02
(presentación modal con `ClienteModel`). Se conocen: UIViewController,
UINavigationController, segues (`show` y `present`), `prepare(for:sender:)`,
@IBOutlet, @IBAction, Optionals, clases como modelo de datos pasado por
referencia entre pantallas.

**TAREA:** Construir el Ejercicio 4 (Calculadora de Venta a Plazos) con:
1. Pantalla "Nueva Venta" con 5 entradas (nombre del electrodoméstico,
   precio unitario, cantidad, número de meses, tasa de interés mensual %)
   y un botón "Calcular"
2. Pantalla "Resultado" que muestre subtotal, IGV, monto base, intereses
   totales, total a pagar y cuota mensual, cada uno formateado con
   `String(format: "S/. %.2f", valor)`
3. Navegación con segue **Show** de identifier `showResultado` dentro de
   un `UINavigationController`, pasando los datos con `prepare(for:sender:)`
4. Una clase `VentaModel: NSObject` con las 6 salidas como `Double`
5. Fórmulas: subtotal = precioUnitario × cantidad; igv = subtotal × 0.18;
   base = subtotal + igv; intereses = base × (tasaMensual/100) × meses;
   total = base + intereses; cuota = total / meses

**RESTRICCIONES:** Solo conceptos vistos hasta la semana 6: clases,
UINavigationController, `prepare(for:sender:)`, IBOutlet/IBAction. Sin
Combine, Codable, persistencia ni librerías externas. El proyecto debe
compilar con `PBXFileSystemSynchronizedRootGroup` (objectVersion 77), sin
editar listas de archivos en `project.pbxproj`.

**FORMATO:** Proyecto Xcode completo (`Lab06VentaPlazos`) con Storyboard
mínimo (Navigation Controller inicial → `NuevaVentaViewController` →
segue `showResultado` → `ResultadoViewController`), UI construida por
código en cada ViewController (UIStackView + Auto Layout), y
`VentaModel.swift` como modelo de datos.

**EJEMPLO:** Basarse en el patrón de `lab06_02` (ClienteModel pasado por
referencia hacia `ViewControllerConfirmacion` vía `prepare(for:sender:)` y
segue manual), adaptado a un cálculo financiero con más campos de entrada
y más valores de salida.

## Reflexión: qué hizo distinto la IA

- Usó `guard let` encadenado para cada campo de entrada en vez de
  desenvolver forzado (`!`) o `if`/`else` anidados, evitando un posible
  crash si el usuario deja un campo vacío o escribe texto no numérico.
- Agregó validaciones que el enunciado no detallaba explícitamente:
  precio unitario y tasa deben ser convertibles a `Double`, cantidad y
  meses deben ser `Int` mayores a 0, y la tasa no puede ser negativa.
- Mostró los errores de validación con `UIAlertController` en vez de
  solo loggear en consola o dejar el cálculo en un estado inconsistente.
- Construyó toda la interfaz por código (UIStackView + NSLayoutConstraint)
  en lugar de diseñar los campos en el Storyboard con `fixedFrame`, para
  que el layout se adapte a distintos tamaños de pantalla sin depender
  de coordenadas fijas.
- Separó el segue como una conexión manual del propio ViewController
  (no atada a un botón del Storyboard), disparándolo por código desde
  `calcularPresionado()` solo después de que la validación pasa.
- En el refinamiento visual, aisló los cambios de estilo (color de marca,
  tarjeta con sombra, inputs con padding) del código de cálculo y
  navegación, para que un cambio de diseño no arriesgue la lógica ya
  validada.
