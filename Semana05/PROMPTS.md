# Prompts — Lab 05
## Docente: Juan Leon — Tecsup
## Herramienta: Claude

## Actividad — Calculadora de Préstamos
### Prompt (CTRFE):

**CONTEXTO:** Estudiante de iOS en semana 5 del curso Programación en Móviles
Avanzado, trabajando con Swift y UIKit (Storyboard, no SwiftUI). Ya se completó
el ejemplo guiado de Calculadora de IMC (Outlets, Actions, validación de
TextFields). Se conocen: UIViewController, @IBOutlet, @IBAction, Optionals,
String(format:).

**TAREA:** Generar el ViewController de una Calculadora de Préstamos que:
1. Reciba 3 datos del usuario: capital inicial, tasa de interés anual (%)
   y plazo del préstamo en años, mediante UITextField
2. Valide que ningún campo esté vacío o en cero antes de calcular
3. Convierta la tasa anual a tasa mensual y el plazo en años a número
   total de pagos
4. Calcule la cuota mensual usando la fórmula de amortización:
   M = P × [r(1+r)^n] / [(1+r)^n − 1]
5. Calcule el monto total a pagar (cuota mensual × número de pagos)
6. Muestre ambos resultados formateados a 2 decimales en un UILabel

**RESTRICCIONES:** Solo usar conceptos vistos hasta semana 5 (Outlets,
Actions, Optionals, pow() para potencias). Sin struct ni class adicionales.
Comentar cada línea del código explicando qué hace.

**FORMATO:** Código Swift completo (ViewController.swift) con un
comentario específico en CADA línea (no comentarios genéricos).

**EJEMPLO:** Basarse en el patrón del ejemplo resuelto de Calculadora de
IMC (mismo PDF del lab): Outlets para inputs, un Label de resultado,
validación de valores en 0, y @IBAction para el botón de cálculo.