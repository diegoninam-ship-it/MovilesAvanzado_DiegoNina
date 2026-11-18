//
//  ResumenViewController.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import UIKit
import CoreData

/// Pantalla A9 (solo Supervisor): indicadores, gráfico de 7 días, ranking de vendedores y stock bajo.
final class ResumenViewController: UIViewController {

    private let context: NSManagedObjectContext

    private let etiquetaSaludo = UILabel()
    private let etiquetaComparacion = UILabel()
    private let filaGrafico = UIStackView()
    private let etiquetaRankingTitulo = UILabel()
    private let stackRanking = UIStackView()
    private let etiquetaStockBajoTitulo = UILabel()
    private let stackStockBajo = UIStackView()

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
        title = "Resumen"
        construirUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        recargar()
    }

    // MARK: - UI

    private func construirUI() {
        etiquetaSaludo.font = .systemFont(ofSize: 20, weight: .bold)
        etiquetaSaludo.numberOfLines = 0

        etiquetaComparacion.font = .systemFont(ofSize: 15)
        etiquetaComparacion.numberOfLines = 0

        filaGrafico.axis = .horizontal
        filaGrafico.alignment = .bottom
        filaGrafico.distribution = .fillEqually
        filaGrafico.spacing = 8
        filaGrafico.translatesAutoresizingMaskIntoConstraints = false
        filaGrafico.heightAnchor.constraint(equalToConstant: 140).isActive = true

        etiquetaRankingTitulo.font = .systemFont(ofSize: 17, weight: .semibold)
        etiquetaRankingTitulo.text = "Ranking de vendedores (mes)"

        stackRanking.axis = .vertical
        stackRanking.spacing = 6

        etiquetaStockBajoTitulo.font = .systemFont(ofSize: 17, weight: .semibold)
        etiquetaStockBajoTitulo.text = "Stock bajo (≤ 5)"

        stackStockBajo.axis = .vertical
        stackStockBajo.spacing = 6

        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let contenido = UIStackView(arrangedSubviews: [
            etiquetaSaludo, etiquetaComparacion, filaGrafico,
            etiquetaRankingTitulo, stackRanking,
            etiquetaStockBajoTitulo, stackStockBajo
        ])
        contenido.axis = .vertical
        contenido.spacing = 20
        contenido.setCustomSpacing(8, after: etiquetaRankingTitulo)
        contenido.setCustomSpacing(8, after: etiquetaStockBajoTitulo)
        contenido.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(contenido)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contenido.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 16),
            contenido.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 24),
            contenido.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -24),
            contenido.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -24),
            contenido.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -48)
        ])
    }

    // MARK: - Datos

    private func recargar() {
        let usuario = SesionUsuario.shared.usuarioActual
        etiquetaSaludo.text = "Hola, \(usuario?.nombre ?? "")\n\(usuario?.rol ?? "")"

        let todasLasVentas = fetchTodasLasVentas()
        actualizarComparacion(todasLasVentas)
        actualizarGrafico(todasLasVentas)
        actualizarRanking(todasLasVentas)
        actualizarStockBajo()
    }

    private func fetchTodasLasVentas() -> [Venta] {
        let fetchRequest: NSFetchRequest<Venta> = Venta.fetchRequest()
        return (try? context.fetch(fetchRequest)) ?? []
    }

    private func totalEnDia(_ ventas: [Venta], _ dia: Date) -> Double {
        let calendario = Calendar.current
        return ventas
            .filter { !$0.anulada && calendario.isDate($0.fecha ?? .distantPast, inSameDayAs: dia) }
            .reduce(0) { $0 + $1.total }
    }

    private func actualizarComparacion(_ ventas: [Venta]) {
        let hoy = Date()
        let ayer = Calendar.current.date(byAdding: .day, value: -1, to: hoy) ?? hoy
        let totalHoy = totalEnDia(ventas, hoy)
        let totalAyer = totalEnDia(ventas, ayer)
        let diferencia = totalHoy - totalAyer

        etiquetaComparacion.text = String(
            format: "Vendido hoy: S/. %.2f (ayer: S/. %.2f, %@%.2f)",
            totalHoy, totalAyer, diferencia >= 0 ? "+" : "", diferencia
        )
    }

    /// Gráfico de barras de los últimos 7 días, dibujado con UIViews de altura proporcional (sin librerías externas).
    private func actualizarGrafico(_ ventas: [Venta]) {
        filaGrafico.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let calendario = Calendar.current
        var totalesPorDia: [(dia: Date, total: Double)] = []
        for desplazamiento in stride(from: 6, through: 0, by: -1) {
            let dia = calendario.date(byAdding: .day, value: -desplazamiento, to: Date()) ?? Date()
            totalesPorDia.append((dia, totalEnDia(ventas, dia)))
        }

        let maximo = max(totalesPorDia.map { $0.total }.max() ?? 1, 1)
        let formateadorDia = DateFormatter()
        formateadorDia.dateFormat = "E"

        for (dia, total) in totalesPorDia {
            let columna = UIStackView()
            columna.axis = .vertical
            columna.alignment = .center
            columna.spacing = 4

            let barra = UIView()
            barra.backgroundColor = .systemBlue
            barra.layer.cornerRadius = 4
            let altura = max(4, CGFloat(total / maximo) * 100)
            barra.translatesAutoresizingMaskIntoConstraints = false
            barra.widthAnchor.constraint(equalToConstant: 20).isActive = true
            barra.heightAnchor.constraint(equalToConstant: altura).isActive = true

            let etiquetaDia = UILabel()
            etiquetaDia.text = formateadorDia.string(from: dia).capitalized
            etiquetaDia.font = .systemFont(ofSize: 11)
            etiquetaDia.textColor = .secondaryLabel

            let espaciador = UIView()
            espaciador.translatesAutoresizingMaskIntoConstraints = false
            espaciador.heightAnchor.constraint(greaterThanOrEqualToConstant: 0).isActive = true

            columna.addArrangedSubview(espaciador)
            columna.addArrangedSubview(barra)
            columna.addArrangedSubview(etiquetaDia)
            filaGrafico.addArrangedSubview(columna)
        }
    }

    /// Agrupa ventas no anuladas del mes por vendedor y ordena descendente por total.
    private func actualizarRanking(_ ventas: [Venta]) {
        stackRanking.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let inicioMes = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month], from: Date())) ?? Date()
        let delMes = ventas.filter { !$0.anulada && ($0.fecha ?? .distantPast) >= inicioMes }

        var totalesPorVendedor: [String: Double] = [:]
        for venta in delMes {
            let nombre = venta.vendedor?.nombre ?? "—"
            totalesPorVendedor[nombre, default: 0] += venta.total
        }

        let ordenado = totalesPorVendedor.sorted { $0.value > $1.value }
        if ordenado.isEmpty {
            stackRanking.addArrangedSubview(etiquetaSimple("Sin ventas este mes."))
        }
        for (nombre, total) in ordenado {
            stackRanking.addArrangedSubview(etiquetaSimple(String(format: "%@ — S/. %.2f", nombre, total)))
        }
    }

    private func actualizarStockBajo() {
        stackStockBajo.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let fetchRequest: NSFetchRequest<Producto> = Producto.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "stock <= 5")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "stock", ascending: true)]
        let productos = (try? context.fetch(fetchRequest)) ?? []

        if productos.isEmpty {
            stackStockBajo.addArrangedSubview(etiquetaSimple("Ningún producto con stock bajo."))
        }
        for producto in productos {
            stackStockBajo.addArrangedSubview(etiquetaSimple("\(producto.nombre ?? "")  ·  stock: \(producto.stock)"))
        }
    }

    private func etiquetaSimple(_ texto: String) -> UILabel {
        let etiqueta = UILabel()
        etiqueta.text = texto
        etiqueta.font = .systemFont(ofSize: 15)
        return etiqueta
    }
}
