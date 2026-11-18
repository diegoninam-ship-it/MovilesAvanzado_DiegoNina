//
//  ProductosViewController.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import UIKit
import CoreData

/// Pantalla A3: catálogo de productos con búsqueda, filtro por categoría y permisos por rol.
final class ProductosViewController: UIViewController {

    private let context: NSManagedObjectContext
    private let esSupervisor = SesionUsuario.shared.usuarioActual?.rol == "Supervisor"

    private let tabla = UITableView(frame: .zero, style: .plain)
    private let buscador = UISearchController(searchResultsController: nil)
    private let filaCategorias = UIStackView()

    private var productos: [Producto] = []
    private var categoriaSeleccionada: String?

    private let celdaID = "ProductoCelda"

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.context = PersistenceController.shared.viewContext
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Productos"
        construirUI()
        if esSupervisor {
            navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add, target: self, action: #selector(crearProducto)
            )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recargar()
    }

    // MARK: - UI

    private func construirUI() {
        navigationItem.searchController = buscador
        navigationItem.hidesSearchBarWhenScrolling = false
        buscador.obscuresBackgroundDuringPresentation = false
        buscador.searchResultsUpdater = self
        buscador.searchBar.placeholder = "Buscar producto"

        construirChipsCategoria()

        tabla.translatesAutoresizingMaskIntoConstraints = false
        tabla.dataSource = self
        tabla.delegate = self

        let contenedor = UIStackView(arrangedSubviews: [filaCategorias, tabla])
        contenedor.axis = .vertical
        contenedor.spacing = 8
        contenedor.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contenedor)

        NSLayoutConstraint.activate([
            contenedor.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contenedor.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contenedor.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contenedor.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    /// Chips de categoría: un UIButton por categoría + "Todas"; se combinan con la búsqueda en un único NSPredicate.
    private func construirChipsCategoria() {
        filaCategorias.axis = .horizontal
        filaCategorias.spacing = 8
        filaCategorias.distribution = .fillProportionally

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.showsHorizontalScrollIndicator = false

        for categoria in ["Todas"] + categoriasDisponibles() {
            let boton = UIButton(type: .system)
            boton.setTitle(categoria, for: .normal)
            boton.tag = (["Todas"] + categoriasDisponibles()).firstIndex(of: categoria) ?? 0
            boton.addTarget(self, action: #selector(chipTocado(_:)), for: .touchUpInside)
            boton.backgroundColor = .secondarySystemBackground
            boton.layer.cornerRadius = 14
            boton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            boton.accessibilityIdentifier = categoria
            filaCategorias.addArrangedSubview(boton)
        }
    }

    private func categoriasDisponibles() -> [String] {
        let fetchRequest: NSFetchRequest<Producto> = Producto.fetchRequest()
        let todos = (try? context.fetch(fetchRequest)) ?? []
        return Array(Set(todos.compactMap { $0.categoria })).sorted()
    }

    @objc private func chipTocado(_ sender: UIButton) {
        categoriaSeleccionada = sender.accessibilityIdentifier == "Todas" ? nil : sender.accessibilityIdentifier
        recargar()
    }

    // MARK: - Datos

    private func recargar() {
        let fetchRequest: NSFetchRequest<Producto> = Producto.fetchRequest()
        var subpredicados: [NSPredicate] = []

        if let texto = buscador.searchBar.text, !texto.trimmingCharacters(in: .whitespaces).isEmpty {
            subpredicados.append(NSPredicate(format: "nombre CONTAINS[cd] %@", texto))
        }
        if let categoria = categoriaSeleccionada {
            subpredicados.append(NSPredicate(format: "categoria == %@", categoria))
        }
        if !subpredicados.isEmpty {
            fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicados)
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]

        productos = (try? context.fetch(fetchRequest)) ?? []
        tabla.reloadData()
    }

    @objc private func crearProducto() {
        presentarFormulario(producto: nil)
    }

    private func presentarFormulario(producto: Producto?) {
        let alerta = UIAlertController(
            title: producto == nil ? "Nuevo producto" : "Editar producto",
            message: nil, preferredStyle: .alert
        )
        alerta.addTextField { $0.placeholder = "Nombre"; $0.text = producto?.nombre }
        alerta.addTextField { $0.placeholder = "Categoría"; $0.text = producto?.categoria }
        alerta.addTextField { $0.placeholder = "Precio"; $0.text = producto.map { String($0.precio) }; $0.keyboardType = .decimalPad }
        alerta.addTextField { $0.placeholder = "Stock"; $0.text = producto.map { String($0.stock) }; $0.keyboardType = .numberPad }

        let accion = UIAlertAction(title: "Guardar", style: .default) { [weak self, weak alerta] _ in
            guard let self, let campos = alerta?.textFields else { return }
            let nombre = campos[0].text ?? ""
            let categoria = campos[1].text ?? ""
            let precio = Double(campos[2].text ?? "") ?? 0
            let stock = Int32(campos[3].text ?? "") ?? 0

            guard !nombre.isEmpty, !categoria.isEmpty else { return }

            let destino = producto ?? Producto(context: self.context)
            destino.nombre = nombre
            destino.categoria = categoria
            destino.precio = precio
            destino.stock = stock
            PersistenceController.shared.guardar()
            self.recargar()
        }
        alerta.addAction(accion)
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alerta, animated: true)
    }

    private func borrar(_ producto: Producto) {
        context.delete(producto)
        do {
            try context.save()
            recargar()
        } catch {
            // El delete rule "Deny" impide borrar un Producto con Ventas asociadas; se revierte y se avisa.
            context.rollback()
            let alerta = UIAlertController(
                title: "No se puede borrar",
                message: "\"\(producto.nombre ?? "")\" tiene ventas registradas y no puede eliminarse.",
                preferredStyle: .alert
            )
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            present(alerta, animated: true)
        }
    }

    /// Verde si stock > 10, ámbar si 6-10, rojo si <= 5.
    private func colorStock(_ stock: Int32) -> UIColor {
        if stock > 10 { return .systemGreen }
        if stock >= 6 { return .systemOrange }
        return .systemRed
    }
}

// MARK: - UITableViewDataSource / Delegate

extension ProductosViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        productos.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: celdaID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: celdaID)
        let producto = productos[indexPath.row]
        celda.textLabel?.text = "\(producto.nombre ?? "") · \(producto.categoria ?? "")"
        celda.detailTextLabel?.text = String(format: "S/. %.2f  ·  stock: %d", producto.precio, producto.stock)
        celda.detailTextLabel?.textColor = colorStock(producto.stock)
        celda.selectionStyle = esSupervisor ? .default : .none
        return celda
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard esSupervisor else { return }
        presentarFormulario(producto: productos[indexPath.row])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard esSupervisor else { return nil }
        let accionBorrar = UIContextualAction(style: .destructive, title: "Borrar") { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            self.borrar(self.productos[indexPath.row])
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [accionBorrar])
    }
}

// MARK: - UISearchResultsUpdating

extension ProductosViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        recargar()
    }
}
