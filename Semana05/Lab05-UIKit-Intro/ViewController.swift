// Desarrollado por: Diego Nina
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Label agregado por código (segundo Label del ejercicio)
        let nombreLabel = UILabel()
        nombreLabel.text = "Diego Nina"
        nombreLabel.backgroundColor = .systemBlue
        nombreLabel.textColor = .white
        nombreLabel.font = UIFont.boldSystemFont(ofSize: 24) // más grande que el Label base
        nombreLabel.textAlignment = .center
        nombreLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nombreLabel)

        NSLayoutConstraint.activate([
            nombreLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            nombreLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 150),
            nombreLabel.widthAnchor.constraint(equalToConstant: 250),
            nombreLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}