//
//  ViewControllerConfirmacion.swift
//  lab06_02
//
//  Created by Tecsup on 30/09/26.
//

import UIKit

class ViewControllerConfirmacion: UIViewController {

    var pCliente:ClienteModel = ClienteModel()
    @IBOutlet weak var tfApellido:UILabel!
    @IBOutlet weak var tfNombre:UILabel!
    @IBOutlet weak var tfDni:UILabel!
    private let botonVolver: UIButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tfApellido.text = pCliente.Apellido
        self.tfNombre.text = pCliente.Nombre
        self.tfDni.text = pCliente.Dni
        configurarBotonVolver()
    }

    // MARK: - UI por codigo

    private func configurarBotonVolver() {
        botonVolver.setTitle("Volver", for: .normal)
        botonVolver.translatesAutoresizingMaskIntoConstraints = false
        botonVolver.addTarget(self, action: #selector(volverPresionado), for: .touchUpInside)
        view.addSubview(botonVolver)

        NSLayoutConstraint.activate([
            botonVolver.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            botonVolver.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
        ])
    }

    @objc private func volverPresionado() {
        dismiss(animated: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
