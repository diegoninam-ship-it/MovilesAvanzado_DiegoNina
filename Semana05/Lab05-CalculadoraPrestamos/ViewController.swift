// Desarrollado por: Diego Nina
import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var capitalTextField: UITextField!
    @IBOutlet weak var tasaTextField: UITextField!
    @IBOutlet weak var plazoTextField: UITextField!
    @IBOutlet weak var resultLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        resultLabel.text = "Ingresa capital, tasa y plazo"
    }

    @IBAction func calcularPrestamo(_ sender: Any) {
        // Obtener los valores ingresados
        let capital = Double(capitalTextField.text ?? "") ?? 0
        let tasaAnual = Double(tasaTextField.text ?? "") ?? 0
        let plazoAnios = Double(plazoTextField.text ?? "") ?? 0

        // Validar que ningún valor esté vacío o en cero
        if capital == 0 || tasaAnual == 0 || plazoAnios == 0 {
            resultLabel.text = "Por favor, ingresa valores válidos."
            return
        }
    }
}