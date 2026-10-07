//
//  NuevaVentaViewController.swift
//  Lab06VentaPlazos
//

import UIKit

class NuevaVentaViewController: UIViewController {

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let tfNombreProducto = UITextField()
    private let tfPrecioUnitario = UITextField()
    private let tfCantidad = UITextField()
    private let tfMeses = UITextField()
    private let tfTasaMensual = UITextField()
    private let btnCalcular = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Nueva Venta"
        view.backgroundColor = .systemBackground
        configurarUI()
    }

    // MARK: - UI por codigo

    private func configurarUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        contentStack.addArrangedSubview(campoConLabel(texto: "Nombre del electrodomestico", campo: tfNombreProducto, teclado: .default))
        contentStack.addArrangedSubview(campoConLabel(texto: "Precio unitario (S/.)", campo: tfPrecioUnitario, teclado: .decimalPad))
        contentStack.addArrangedSubview(campoConLabel(texto: "Cantidad", campo: tfCantidad, teclado: .numberPad))
        contentStack.addArrangedSubview(campoConLabel(texto: "Numero de meses", campo: tfMeses, teclado: .numberPad))
        contentStack.addArrangedSubview(campoConLabel(texto: "Tasa de interes mensual (%)", campo: tfTasaMensual, teclado: .decimalPad))

        btnCalcular.setTitle("Calcular", for: .normal)
        btnCalcular.addTarget(self, action: #selector(calcularPresionado), for: .touchUpInside)
        contentStack.addArrangedSubview(btnCalcular)
    }

    private func campoConLabel(texto: String, campo: UITextField, teclado: UIKeyboardType) -> UIStackView {
        let label = UILabel()
        label.text = texto
        label.font = .systemFont(ofSize: 15, weight: .medium)

        campo.borderStyle = .roundedRect
        campo.keyboardType = teclado

        let stack = UIStackView(arrangedSubviews: [label, campo])
        stack.axis = .vertical
        stack.spacing = 6
        return stack
    }

    // MARK: - Calculo y validacion

    @objc private func calcularPresionado() {
        guard let nombre = tfNombreProducto.text, !nombre.trimmingCharacters(in: .whitespaces).isEmpty else {
            mostrarError("Ingrese el nombre del electrodomestico.")
            return
        }
        guard let precioTexto = tfPrecioUnitario.text, let precioUnitario = Double(precioTexto), precioUnitario > 0 else {
            mostrarError("Ingrese un precio unitario valido mayor a 0.")
            return
        }
        guard let cantidadTexto = tfCantidad.text, let cantidad = Int(cantidadTexto), cantidad > 0 else {
            mostrarError("Ingrese una cantidad valida mayor a 0.")
            return
        }
        guard let mesesTexto = tfMeses.text, let meses = Int(mesesTexto), meses > 0 else {
            mostrarError("Ingrese un numero de meses valido mayor a 0.")
            return
        }
        guard let tasaTexto = tfTasaMensual.text, let tasaMensual = Double(tasaTexto), tasaMensual >= 0 else {
            mostrarError("Ingrese una tasa de interes mensual valida (0 o mayor).")
            return
        }

        let subtotal = precioUnitario * Double(cantidad)
        let igv = subtotal * 0.18
        let base = subtotal + igv
        let intereses = base * (tasaMensual / 100) * Double(meses)
        let total = base + intereses
        let cuota = total / Double(meses)

        let venta = VentaModel(
            nombreProducto: nombre,
            subtotal: subtotal,
            igv: igv,
            base: base,
            intereses: intereses,
            total: total,
            cuota: cuota
        )

        performSegue(withIdentifier: "showResultado", sender: venta)
    }

    private func mostrarError(_ mensaje: String) {
        let alerta = UIAlertController(title: "Datos invalidos", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alerta, animated: true)
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "showResultado",
              let resultadoVC = segue.destination as? ResultadoViewController,
              let venta = sender as? VentaModel else {
            return
        }
        resultadoVC.venta = venta
    }
}
