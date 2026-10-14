//
//  ViewController.swift
//  Ejercicio01
//
//  Created by Tecsup on 14/10/26.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listaProfesores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda")!
        cell.textLabel?.text = listaProfesores[indexPath.row].nombre
        cell.detailTextLabel?.text = listaProfesores[indexPath.row].cargo
        cell.imageView?.image = listaProfesores[indexPath.row].foto
        return cell
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    var listaProfesores=[
        Profesor(nombre:"Jaime Gomez", cargo: "Coordinador de Software", foto:UIImage(named:"avatar1")),
        Profesor(nombre:"Jaime Farfan", cargo: "Docente de Software TC", foto:UIImage(named:"avatar2")),
        Profesor(nombre:"Juan León", cargo: "Docente de Software TC", foto:UIImage(named:"avatar3")),
        Profesor(nombre: "Silvia Montoya", cargo: "Docente de Software TC", foto:UIImage(named:"avatar4"))
    ]


}

