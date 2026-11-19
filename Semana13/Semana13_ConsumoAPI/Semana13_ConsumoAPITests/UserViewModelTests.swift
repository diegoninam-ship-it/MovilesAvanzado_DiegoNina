// Desarrollado por: Diego Nina Malqui

import XCTest
@testable import Semana13_ConsumoAPI

final class UserViewModelTests: XCTestCase {

    // MARK: - filteredUsers (caja negra: particion de equivalencia)

    private func usuariosDePrueba() -> [User] {
        [
            User(id: 1, name: "Leanne Graham", username: "Bret", email: "leanne@april.biz"),
            User(id: 2, name: "Ervin Howell", username: "Antonette", email: "ervin@melissa.tv"),
            User(id: 3, name: "Clementine Bauch", username: "Samantha", email: "clementine@yesenia.net")
        ]
    }

    // 1. searchText vacio -> devuelve todos los usuarios.
    func testFilteredUsers_textoVacio_devuelveTodos() {
        let vm = UserViewModel(sesion: SesionDeRedSimulada())
        vm.users = usuariosDePrueba()
        vm.searchText = ""

        XCTAssertEqual(vm.filteredUsers.count, 3)
    }

    // 2. searchText sin ninguna coincidencia -> lista vacia.
    func testFilteredUsers_sinCoincidencias_listaVacia() {
        let vm = UserViewModel(sesion: SesionDeRedSimulada())
        vm.users = usuariosDePrueba()
        vm.searchText = "zzzzz"

        XCTAssertTrue(vm.filteredUsers.isEmpty)
    }

    // 3. searchText que coincide con el name de un solo usuario -> esa unica fila.
    func testFilteredUsers_coincideConName_unicaFila() {
        let vm = UserViewModel(sesion: SesionDeRedSimulada())
        vm.users = usuariosDePrueba()
        vm.searchText = "Leanne"

        XCTAssertEqual(vm.filteredUsers.count, 1)
        XCTAssertEqual(vm.filteredUsers.first?.id, 1)
    }

    // 4. searchText que coincide con el username (no el name) de un usuario.
    func testFilteredUsers_coincideConUsername_filtraCorrectamente() {
        let vm = UserViewModel(sesion: SesionDeRedSimulada())
        vm.users = usuariosDePrueba()
        vm.searchText = "Antonette"

        XCTAssertEqual(vm.filteredUsers.count, 1)
        XCTAssertEqual(vm.filteredUsers.first?.id, 2)
    }

    // 5. searchText que coincide con varios usuarios -> todas las coincidencias, ninguna de mas.
    func testFilteredUsers_coincideConVarios_todasLasCoincidencias() {
        let vm = UserViewModel(sesion: SesionDeRedSimulada())
        vm.users = usuariosDePrueba()
        vm.searchText = "e"

        let nombresEsperados = Set(usuariosDePrueba().map(\.name))
        let nombresObtenidos = Set(vm.filteredUsers.map(\.name))
        XCTAssertEqual(nombresObtenidos, nombresEsperados)
    }

    // 6. Mismo texto en mayusculas/minusculas mezcladas -> mismo resultado (case-insensitive).
    func testFilteredUsers_caseInsensitive() {
        let vm = UserViewModel(sesion: SesionDeRedSimulada())
        vm.users = usuariosDePrueba()
        vm.searchText = "lEaNnE"

        XCTAssertEqual(vm.filteredUsers.count, 1)
        XCTAssertEqual(vm.filteredUsers.first?.id, 1)
    }

    // MARK: - fetchUsers() con SesionDeRedSimulada

    // 7. Respuesta exitosa con JSON valido de 3 usuarios -> users queda con esos 3 usuarios.
    func testFetchUsers_jsonValido_actualizaUsers() {
        let sesion = SesionDeRedSimulada()
        sesion.dataAEntregar = """
        [
            {"id":1,"name":"Leanne Graham","username":"Bret","email":"leanne@april.biz"},
            {"id":2,"name":"Ervin Howell","username":"Antonette","email":"ervin@melissa.tv"},
            {"id":3,"name":"Clementine Bauch","username":"Samantha","email":"clementine@yesenia.net"}
        ]
        """.data(using: .utf8)
        let vm = UserViewModel(sesion: sesion)

        let expectation = expectation(description: "fetchUsers exitoso")
        vm.fetchUsers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertEqual(vm.users.count, 3)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // 8. Respuesta con error de red simulado -> users queda vacio y no crashea.
    func testFetchUsers_errorDeRed_usersQuedaVacio() {
        let sesion = SesionDeRedSimulada()
        sesion.errorAEntregar = URLError(.notConnectedToInternet)
        let vm = UserViewModel(sesion: sesion)

        let expectation = expectation(description: "fetchUsers con error")
        vm.fetchUsers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(vm.users.isEmpty)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }

    // 9. Respuesta exitosa con JSON corrupto/no decodificable -> se maneja sin crash.
    func testFetchUsers_jsonCorrupto_noActualizaUsers() {
        let sesion = SesionDeRedSimulada()
        sesion.dataAEntregar = "esto no es JSON valido".data(using: .utf8)
        let vm = UserViewModel(sesion: sesion)

        let expectation = expectation(description: "fetchUsers con JSON corrupto")
        vm.fetchUsers()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            XCTAssertTrue(vm.users.isEmpty)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
}
