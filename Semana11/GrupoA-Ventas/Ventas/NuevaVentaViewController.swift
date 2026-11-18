//
//  NuevaVentaViewController.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import UIKit
import CoreData

/// Pantalla A5: registra una venta con cálculo en vivo (subtotal, descuento, IGV, total) y control de stock.
final class NuevaVentaViewController: UIViewController {

    private let context: NSManagedObjectContext

    private let etiquetaVendedor = UILabel()
    private let botonCliente = UIButton(type: .system)
    private let botonProducto = UIButton(type: .system)
    private let etiquetaStock = UILabel()
    private let stepperCantidad = UIStepper()
    private let etiquetaCantidad = UILabel()
    private let etiquetaResumen = UILabel()
    private let botonRegistrar = UIButton(type: .system)

    private var clientes: [Cliente] = []
    private var productos: [Producto] = []
    private var clienteSeleccionado: Cliente?
    private var productoSeleccionado: Producto? {
        didSet { actualizarStockYResumen() }
    }

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
        title = "Venta"
        construirUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cargarDatos()
    }

    // MARK: - UI

    private func construirUI() {
        etiquetaVendedor.text = "Vendedor: \(SesionUsuario.shared.usuarioActual?.nombre ?? "")"
        etiquetaVendedor.font = .systemFont(ofSize: 16, weight: .medium)

        botonCliente.setTitle("Seleccionar cliente", for: .normal)
        botonCliente.addTarget(self, action: #selector(elegirCliente), for: .touchUpInside)

        botonProducto.setTitle("Seleccionar producto", for: .normal)
        botonProducto.addTarget(self, action: #selector(elegirProducto), for: .touchUpInside)

        etiquetaStock.font = .systemFont(ofSize: 13)
        etiquetaStock.textColor = .secondaryLabel

        stepperCantidad.minimumValue = 1
        stepperCantidad.maximumValue = 1
        stepperCantidad.value = 1
        stepperCantidad.isEnabled = false
        stepperCantidad.addTarget(self, action: #selector(cantidadCambio), for: .valueChanged)

        etiquetaCantidad.font = .systemFont(ofSize: 16, weight: .medium)
        etiquetaCantidad.text = "Cantidad: 1"

        let filaCantidad = UIStackView(arrangedSubviews: [etiquetaCantidad, stepperCantidad])
        filaCantidad.axis = .horizontal
        filaCantidad.spacing = 16

        etiquetaResumen.font = .monospacedSystemFont(ofSize: 15, weight: .regular)
        etiquetaResumen.numberOfLines = 0
        actualizarResumenVacio()

        botonRegistrar.setTitle("Registrar venta", for: .normal)
        botonRegistrar.addTarget(self, action: #selector(registrarVenta), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            etiquetaVendedor, botonCliente, botonProducto, etiquetaStock,
            filaCantidad, etiquetaResumen, botonRegistrar
        ])
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

    // MARK: - Datos

    private func cargarDatos() {
        let fetchClientes: NSFetchRequest<Cliente> = Cliente.fetchRequest()
        fetchClientes.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        clientes = (try? context.fetch(fetchClientes)) ?? []

        let fetchProductos: NSFetchRequest<Producto> = Producto.fetchRequest()
        fetchProductos.sortDescriptors = [NSSortDescriptor(key: "nombre", ascending: true)]
        productos = (try? context.fetch(fetchProductos)) ?? []
    }

    @objc private func elegirCliente() {
        guard !clientes.isEmpty else { return }
        let alerta = UIAlertController(title: "Cliente", message: nil, preferredStyle: .actionSheet)
        for cliente in clientes {
            alerta.addAction(UIAlertAction(title: cliente.nombre, style: .default) { [weak self] _ in
                self?.clienteSeleccionado = cliente
                self?.botonCliente.setTitle(cliente.nombre, for: .normal)
            })
        }
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alerta.popoverPresentationController?.sourceView = botonCliente
        present(alerta, animated: true)
    }

    @objc private func elegirProducto() {
        guard !productos.isEmpty else { return }
        let alerta = UIAlertController(title: "Producto", message: nil, preferredStyle: .actionSheet)
        for producto in productos {
            alerta.addAction(UIAlertAction(title: "\(producto.nombre ?? "") (stock: \(producto.stock))", style: .default) { [weak self] _ in
                self?.productoSeleccionado = producto
                self?.botonProducto.setTitle(producto.nombre, for: .normal)
            })
        }
        alerta.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        alerta.popoverPresentationController?.sourceView = botonProducto
        present(alerta, animated: true)
    }

    @objc private func cantidadCambio() {
        etiquetaCantidad.text = "Cantidad: \(Int(stepperCantidad.value))"
        actualizarResumen()
    }

    private func actualizarStockYResumen() {
        guard let producto = productoSeleccionado else {
            stepperCantidad.isEnabled = false
            etiquetaStock.text = nil
            actualizarResumenVacio()
            return
        }
        etiquetaStock.text = "Stock disponible: \(producto.stock)"
        stepperCantidad.isEnabled = producto.stock > 0
        stepperCantidad.minimumValue = 1
        stepperCantidad.maximumValue = Double(max(producto.stock, 1))
        stepperCantidad.value = 1
        etiquetaCantidad.text = "Cantidad: 1"
        actualizarResumen()
    }

    private func actualizarResumenVacio() {
        etiquetaResumen.text = "Subtotal: S/. 0.00\nDescuento: S/. 0.00\nIGV: S/. 0.00\nTotal: S/. 0.00"
    }

    private func actualizarResumen() {
        guard let producto = productoSeleccionado else {
            actualizarResumenVacio()
            return
        }
        let cantidad = Int(stepperCantidad.value)
        let esVIP = clienteSeleccionado.map { CalculoVenta.categoriaCliente(totalComprado: totalComprado($0)) == "VIP" } ?? false

        let subtotal = CalculoVenta.subtotal(precioUnitario: producto.precio, cantidad: cantidad)
        let descuento = CalculoVenta.descuento(subtotal: subtotal, esVIP: esVIP)
        let igv = CalculoVenta.igv(subtotal: subtotal, descuento: descuento)
        let total = CalculoVenta.total(subtotal: subtotal, descuento: descuento, igv: igv)

        etiquetaResumen.text = String(
            format: "Subtotal: S/. %.2f\nDescuento: S/. %.2f\nIGV: S/. %.2f\nTotal: S/. %.2f",
            subtotal, descuento, igv, total
        )
    }

    private func totalComprado(_ cliente: Cliente) -> Double {
        let ventas = (cliente.ventas as? Set<Venta>) ?? []
        return ventas.filter { !$0.anulada }.reduce(0) { $0 + $1.total }
    }

    // MARK: - Registrar

    @objc private func registrarVenta() {
        guard let cliente = clienteSeleccionado, let producto = productoSeleccionado else {
            mostrarError("Selecciona un cliente y un producto.")
            return
        }

        let cantidad = Int(stepperCantidad.value)
        guard cantidad > 0 else {
            mostrarError("La cantidad debe ser mayor a 0.")
            return
        }

        // No se permite vender más de lo que hay en stock; si excede, se avisa y no se registra (el stock no cambia).
        guard cantidad <= producto.stock else {
            mostrarError("No hay stock suficiente. Disponible: \(producto.stock).")
            return
        }

        guard let vendedor = SesionUsuario.shared.usuarioActual else { return }

        let esVIP = CalculoVenta.categoriaCliente(totalComprado: totalComprado(cliente)) == "VIP"
        let subtotal = CalculoVenta.subtotal(precioUnitario: producto.precio, cantidad: cantidad)
        let descuento = CalculoVenta.descuento(subtotal: subtotal, esVIP: esVIP)
        let igv = CalculoVenta.igv(subtotal: subtotal, descuento: descuento)
        let total = CalculoVenta.total(subtotal: subtotal, descuento: descuento, igv: igv)

        let venta = Venta(context: context)
        venta.fecha = Date()
        venta.cantidad = Int32(cantidad)
        venta.precioUnitario = producto.precio
        venta.descuento = descuento
        venta.igv = igv
        venta.total = total
        venta.anulada = false
        venta.vendedor = vendedor
        venta.producto = producto
        venta.cliente = cliente

        producto.stock -= Int32(cantidad)

        PersistenceController.shared.guardar()
        limpiarFormulario()

        let confirmacion = UIAlertController(
            title: "Venta registrada",
            message: String(format: "Total: S/. %.2f", total),
            preferredStyle: .alert
        )
        confirmacion.addAction(UIAlertAction(title: "OK", style: .default))
        present(confirmacion, animated: true)
    }

    private func limpiarFormulario() {
        clienteSeleccionado = nil
        productoSeleccionado = nil
        botonCliente.setTitle("Seleccionar cliente", for: .normal)
        botonProducto.setTitle("Seleccionar producto", for: .normal)
        cargarDatos()
    }

    private func mostrarError(_ mensaje: String) {
        let alerta = UIAlertController(title: "No se pudo registrar", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        present(alerta, animated: true)
    }
}
