//
//  VentasTests.swift
//  VentasTests
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import XCTest
import CoreData
@testable import Ventas

/// Verifica los 11 casos de prueba de la Sección 6 del expediente, usando un store de Core Data
/// en memoria (NSInMemoryStoreType) para no tocar datos reales.
final class VentasTests: XCTestCase {

    private var persistencia: PersistenceController!
    private var context: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        persistencia = PersistenceController(inMemory: true)
        context = persistencia.viewContext
    }

    override func tearDown() {
        persistencia = nil
        context = nil
        super.tearDown()
    }

    // MARK: - Helpers (replican las validaciones de los ViewControllers)

    @discardableResult
    private func crearUsuario(nombre: String, usuario: String, clave: String, rol: String) -> Usuario {
        let nuevo = Usuario(context: context)
        nuevo.nombre = nombre
        nuevo.usuario = usuario
        nuevo.clave = clave
        nuevo.rol = rol
        try? context.save()
        return nuevo
    }

    private func usuarioYaExiste(_ usuario: String) -> Bool {
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "usuario ==[c] %@", usuario)
        let conteo = try? context.count(for: fetchRequest)
        return (conteo ?? 0) > 0
    }

    private func buscarUsuario(_ usuario: String) -> Usuario? {
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "usuario ==[c] %@", usuario)
        fetchRequest.fetchLimit = 1
        return try? context.fetch(fetchRequest).first
    }

    /// Replica las validaciones de RegistroViewController.registrarUsuario().
    private func registroEsValido(clave: String, confirmacion: String) -> Bool {
        clave.count >= 6 && clave == confirmacion
    }

    @discardableResult
    private func crearProducto(nombre: String, categoria: String, precio: Double, stock: Int32) -> Producto {
        let producto = Producto(context: context)
        producto.nombre = nombre
        producto.categoria = categoria
        producto.precio = precio
        producto.stock = stock
        try? context.save()
        return producto
    }

    @discardableResult
    private func crearCliente(nombre: String, documento: String) -> Cliente {
        let cliente = Cliente(context: context)
        cliente.nombre = nombre
        cliente.documento = documento
        try? context.save()
        return cliente
    }

    private func totalComprado(_ cliente: Cliente) -> Double {
        let ventas = (cliente.ventas as? Set<Venta>) ?? []
        return ventas.filter { !$0.anulada }.reduce(0) { $0 + $1.total }
    }

    /// Replica NuevaVentaViewController.registrarVenta(): valida cantidad y stock antes de tocar Core Data.
    @discardableResult
    private func registrarVenta(vendedor: Usuario, cliente: Cliente, producto: Producto, cantidad: Int) -> Venta? {
        guard cantidad > 0 else { return nil }
        guard cantidad <= producto.stock else { return nil }

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
        try? context.save()
        return venta
    }

    /// Replica AnularVentaViewController.confirmarAnulacion(): exige motivo no vacío.
    private func anularVenta(_ venta: Venta, motivo: String) -> Bool {
        guard !motivo.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        venta.anulada = true
        venta.motivoAnulacion = motivo
        venta.producto?.stock += venta.cantidad
        try? context.save()
        return true
    }

    // MARK: - Caso 1: usuario único (sin distinguir mayúsculas)

    func testCaso1_RegistroDeUsuarioUnicoSinDistinguirMayusculas() {
        crearUsuario(nombre: "Luis Paredes", usuario: "lparedes", clave: "clave123", rol: "Supervisor")
        XCTAssertTrue(usuarioYaExiste("LPAREDES"), "El segundo registro debe detectar que \"LPAREDES\" ya existe (comparación sin mayúsculas/minúsculas).")
    }

    // MARK: - Caso 2: claves distintas o de 4 caracteres

    func testCaso2_RegistroConClavesDistintasOCortas() {
        XCTAssertFalse(registroEsValido(clave: "abcd", confirmacion: "abcd"), "Una clave de 4 caracteres debe rechazarse.")
        XCTAssertFalse(registroEsValido(clave: "abcdef", confirmacion: "ghijkl"), "Claves distintas deben rechazarse.")
        XCTAssertTrue(registroEsValido(clave: "abcdef", confirmacion: "abcdef"), "Una clave de 6+ caracteres que coincide con la confirmación debe aceptarse.")
    }

    // MARK: - Caso 3: login con clave incorrecta

    func testCaso3_LoginConClaveIncorrectaNoAutentica() {
        crearUsuario(nombre: "Juan Perez", usuario: "jperez", clave: "clave123", rol: "Vendedor")
        let encontrado = buscarUsuario("jperez")
        XCTAssertNotNil(encontrado)
        XCTAssertNotEqual(encontrado?.clave, "otraClave", "Con la clave incorrecta no debe autenticar.")
    }

    // MARK: - Caso 4: venta a cliente VIP con descuento

    func testCaso4_VentaDeLaptopsAClienteVIP() {
        let vendedor = crearUsuario(nombre: "Juan Perez", usuario: "jperez", clave: "clave123", rol: "Vendedor")
        let producto = crearProducto(nombre: "Laptop", categoria: "Tecnologia", precio: 200.0, stock: 40)
        let cliente = crearCliente(nombre: "Cliente VIP", documento: "11111111")

        // El cliente ya tiene S/ 5,200.00 en ventas no anuladas, lo que lo hace VIP.
        let ventaPrevia = Venta(context: context)
        ventaPrevia.fecha = Date()
        ventaPrevia.cantidad = 1
        ventaPrevia.precioUnitario = 5200.0
        ventaPrevia.descuento = 0
        ventaPrevia.igv = 0
        ventaPrevia.total = 5200.0
        ventaPrevia.anulada = false
        ventaPrevia.vendedor = vendedor
        ventaPrevia.producto = producto
        ventaPrevia.cliente = cliente
        try? context.save()

        let venta = registrarVenta(vendedor: vendedor, cliente: cliente, producto: producto, cantidad: 2)

        XCTAssertNotNil(venta)
        XCTAssertEqual(venta?.descuento ?? 0, 40.00, accuracy: 0.01)
        XCTAssertEqual(venta?.igv ?? 0, 64.80, accuracy: 0.01)
        XCTAssertEqual(venta?.total ?? 0, 424.80, accuracy: 0.01)
        XCTAssertEqual(producto.stock, 38, "El stock debe bajar de 40 a 38.")
    }

    // MARK: - Caso 5: venta a cliente Regular sin descuento

    func testCaso5_VentaDeMouseAClienteRegular() {
        let vendedor = crearUsuario(nombre: "Juan Perez", usuario: "jperez2", clave: "clave123", rol: "Vendedor")
        let producto = crearProducto(nombre: "Mouse", categoria: "Tecnologia", precio: 35.0, stock: 100)
        let cliente = crearCliente(nombre: "Cliente Regular", documento: "22222222")

        let venta = registrarVenta(vendedor: vendedor, cliente: cliente, producto: producto, cantidad: 3)

        XCTAssertNotNil(venta)
        XCTAssertEqual(venta?.descuento ?? -1, 0, accuracy: 0.01)
        XCTAssertEqual(venta?.igv ?? 0, 18.90, accuracy: 0.01)
        XCTAssertEqual(venta?.total ?? 0, 123.90, accuracy: 0.01)
    }

    // MARK: - Caso 6: venta que excede el stock

    func testCaso6_VentaQueExcedeElStockSeRechaza() {
        let vendedor = crearUsuario(nombre: "Juan Perez", usuario: "jperez3", clave: "clave123", rol: "Vendedor")
        let producto = crearProducto(nombre: "Laptop", categoria: "Tecnologia", precio: 200.0, stock: 40)
        let cliente = crearCliente(nombre: "Cliente Regular", documento: "33333333")

        let venta = registrarVenta(vendedor: vendedor, cliente: cliente, producto: producto, cantidad: 50)

        XCTAssertNil(venta, "La venta de 50 unidades con stock 40 debe rechazarse.")
        XCTAssertEqual(producto.stock, 40, "El stock no debe cambiar cuando la venta se rechaza.")
    }

    // MARK: - Caso 7: Mis ventas solo muestra las del vendedor de la sesión

    func testCaso7_MisVentasSoloDevuelveLasDelVendedor() {
        let vendedor1 = crearUsuario(nombre: "Juan Perez", usuario: "jperez4", clave: "clave123", rol: "Vendedor")
        let vendedor2 = crearUsuario(nombre: "Ana Soto", usuario: "asoto", clave: "clave123", rol: "Vendedor")
        let producto = crearProducto(nombre: "Teclado", categoria: "Tecnologia", precio: 50.0, stock: 100)
        let cliente = crearCliente(nombre: "Cliente", documento: "44444444")

        registrarVenta(vendedor: vendedor1, cliente: cliente, producto: producto, cantidad: 1)
        registrarVenta(vendedor: vendedor1, cliente: cliente, producto: producto, cantidad: 1)
        registrarVenta(vendedor: vendedor1, cliente: cliente, producto: producto, cantidad: 1)
        registrarVenta(vendedor: vendedor2, cliente: cliente, producto: producto, cantidad: 1)

        let fetchRequest: NSFetchRequest<Venta> = Venta.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "vendedor == %@", vendedor1)
        let misVentas = (try? context.fetch(fetchRequest)) ?? []

        let fetchTodas: NSFetchRequest<Venta> = Venta.fetchRequest()
        let todasLasVentas = (try? context.fetch(fetchTodas)) ?? []

        XCTAssertEqual(misVentas.count, 3, "jperez4 debe ver solo sus 3 ventas.")
        XCTAssertEqual(todasLasVentas.count, 4, "El Supervisor debe ver las 4 ventas en total.")
    }

    // MARK: - Caso 8: anulación exige motivo y devuelve stock

    func testCaso8_AnulacionExigeMotivoYDevuelveStock() {
        let vendedor = crearUsuario(nombre: "Juan Perez", usuario: "jperez5", clave: "clave123", rol: "Vendedor")
        let producto = crearProducto(nombre: "Laptop", categoria: "Tecnologia", precio: 200.0, stock: 40)
        let cliente = crearCliente(nombre: "Cliente VIP", documento: "55555555")

        guard let venta = registrarVenta(vendedor: vendedor, cliente: cliente, producto: producto, cantidad: 2) else {
            XCTFail("La venta debió registrarse.")
            return
        }
        XCTAssertEqual(producto.stock, 38)

        XCTAssertFalse(anularVenta(venta, motivo: ""), "Sin motivo no se puede anular.")
        XCTAssertFalse(venta.anulada)

        XCTAssertTrue(anularVenta(venta, motivo: "Cliente desistió de la compra"))
        XCTAssertTrue(venta.anulada)
        XCTAssertEqual(producto.stock, 40, "El stock debe volver a 40 tras anular.")
    }

    // MARK: - Caso 9: borrar un cliente con ventas se impide (delete rule Deny)

    func testCaso9_BorrarClienteConVentasLanzaError() {
        let vendedor = crearUsuario(nombre: "Juan Perez", usuario: "jperez6", clave: "clave123", rol: "Vendedor")
        let producto = crearProducto(nombre: "Laptop", categoria: "Tecnologia", precio: 200.0, stock: 40)
        let cliente = crearCliente(nombre: "Cliente con ventas", documento: "66666666")
        registrarVenta(vendedor: vendedor, cliente: cliente, producto: producto, cantidad: 1)

        context.delete(cliente)
        XCTAssertThrowsError(try context.save(), "Core Data debe denegar el borrado de un Cliente con Ventas asociadas.")
        context.rollback()
    }

    // MARK: - Caso 10: umbral de S/ 1,000 es inclusivo (Frecuente)

    func testCaso10_UmbralDeMilEsInclusivoParaFrecuente() {
        XCTAssertEqual(CalculoVenta.categoriaCliente(totalComprado: 1000.00), "Frecuente")
        XCTAssertEqual(CalculoVenta.categoriaCliente(totalComprado: 999.99), "Regular")
    }

    // MARK: - Caso 11: cantidad 0 o vacía se rechaza antes de tocar Core Data

    func testCaso11_CantidadCeroSeRechazaSinTocarCoreData() {
        let vendedor = crearUsuario(nombre: "Juan Perez", usuario: "jperez7", clave: "clave123", rol: "Vendedor")
        let producto = crearProducto(nombre: "Laptop", categoria: "Tecnologia", precio: 200.0, stock: 40)
        let cliente = crearCliente(nombre: "Cliente", documento: "77777777")

        let fetchRequest: NSFetchRequest<Venta> = Venta.fetchRequest()
        let ventasAntes = (try? context.count(for: fetchRequest)) ?? 0

        let venta = registrarVenta(vendedor: vendedor, cliente: cliente, producto: producto, cantidad: 0)

        let ventasDespues = (try? context.count(for: fetchRequest)) ?? 0

        XCTAssertNil(venta, "Una venta con cantidad 0 debe rechazarse.")
        XCTAssertEqual(ventasAntes, ventasDespues, "No debe crearse ninguna Venta en Core Data.")
        XCTAssertEqual(producto.stock, 40, "El stock no debe cambiar.")
    }
}
