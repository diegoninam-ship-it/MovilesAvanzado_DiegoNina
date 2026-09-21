// Desarrollado por: Diego Nina
// Herramienta usada: Claude
import UIKit // Importa el framework UIKit, necesario para UIViewController, UILabel, UITextField, etc.

class ViewController: UIViewController { // Define la clase principal de la pantalla, heredando de UIViewController

    @IBOutlet weak var capitalTextField: UITextField! // Conexión al campo de texto donde el usuario ingresa el capital inicial
    @IBOutlet weak var tasaTextField: UITextField! // Conexión al campo de texto donde el usuario ingresa la tasa de interés anual
    @IBOutlet weak var plazoTextField: UITextField! // Conexión al campo de texto donde el usuario ingresa el plazo en años
    @IBOutlet weak var resultLabel: UILabel! // Conexión al Label donde se mostrará el resultado del cálculo

    override func viewDidLoad() { // Se ejecuta automáticamente cuando la pantalla termina de cargar
        super.viewDidLoad() // Llama a la implementación base de viewDidLoad (obligatorio)
        resultLabel.text = "Ingresa capital, tasa y plazo" // Muestra un mensaje inicial antes de que el usuario calcule algo
    }

    @IBAction func calcularPrestamo(_ sender: Any) { // Se ejecuta cuando el usuario presiona el botón "Calcular"
        // Obtener los valores ingresados
        let capital = Double(capitalTextField.text ?? "") ?? 0 // Convierte el texto del capital a Double; si falla o está vacío, usa 0
        let tasaAnual = Double(tasaTextField.text ?? "") ?? 0 // Convierte el texto de la tasa anual a Double; si falla, usa 0
        let plazoAnios = Double(plazoTextField.text ?? "") ?? 0 // Convierte el texto del plazo a Double; si falla, usa 0

        // Validar que ningún valor esté vacío o en cero
        if capital == 0 || tasaAnual == 0 || plazoAnios == 0 { // Si alguno de los 3 valores es 0 (inválido o vacío)
            resultLabel.text = "Por favor, ingresa valores válidos." // Muestra mensaje de error al usuario
            return // Detiene la ejecución de la función para no continuar con datos inválidos
        }

        // Convertir tasa anual a tasa mensual, y años a número de pagos
        let r = (tasaAnual / 100) / 12 // Convierte el porcentaje anual a decimal, y luego a tasa mensual (÷12)
        let n = plazoAnios * 12 // Convierte el plazo de años a número total de cuotas mensuales

        // Fórmula de amortización: M = P * [r(1+r)^n] / [(1+r)^n - 1]
        let factor = pow(1 + r, n) // Calcula (1+r) elevado a la n; pow() es la función de potencia de Swift
        let cuotaMensual = capital * (r * factor) / (factor - 1) // Aplica la fórmula completa para obtener la cuota mensual (M)

        // Calcular el monto total a pagar (cuota mensual × número de pagos)
        let montoTotal = cuotaMensual * n // Multiplica la cuota mensual por el total de pagos para obtener el monto final

        // Mostrar el resultado formateado
        resultLabel.text = "Cuota mensual: S/. \(String(format: "%.2f", cuotaMensual))\nMonto total a pagar: S/. \(String(format: "%.2f", montoTotal))" // Muestra ambos resultados con 2 decimales, separados por salto de línea
    }
}