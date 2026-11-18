//
//  AnularVentaViewController.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import UIKit

/// Pantalla A8: confirma la anulación de una venta con motivo obligatorio.
final class AnularVentaViewController: UIViewController {

    private let venta: Venta
    private let alAnular: () -> Void

    private let etiquetaResumen = UILabel()
    private let etiquetaAviso = UILabel()
    private let campoMotivo = UITextField()
    private let botonAnular = UIButton(type: .system)

    init(venta: Venta, alAnular: @escaping () -> Void) {
        self.venta = venta
        self.alAnular = alAnular
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) no implementado")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Anular venta"
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel, target: self, action: #selector(cancelar)
        )
        construirUI()
    }

    private func construirUI() {
        etiquetaResumen.numberOfLines = 0
        etiquetaResumen.text = String(
            format: "%@ · %@\nCantidad: %d\nTotal: S/. %.2f",
            venta.producto?.nombre ?? "", venta.cliente?.nombre ?? "", venta.cantidad, venta.total
        )

        etiquetaAviso.numberOfLines = 0
        etiquetaAviso.textColor = .secondaryLabel
        etiquetaAviso.font = .systemFont(ofSize: 13)
        etiquetaAviso.text = "El stock del producto se devolverá (+\(venta.cantidad)) al anular esta venta."

        campoMotivo.placeholder = "Motivo de la anulación"
        campoMotivo.borderStyle = .roundedRect
        campoMotivo.addTarget(self, action: #selector(motivoCambio), for: .editingChanged)

        botonAnular.setTitle("Anular", for: .normal)
        botonAnular.isEnabled = false
        botonAnular.addTarget(self, action: #selector(confirmarAnulacion), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [etiquetaResumen, etiquetaAviso, campoMotivo, botonAnular])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }

    @objc private func motivoCambio() {
        let texto = campoMotivo.text ?? ""
        botonAnular.isEnabled = !texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @objc private func confirmarAnulacion() {
        let motivo = (campoMotivo.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !motivo.isEmpty else { return }

        venta.anulada = true
        venta.motivoAnulacion = motivo
        if let producto = venta.producto {
            producto.stock += venta.cantidad
        }
        PersistenceController.shared.guardar()

        alAnular()
        dismiss(animated: true)
    }

    @objc private func cancelar() {
        dismiss(animated: true)
    }
}
