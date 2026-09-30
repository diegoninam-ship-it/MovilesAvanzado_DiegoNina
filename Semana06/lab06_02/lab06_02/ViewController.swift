//
//  ViewController.swift
//  lab06_02
//
//  Created by Tecsup on 30/09/26.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tfApellido: UITextField!
    @IBOutlet weak var tfNombre: UITextField!
    @IBOutlet weak var tfDni: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func btnContinuar(_ sender: Any) {
        let oCliente: ClienteModel = ClienteModel(Codigo:0,Apellido:self.tfApellido.text!,
                                                  Nombre:self.tfNombre.text!,Dni:self.tfDni.text!)
        
        let osb: UIStoryboard=UIStoryboard(name: "Main", bundle: nil)
        let oPantalla2 = osb.instantiateViewController(withIdentifier: "ViewControllerConfirmacion") as! ViewControllerConfirmacion
        oPantalla2.pCliente = oCliente
        self.present(oPantalla2, animated: true, completion: nil)
    }

}

