//
//  VentasSupervisorViewController.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import UIKit
import CoreData

/// Pantalla A7 (solo Supervisor): todas las ventas, filtro por vendedor e inicio de anulación.
final class VentasSupervisorViewController: UIViewController {

    private let context: NSManagedObjectContext

    private let filaVendedores = UIStackView()
    private let tabla = UITableView(frame: .zero, style: .plain)

    private var vendedores: [Usuario] = []
    private var vendedorSeleccionado: Usuario?
    private var ventas: [Venta] = []
    private let celdaID = "VentaSupervisorCelda"

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
        title = "Ventas"
        construirUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarVendedores()
        recargar()
    }

    // MARK: - UI

    private func construirUI() {
        filaVendedores.axis = .horizontal
        filaVendedores.spacing = 8

        tabla.translatesAutoresizingMaskIntoConstraints = false
        tabla.dataSource = self
        tabla.delegate = self

        let contenedor = UIStackView(arrangedSubviews: [filaVendedores, tabla])
        contenedor.axis = .vertical
        contenedor.spacing = 8
        contenedor.translatesAutoresizingMaskIntoConstraints = false
        contenedor.isLayoutMarginsRelativeArrangement = true
        contenedor.layoutMargins = UIEdgeInsets(top: 12, left: 16, bottom: 0, right: 16)
        view.addSubview(contenedor)

        NSLayoutConstraint.activate([
            contenedor.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contenedor.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contenedor.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contenedor.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func cargarVendedores() {
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "rol == %@", "Vendedor")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        vendedores = (try? context.fetch(fetchRequest)) ?? []

        filaVendedores.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (indice, chip) in (["Todos"] + vendedores.map { $0.nombre ?? "" }).enumerated() {
            let boton = UIButton(type: .system)
            boton.setTitle(chip, for: .normal)
            boton.tag = indice
            boton.addTarget(self, action: #selector(chipTocado(_:)), for: .touchUpInside)
            boton.backgroundColor = .secondarySystemBackground
            boton.layer.cornerRadius = 14
            boton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
            filaVendedores.addArrangedSubview(boton)
        }
    }

    @objc private func chipTocado(_ sender: UIButton) {
        vendedorSeleccionado = sender.tag == 0 ? nil : vendedores[sender.tag - 1]
        recargar()
    }

    private func recargar() {
        let fetchRequest: NSFetchRequest<Venta> = Venta.fetchRequest()
        if let vendedor = vendedorSeleccionado {
            fetchRequest.predicate = NSPredicate(format: "vendedor == %@", vendedor)
        }
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fecha", ascending: false)]
        ventas = (try? context.fetch(fetchRequest)) ?? []
        tabla.reloadData()
    }

    private func anular(_ venta: Venta) {
        let anularVC = AnularVentaViewController(venta: venta) { [weak self] in
            self?.recargar()
        }
        present(UINavigationController(rootViewController: anularVC), animated: true)
    }
}

// MARK: - UITableViewDataSource / Delegate

extension VentasSupervisorViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ventas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: celdaID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: celdaID)
        let venta = ventas[indexPath.row]

        let descripcion = "\(venta.producto?.nombre ?? "")  ·  \(venta.vendedor?.nombre ?? "")"
        let detalle = String(format: "S/. %.2f  ·  %@", venta.total, venta.cliente?.nombre ?? "")

        if venta.anulada {
            let atributos: [NSAttributedString.Key: Any] = [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            celda.textLabel?.attributedText = NSAttributedString(string: "\(descripcion)  ·  ANULADA", attributes: atributos)
            celda.detailTextLabel?.attributedText = NSAttributedString(string: detalle, attributes: atributos)
        } else {
            celda.textLabel?.attributedText = NSAttributedString(string: descripcion)
            celda.detailTextLabel?.attributedText = NSAttributedString(string: detalle)
        }
        celda.selectionStyle = .none
        return celda
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let venta = ventas[indexPath.row]
        guard !venta.anulada else { return nil }
        let accionAnular = UIContextualAction(style: .destructive, title: "Anular") { [weak self] _, _, completion in
            self?.anular(venta)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [accionAnular])
    }
}
