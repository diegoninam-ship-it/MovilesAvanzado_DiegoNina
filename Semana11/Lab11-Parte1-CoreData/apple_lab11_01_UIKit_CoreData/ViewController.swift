// Desarrollado por: Diego Nina Malqui

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TablaContacto: UITableView!

    var contactos = [Contacto]()

    @IBAction func agregarContacto(_ sender: UIBarButtonItem) {
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
