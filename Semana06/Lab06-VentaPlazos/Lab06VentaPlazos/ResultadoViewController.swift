//
//  ResultadoViewController.swift
//  Lab06VentaPlazos
//

import UIKit

class ResultadoViewController: UIViewController {

    var venta: VentaModel?

    private let contentStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = venta?.nombreProducto ?? "Resultado"
        configurarUI()
        mostrarResultado()
    }

    // MARK: - UI por codigo

    private func configurarUI() {
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    private func mostrarResultado() {
        guard let venta = venta else { return }

        contentStack.addArrangedSubview(filaResultado(etiqueta: "Subtotal", valor: venta.subtotal))
        contentStack.addArrangedSubview(filaResultado(etiqueta: "IGV", valor: venta.igv))
        contentStack.addArrangedSubview(filaResultado(etiqueta: "Monto base", valor: venta.base))
        contentStack.addArrangedSubview(filaResultado(etiqueta: "Intereses totales", valor: venta.intereses))
        contentStack.addArrangedSubview(filaResultado(etiqueta: "Total a pagar", valor: venta.total))
        contentStack.addArrangedSubview(filaResultado(etiqueta: "Cuota mensual", valor: venta.cuota))
    }

    private func filaResultado(etiqueta: String, valor: Double) -> UIStackView {
        let labelEtiqueta = UILabel()
        labelEtiqueta.text = etiqueta
        labelEtiqueta.font = .systemFont(ofSize: 16, weight: .medium)

        let labelValor = UILabel()
        labelValor.text = String(format: "S/. %.2f", valor)
        labelValor.font = .systemFont(ofSize: 16, weight: .semibold)
        labelValor.textAlignment = .right

        let fila = UIStackView(arrangedSubviews: [labelEtiqueta, labelValor])
        fila.axis = .horizontal
        fila.distribution = .fillEqually
        return fila
    }
}
