// Desarrollado por: Diego Nina Malqui

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TablaContacto: UITableView!

    var contactos = [Contacto]()

    @IBAction func agregarContacto(_ sender: UIBarButtonItem) {
        let alerta = UIAlertController(title: "Nuevo Contacto", message: "Ingrese los datos del contacto", preferredStyle: .alert)

        alerta.addTextField { textField in
            textField.placeholder = "Nombre"
        }
        alerta.addTextField { textField in
            textField.placeholder = "Telefono"
        }
        alerta.addTextField { textField in
            textField.placeholder = "Direccion"
        }

        let accionGuardar = UIAlertAction(title: "Guardar", style: .default) { _ in
            guard let nombre = alerta.textFields?[0].text,
                  let telefono = alerta.textFields?[1].text,
                  let direccion = alerta.textFields?[2].text else { return }

            let contexto = self.conexion()
            let nuevoContacto = NSEntityDescription.insertNewObject(forEntityName: "Contacto", into: contexto) as! Contacto
            nuevoContacto.nombre = nombre
            nuevoContacto.telefono = telefono
            nuevoContacto.direccion = direccion

            do {
                try contexto.save()
                self.cargarInfoCoreData()
            } catch {
                print("Error al guardar contacto: \(error)")
            }
        }

        let accionCancelar = UIAlertAction(title: "Cancelar", style: .cancel)

        alerta.addAction(accionGuardar)
        alerta.addAction(accionCancelar)

        present(alerta, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        TablaContacto.dataSource = self
        TablaContacto.delegate = self
        mostrarRutaBaseDeDatos()
        cargarInfoCoreData()
    }

    // MARK: - Core Data

    func conexion() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

    func mostrarRutaBaseDeDatos() {
        if let url = conexion().persistentStoreCoordinator?.persistentStores.first?.url {
            print("Base de datos SQLite en: \(url)")
        }
    }

    func cargarInfoCoreData() {
        let contexto = conexion()
        let peticion: NSFetchRequest<Contacto> = Contacto.fetchRequest()
        peticion.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        do {
            contactos = try contexto.fetch(peticion)
            TablaContacto.reloadData()
        } catch {
            print("Error al cargar contactos: \(error)")
        }
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let contacto = contactos[indexPath.row]
        celda.textLabel?.text = contacto.nombre
        celda.detailTextLabel?.text = contacto.telefono
        return celda
    }

}
