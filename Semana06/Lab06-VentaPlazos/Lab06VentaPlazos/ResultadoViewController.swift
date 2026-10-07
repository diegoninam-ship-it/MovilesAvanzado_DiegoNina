//
//  ResultadoViewController.swift
//  Lab06VentaPlazos
//

import UIKit

class ResultadoViewController: UIViewController {

    var venta: VentaModel?

    private let colorMarca = UIColor(red: 0x1A / 255.0, green: 0x33 / 255.0, blue: 0x61 / 255.0, alpha: 1.0)

    private let cardView = UIView()
    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        title = venta?.nombreProducto ?? "Resultado"
        configurarUI()
        mostrarResultado()
    }

    // MARK: - UI por codigo

    private func configurarUI() {
        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 16
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 6
        cardView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cardView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            contentStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 20),
            contentStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -20)
        ])
    }

    private func mostrarResultado() {
        guard let venta = venta else { return }

        contentStack.addArrangedSubview(filaResultado(etiqueta: "Subtotal", valor: venta.subtotal, destacado: false))
        contentStack.addArrangedSubview(filaResultado(etiqueta: "IGV", valor: venta.igv, destacado: false))
        contentStack.addArrangedSubview(filaResultado(etiqueta: "Monto base", valor: venta.base, destacado: false))
        contentStack.addArrangedSubview(filaResultado(etiqueta: "Intereses totales", valor: venta.intereses, destacado: false))
        contentStack.addArrangedSubview(filaResultado(etiqueta: "Total a pagar", valor: venta.total, destacado: true))
        contentStack.addArrangedSubview(filaResultado(etiqueta: "Cuota mensual", valor: venta.cuota, destacado: true))
    }

    private func filaResultado(etiqueta: String, valor: Double, destacado: Bool) -> UIStackView {
        let labelEtiqueta = UILabel()
        labelEtiqueta.text = etiqueta.uppercased()
        labelEtiqueta.font = .systemFont(ofSize: destacado ? 15 : 13, weight: .semibold)
        labelEtiqueta.textColor = destacado ? colorMarca : .darkGray

        let labelValor = UILabel()
        labelValor.text = String(format: "S/. %.2f", valor)
        labelValor.font = .systemFont(ofSize: destacado ? 20 : 16, weight: destacado ? .bold : .semibold)
        labelValor.textColor = destacado ? colorMarca : .label
        labelValor.textAlignment = .right

        let fila = UIStackView(arrangedSubviews: [labelEtiqueta, labelValor])
        fila.axis = .horizontal
        fila.distribution = .fillEqually
        fila.alignment = .center
        return fila
    }
}
