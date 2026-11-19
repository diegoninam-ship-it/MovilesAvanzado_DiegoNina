// Desarrollado por: Diego Nina Malqui
//
// Pruebas de integracion: golpean la API real jsonplaceholder.typicode.com.
// Si no hay conexion a internet en el entorno, se saltan (XCTSkip) en vez de
// fallar, para no romper el resto de la suite.

import XCTest
@testable import Semana13_ConsumoAPI

final class IntegrationTests: XCTestCase {

    private func verificarConexion() async throws {
        do {
            _ = try await URLSession.shared.data(from: URL(string: "https://jsonplaceholder.typicode.com/users")!)
        } catch {
            throw XCTSkip("Sin conexion a internet en este entorno: \(error.localizedDescription)")
        }
    }

    func testFetchUsers_apiReal_devuelveListaConDatosValidos() async throws {
        try await verificarConexion()

        let vm = UserViewModel()
        let expectation = expectation(description: "fetchUsers real")
        vm.fetchUsers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            expectation.fulfill()
        }
        await fulfillment(of: [expectation], timeout: 10.0)

        XCTAssertFalse(vm.users.isEmpty, "La API real deberia devolver al menos un usuario")
        guard let primero = vm.users.first else { return }
        XCTAssertGreaterThan(primero.id, 0)
        XCTAssertFalse(primero.name.isEmpty)
        XCTAssertFalse(primero.email.isEmpty)
    }
}
