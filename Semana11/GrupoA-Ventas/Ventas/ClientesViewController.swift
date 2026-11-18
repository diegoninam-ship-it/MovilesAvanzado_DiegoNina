//
//  ClientesViewController.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import UIKit
import CoreData

/// Pantalla A4: clientes con categoría y total comprado calculados (no guardados).
final class ClientesViewController: UIViewController {

    private let context: NSManagedObjectContext
    private let esSupervisor = SesionUsuario.shared.usuarioActual?.rol == "Supervisor"

    private let tabla = UITableView(frame: .zero, style: .plain)
    private var clientes: [Cliente] = []

    private let celdaID = "ClienteCelda"

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
        title = "Clientes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add, target: self, action: #selector(crearCliente)
        )
        construirUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recargar()
    }

    private func construirUI() {
        tabla.translatesAutoresizingMaskIntoConstraints = false
        tabla.dataSource = self
        tabla.delegate = self
        tabla.rowHeight = 72
        view.addSubview(tabla)

        NSLayoutConstraint.activate([
            tabla.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tabla.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabla.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabla.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func recargar() {
        let fetchRequest: NSFetchRequest<Cliente> = Cliente.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        clientes = (try? context.fetch(fetchRequest)) ?? []
        tabla.reloadData()
    }

    /// Suma el total de las ventas no anuladas del cliente (no se guarda, se calcula cada vez).
    private func totalComprado(_ cliente: Cliente) -> Double {
        let ventas = (cliente.ventas as? Set<Venta>) ?? []
        return ventas.filter { !$0.anulada }.reduce(0) { $0 + $1.total }
    }

    /// Regular si lo comprado es menor a S/ 1,000; Frecuente desde S/ 1,000; VIP desde S/ 5,000 (umbral inclusivo).
    private func categoria(paraTotal total: Double) -> String {
        if total >= 5000 { return "VIP" }
        if total >= 1000 { return "Frecuente" }
        return "Regular"
    }

    private func iniciales(_ nombre: String) -> String {
        let partes = nombre.split(separator: " ")
        let letras = partes.prefix(2).compactMap { $0.first }
        return String(letras).uppercased()
    }

    @objc private func crearCliente() {
        presentarFormulario(cliente: nil)
    }

    private func presentarFormulario(cliente: Cliente?) {
        let alerta = UIAlertController(
            title: cliente == nil ? "Nuevo cliente" : "Editar cliente",
            message: nil, preferredStyle: .alert
        )
        alerta.addTextField { $0.placeholder = "Nombre"; $0.text = cliente?.nombre }
        alerta.addTextField { $0.placeholder = "Documento"; $0.text = cliente?.documento; $0.keyboardType = .numberPad }

        let accion = UIAlertAction(title: "Guardar", style: .default) { [weak self, weak alerta] _ in
            guard let self, let campos = alerta?.textFields else { return }
            let nombre = campos[0].text ?? ""
            let documento = campos[1].text ?? ""
            guard !nombre.isEmpty, !documento.isEmpty else { return }

            let destino = cliente ?? Cliente(context: self.context)
            destino.nombre = nombre
            destino.documento = documento
            PersistenceController.shared.guardar()
            self.recargar()
        }
        alerta.addAction(accion)
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(alerta, animated: true)
    }

    private func borrar(_ cliente: Cliente) {
        context.delete(cliente)
        do {
            try context.save()
            recargar()
        } catch {
            // Delete rule "Deny": no se puede borrar un Cliente con Ventas asociadas.
            context.rollback()
            let alerta = UIAlertController(
                title: "No se puede borrar",
                message: "\"\(cliente.nombre ?? "")\" tiene ventas registradas y no puede eliminarse.",
                preferredStyle: .alert
            )
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            present(alerta, animated: true)
        }
    }
}

// MARK: - UITableViewDataSource / Delegate

extension ClientesViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        clientes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: celdaID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: celdaID)
        let cliente = clientes[indexPath.row]
        let total = totalComprado(cliente)

        celda.textLabel?.text = "\(cliente.nombre ?? "")  ·  \(cliente.documento ?? "")"
        celda.detailTextLabel?.text = String(format: "S/. %.2f  ·  %@", total, categoria(paraTotal: total))
        celda.imageView?.image = avatar(paraIniciales: iniciales(cliente.nombre ?? ""))
        celda.selectionStyle = .default
        return celda
    }

    /// Dibuja un avatar circular simple con las iniciales del cliente.
    private func avatar(paraIniciales iniciales: String) -> UIImage {
        let tamano = CGSize(width: 36, height: 36)
        let renderer = UIGraphicsImageRenderer(size: tamano)
        return renderer.image { contexto in
            UIColor.secondarySystemBackground.setFill()
            contexto.cgContext.fillEllipse(in: CGRect(origin: .zero, size: tamano))

            let atributos: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .semibold),
                .foregroundColor: UIColor.label
            ]
            let texto = iniciales as NSString
            let tamanoTexto = texto.size(withAttributes: atributos)
            let origen = CGPoint(x: (tamano.width - tamanoTexto.width) / 2, y: (tamano.height - tamanoTexto.height) / 2)
            texto.draw(at: origen, withAttributes: atributos)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        presentarFormulario(cliente: clientes[indexPath.row])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard esSupervisor else { return nil }
        let accionBorrar = UIContextualAction(style: .destructive, title: "Borrar") { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            self.borrar(self.clientes[indexPath.row])
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [accionBorrar])
    }
}
