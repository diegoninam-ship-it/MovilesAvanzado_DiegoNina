//
//  MisVentasViewController.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import UIKit
import CoreData

/// Pantalla A6 (solo Vendedor): sus propias ventas, con indicadores y filtros.
final class MisVentasViewController: UIViewController {

    private let context: NSManagedObjectContext

    private let etiquetaHoy = UILabel()
    private let etiquetaMes = UILabel()
    private let segmentado = UISegmentedControl(items: ["Todas", "Hoy", "Mes"])
    private let buscador = UISearchController(searchResultsController: nil)
    private let tabla = UITableView(frame: .zero, style: .plain)

    private var ventas: [Venta] = []
    private let celdaID = "VentaCelda"

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
        title = "Mis ventas"
        construirUI()
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
        buscador.searchBar.placeholder = "Buscar por cliente"

        etiquetaHoy.font = .systemFont(ofSize: 15, weight: .medium)
        etiquetaMes.font = .systemFont(ofSize: 15, weight: .medium)
        let indicadores = UIStackView(arrangedSubviews: [etiquetaHoy, etiquetaMes])
        indicadores.axis = .vertical
        indicadores.spacing = 4

        segmentado.selectedSegmentIndex = 0
        segmentado.addTarget(self, action: #selector(filtroCambio), for: .valueChanged)

        tabla.translatesAutoresizingMaskIntoConstraints = false
        tabla.dataSource = self
        tabla.delegate = self

        let contenedor = UIStackView(arrangedSubviews: [indicadores, segmentado, tabla])
        contenedor.axis = .vertical
        contenedor.spacing = 12
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

    @objc private func filtroCambio() {
        recargar()
    }

    // MARK: - Datos

    private func recargar() {
        guard let vendedor = SesionUsuario.shared.usuarioActual else { return }

        let fetchRequest: NSFetchRequest<Venta> = Venta.fetchRequest()
        var subpredicados: [NSPredicate] = [NSPredicate(format: "vendedor == %@", vendedor)]

        switch segmentado.selectedSegmentIndex {
        case 1:
            subpredicados.append(NSPredicate(format: "fecha >= %@", inicioDeHoy() as NSDate))
        case 2:
            subpredicados.append(NSPredicate(format: "fecha >= %@", inicioDeMes() as NSDate))
        default:
            break
        }

        if let texto = buscador.searchBar.text, !texto.trimmingCharacters(in: .whitespaces).isEmpty {
            subpredicados.append(NSPredicate(format: "cliente.nombre CONTAINS[cd] %@", texto))
        }

        fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: subpredicados)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "fecha", ascending: false)]
        ventas = (try? context.fetch(fetchRequest)) ?? []
        tabla.reloadData()
        actualizarIndicadores(vendedor: vendedor)
    }

    private func actualizarIndicadores(vendedor: Usuario) {
        let fetchRequest: NSFetchRequest<Venta> = Venta.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "vendedor == %@", vendedor)
        let todasLasVentas = (try? context.fetch(fetchRequest)) ?? []

        let hoy = inicioDeHoy()
        let inicioMes = inicioDeMes()

        let totalHoy = todasLasVentas
            .filter { !$0.anulada && ($0.fecha ?? .distantPast) >= hoy }
            .reduce(0) { $0 + $1.total }
        let totalMes = todasLasVentas
            .filter { !$0.anulada && ($0.fecha ?? .distantPast) >= inicioMes }
            .reduce(0) { $0 + $1.total }

        etiquetaHoy.text = String(format: "Vendido hoy: S/. %.2f", totalHoy)
        etiquetaMes.text = String(format: "Vendido este mes: S/. %.2f", totalMes)
    }

    private func inicioDeHoy() -> Date {
        Calendar.current.startOfDay(for: Date())
    }

    private func inicioDeMes() -> Date {
        let comp = Calendar.current.dateComponents([.year, .month], from: Date())
        return Calendar.current.date(from: comp) ?? Date()
    }
}

// MARK: - UITableViewDataSource / Delegate

extension MisVentasViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ventas.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let celda = tableView.dequeueReusableCell(withIdentifier: celdaID) ?? UITableViewCell(style: .subtitle, reuseIdentifier: celdaID)
        let venta = ventas[indexPath.row]

        let descripcion = "\(venta.producto?.nombre ?? "")  ·  \(venta.cliente?.nombre ?? "")"
        let montoYFecha = String(format: "S/. %.2f  ·  %@", venta.total, formatoFecha(venta.fecha))

        if venta.anulada {
            let atributos: [NSAttributedString.Key: Any] = [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            celda.textLabel?.attributedText = NSAttributedString(string: "\(descripcion)  ·  ANULADA", attributes: atributos)
            celda.detailTextLabel?.attributedText = NSAttributedString(string: montoYFecha, attributes: atributos)
        } else {
            celda.textLabel?.attributedText = NSAttributedString(string: descripcion)
            celda.detailTextLabel?.attributedText = NSAttributedString(string: montoYFecha)
        }
        celda.selectionStyle = .none
        return celda
    }

    private func formatoFecha(_ fecha: Date?) -> String {
        guard let fecha else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: fecha)
    }
}

// MARK: - UISearchResultsUpdating

extension MisVentasViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        recargar()
    }
}
