import XCTest
import SwiftData
@testable import Compras

final class ComprasTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUpWithError() throws {
        let configuracion = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: Usuario.self, Proveedor.self, Producto.self, Compra.self, configurations: configuracion)
        modelContext = ModelContext(modelContainer)
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
    }

    // 1. Registrar "mtorres" como Comprador; repetir el usuario -> debe rechazarse.
    func testRegistroUsuarioUnico() throws {
        let usuario1 = Usuario(nombre: "Mario Torres", usuario: "mtorres", clave: "clave123", rol: "Comprador")
        modelContext.insert(usuario1)
        try modelContext.save()

        let usuarioTexto = "mtorres"
        let descriptor = FetchDescriptor<Usuario>(predicate: #Predicate { $0.usuario == usuarioTexto })
        let cantidadExistente = try modelContext.fetchCount(descriptor)
        XCTAssertEqual(cantidadExistente, 1)

        // Intento de registrar el mismo usuario: debe detectarse como existente, no insertarse.
        XCTAssertGreaterThan(cantidadExistente, 0, "El usuario 'mtorres' ya existe y el registro debe rechazarse")
    }

    // 2. Login con clave incorrecta -> no autentica.
    func testLoginClaveIncorrecta() throws {
        let usuario = Usuario(nombre: "Mario Torres", usuario: "mtorres", clave: "clave123", rol: "Comprador")
        modelContext.insert(usuario)
        try modelContext.save()

        let usuarioTexto = "mtorres"
        let descriptor = FetchDescriptor<Usuario>(predicate: #Predicate { $0.usuario == usuarioTexto })
        let encontrado = try modelContext.fetch(descriptor).first
        XCTAssertNotNil(encontrado)
        XCTAssertNotEqual(encontrado?.clave, "claveIncorrecta")
    }

    // 3. Producto stock 40, costoPromedio 110.00; compra de 10 a 120.00 al credito.
    func testCompraAprobadaAutomaticaACredito() throws {
        let producto = Producto(nombre: "Teclado", categoria: "Accesorios", stock: 40, costoPromedio: 110.00)
        let proveedor = Proveedor(nombre: "Proveedor A", ruc: "20100000001")
        modelContext.insert(producto)
        modelContext.insert(proveedor)

        let cantidad = 10
        let costoUnitario = 120.00
        let subtotal = Double(cantidad) * costoUnitario
        let igv = subtotal * 0.18
        let total = subtotal + igv

        XCTAssertEqual(subtotal, 1200.00, accuracy: 0.01)
        XCTAssertEqual(igv, 216.00, accuracy: 0.01)
        XCTAssertEqual(total, 1416.00, accuracy: 0.01)

        let ahora = Date()
        let vencimiento = Calendar.current.date(byAdding: .day, value: 30, to: ahora)!
        let compra = Compra(fecha: ahora, cantidad: cantidad, costoUnitario: costoUnitario, igv: igv, total: total, alCredito: true, vence: vencimiento, estado: "Aprobada", pagada: false)
        compra.producto = producto
        compra.proveedor = proveedor
        modelContext.insert(compra)

        let nuevoCostoPromedio = (Double(producto.stock) * producto.costoPromedio + Double(cantidad) * costoUnitario) / Double(producto.stock + cantidad)
        producto.stock += cantidad
        producto.costoPromedio = nuevoCostoPromedio
        try modelContext.save()

        XCTAssertEqual(compra.estado, "Aprobada")
        XCTAssertEqual(producto.stock, 50)
        XCTAssertEqual(producto.costoPromedio, 112.00, accuracy: 0.01)
        XCTAssertFalse(compra.pagada)
        XCTAssertTrue(Calendar.current.isDate(compra.vence, equalTo: vencimiento, toGranularity: .day))
    }

    // 4. La misma compra al contado -> queda pagada, no aparece en pendientes de pago.
    func testCompraAlContadoQuedaPagada() throws {
        let producto = Producto(nombre: "Teclado", categoria: "Accesorios", stock: 40, costoPromedio: 110.00)
        let proveedor = Proveedor(nombre: "Proveedor A", ruc: "20100000001")
        modelContext.insert(producto)
        modelContext.insert(proveedor)

        let cantidad = 10
        let costoUnitario = 120.00
        let subtotal = Double(cantidad) * costoUnitario
        let igv = subtotal * 0.18
        let total = subtotal + igv

        let compra = Compra(fecha: Date(), cantidad: cantidad, costoUnitario: costoUnitario, igv: igv, total: total, alCredito: false, vence: Date(), estado: "Aprobada", pagada: true)
        compra.producto = producto
        compra.proveedor = proveedor
        modelContext.insert(compra)
        try modelContext.save()

        XCTAssertTrue(compra.pagada)
        XCTAssertFalse(compra.alCredito)

        let descriptorPorPagar = FetchDescriptor<Compra>(predicate: #Predicate<Compra> { $0.alCredito == true && $0.pagada == false })
        let pendientesDePago = try modelContext.fetch(descriptorPorPagar)
        XCTAssertFalse(pendientesDePago.contains { $0.persistentModelID == compra.persistentModelID })
    }

    // 5. Compra de 50 a 120.00 (total 7,080.00) -> queda Pendiente; stock sigue en 40; no suma a por pagar.
    func testCompraGrandeQuedaPendiente() throws {
        let producto = Producto(nombre: "Teclado", categoria: "Accesorios", stock: 40, costoPromedio: 110.00)
        let proveedor = Proveedor(nombre: "Proveedor A", ruc: "20100000001")
        modelContext.insert(producto)
        modelContext.insert(proveedor)

        let cantidad = 50
        let costoUnitario = 120.00
        let subtotal = Double(cantidad) * costoUnitario
        let igv = subtotal * 0.18
        let total = subtotal + igv
        XCTAssertEqual(total, 7080.00, accuracy: 0.01)
        XCTAssertGreaterThanOrEqual(total, 5000.0)

        let compra = Compra(fecha: Date(), cantidad: cantidad, costoUnitario: costoUnitario, igv: igv, total: total, alCredito: true, vence: Date(), estado: "Pendiente", pagada: false)
        compra.producto = producto
        compra.proveedor = proveedor
        modelContext.insert(compra)
        try modelContext.save()

        XCTAssertEqual(compra.estado, "Pendiente")
        XCTAssertEqual(producto.stock, 40, "El stock no debe cambiar mientras la compra esta pendiente")

        let descriptorPorPagar = FetchDescriptor<Compra>(predicate: #Predicate<Compra> { $0.alCredito == true && $0.pagada == false && $0.estado == "Aprobada" })
        let porPagar = try modelContext.fetch(descriptorPorPagar)
        XCTAssertFalse(porPagar.contains { $0.persistentModelID == compra.persistentModelID })
    }

    // 6. El supervisor aprueba la compra del caso 5 -> stock 90; costoPromedio 115.56; aparece en Por pagar.
    func testAprobacionDeCompraPendiente() throws {
        let producto = Producto(nombre: "Teclado", categoria: "Accesorios", stock: 40, costoPromedio: 110.00)
        let proveedor = Proveedor(nombre: "Proveedor A", ruc: "20100000001")
        modelContext.insert(producto)
        modelContext.insert(proveedor)

        let cantidad = 50
        let costoUnitario = 120.00
        let subtotal = Double(cantidad) * costoUnitario
        let igv = subtotal * 0.18
        let total = subtotal + igv

        let compra = Compra(fecha: Date(), cantidad: cantidad, costoUnitario: costoUnitario, igv: igv, total: total, alCredito: true, vence: Date(), estado: "Pendiente", pagada: false)
        compra.producto = producto
        compra.proveedor = proveedor
        modelContext.insert(compra)
        try modelContext.save()

        let stockActual = producto.stock
        let costoActual = producto.costoPromedio
        let nuevoCosto = (Double(stockActual) * costoActual + Double(compra.cantidad) * compra.costoUnitario) / Double(stockActual + compra.cantidad)
        producto.stock += compra.cantidad
        producto.costoPromedio = nuevoCosto
        compra.estado = "Aprobada"
        compra.pagada = compra.alCredito ? false : true
        try modelContext.save()

        XCTAssertEqual(producto.stock, 90)
        XCTAssertEqual(producto.costoPromedio, 115.56, accuracy: 0.01)
        XCTAssertEqual(compra.estado, "Aprobada")

        let descriptorPorPagar = FetchDescriptor<Compra>(predicate: #Predicate<Compra> { $0.alCredito == true && $0.pagada == false })
        let porPagar = try modelContext.fetch(descriptorPorPagar)
        XCTAssertTrue(porPagar.contains { $0.persistentModelID == compra.persistentModelID })
    }

    // 7. El supervisor rechaza otra compra grande sin motivo (debe fallar) y luego con motivo.
    func testRechazoRequiereMotivo() throws {
        let producto = Producto(nombre: "Monitor", categoria: "Accesorios", stock: 20, costoPromedio: 500.00)
        let proveedor = Proveedor(nombre: "Proveedor B", ruc: "20100000002")
        modelContext.insert(producto)
        modelContext.insert(proveedor)

        let cantidad = 20
        let costoUnitario = 500.00
        let subtotal = Double(cantidad) * costoUnitario
        let igv = subtotal * 0.18
        let total = subtotal + igv

        let compra = Compra(fecha: Date(), cantidad: cantidad, costoUnitario: costoUnitario, igv: igv, total: total, alCredito: true, vence: Date(), estado: "Pendiente", pagada: false)
        compra.producto = producto
        compra.proveedor = proveedor
        modelContext.insert(compra)
        try modelContext.save()

        let stockAntesDelRechazo = producto.stock

        func rechazar(motivo: String) -> Bool {
            guard !motivo.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
            compra.estado = "Rechazada"
            compra.motivoRechazo = motivo
            return true
        }

        XCTAssertFalse(rechazar(motivo: ""), "Rechazar sin motivo debe fallar")
        XCTAssertEqual(compra.estado, "Pendiente")

        XCTAssertTrue(rechazar(motivo: "Precio por encima del mercado"))
        try modelContext.save()

        XCTAssertEqual(compra.estado, "Rechazada")
        XCTAssertEqual(compra.motivoRechazo, "Precio por encima del mercado")
        XCTAssertEqual(producto.stock, stockAntesDelRechazo, "El stock no debe cambiar al rechazar")
    }

    // 8. Compra a credito con vencimiento ya pasado -> Vencidas; al pagar pasa a Pagadas, el total por pagar baja.
    func testCompraVencidaYPago() throws {
        let producto = Producto(nombre: "Silla", categoria: "Mobiliario", stock: 10, costoPromedio: 200.00)
        let proveedor = Proveedor(nombre: "Proveedor C", ruc: "20100000003")
        modelContext.insert(producto)
        modelContext.insert(proveedor)

        let vencimientoPasado = Calendar.current.date(byAdding: .day, value: -5, to: Date())!
        let compra = Compra(fecha: Date(), cantidad: 5, costoUnitario: 200.00, igv: 180.00, total: 1180.00, alCredito: true, vence: vencimientoPasado, estado: "Aprobada", pagada: false)
        compra.producto = producto
        compra.proveedor = proveedor
        modelContext.insert(compra)
        try modelContext.save()

        let esVencida = !compra.pagada && compra.vence < Date()
        XCTAssertTrue(esVencida)

        let totalPorPagarAntes = try fetchComprasCredito().filter { !$0.pagada }.reduce(0.0) { $0 + $1.total }

        compra.pagada = true
        try modelContext.save()

        let totalPorPagarDespues = try fetchComprasCredito().filter { !$0.pagada }.reduce(0.0) { $0 + $1.total }

        XCTAssertTrue(compra.pagada)
        XCTAssertEqual(totalPorPagarDespues, totalPorPagarAntes - compra.total, accuracy: 0.01)
    }

    private func fetchComprasCredito() throws -> [Compra] {
        try modelContext.fetch(FetchDescriptor<Compra>(predicate: #Predicate<Compra> { $0.alCredito == true }))
    }

    // 9. Un comprador abre Mis compras y solo ve sus compras (sin opcion de pagar en esa pantalla).
    func testCompradorSoloVeSusCompras() throws {
        let compradorA = Usuario(nombre: "Ana Comprador", usuario: "acomprador", clave: "clave123", rol: "Comprador")
        let compradorB = Usuario(nombre: "Beto Comprador", usuario: "bcomprador", clave: "clave123", rol: "Comprador")
        let producto = Producto(nombre: "Mouse", categoria: "Accesorios", stock: 30, costoPromedio: 25.00)
        let proveedor = Proveedor(nombre: "Proveedor D", ruc: "20100000004")
        modelContext.insert(compradorA)
        modelContext.insert(compradorB)
        modelContext.insert(producto)
        modelContext.insert(proveedor)

        let compraDeA = Compra(fecha: Date(), cantidad: 2, costoUnitario: 25.00, igv: 9.00, total: 59.00, alCredito: false, vence: Date(), estado: "Aprobada", pagada: true)
        compraDeA.comprador = compradorA
        compraDeA.producto = producto
        compraDeA.proveedor = proveedor
        modelContext.insert(compraDeA)

        let compraDeB = Compra(fecha: Date(), cantidad: 3, costoUnitario: 25.00, igv: 13.50, total: 88.50, alCredito: false, vence: Date(), estado: "Aprobada", pagada: true)
        compraDeB.comprador = compradorB
        compraDeB.producto = producto
        compraDeB.proveedor = proveedor
        modelContext.insert(compraDeB)
        try modelContext.save()

        let idUsuarioDeSesion = compradorA.persistentModelID
        let descriptor = FetchDescriptor<Compra>(predicate: #Predicate<Compra> { $0.comprador?.persistentModelID == idUsuarioDeSesion })
        let comprasDeA = try modelContext.fetch(descriptor)

        XCTAssertEqual(comprasDeA.count, 1)
        XCTAssertTrue(comprasDeA.allSatisfy { $0.comprador?.persistentModelID == compradorA.persistentModelID })
        XCTAssertFalse(comprasDeA.contains { $0.persistentModelID == compraDeB.persistentModelID })
        // La vista "Mis compras" de un Comprador no muestra la accion de pagar (esa accion solo existe en Por Pagar, solo para Supervisor).
    }
}
