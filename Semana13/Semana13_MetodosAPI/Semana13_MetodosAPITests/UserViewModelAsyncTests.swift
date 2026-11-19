// Desarrollado por: Diego Nina Malqui
//
// Pruebas de regresion: Actividad 3 (async/await) vs Actividad 2 (dataTask).
//
// Contexto: en este repo, UserViewModel de MetodosAPI ya fue migrado por
// completo a async/await durante el prompt de desarrollo (no quedo ninguna
// ruta dataTask separada en produccion, y la regla de este prompt prohibe
// reintroducirla solo para tener dos rutas que probar). Por eso, en vez de
// comparar dos implementaciones distintas del ViewModel, este archivo repite
// explicitamente los 5 escenarios de CRUD de UserViewModelTests.swift como
// pruebas de regresion independientes: demuestran que, ante los mismos datos
// de entrada simulados por SesionDeRedSimulada, el resultado observable de
// cada metodo async/await (fetchUsers, addUser, updateUser, deleteUser) es
// el mismo que se documento como esperado para la Actividad 2 (equivalente
// al que producia la version dataTask antes del refactor).

import XCTest
@testable import Semana13_MetodosAPI

final class UserViewModelAsyncTests: XCTestCase {

    private func respuesta(status: Int, url: String = "https://jsonplaceholder.typicode.com/users") -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: url)!, statusCode: status, httpVersion: nil, headerFields: nil)!
    }

    // 1. fetchUsers() -> users se llena correctamente.
    func testFetchUsers_asyncAwait_llenaUsers() async {
        let sesion = SesionDeRedSimulada()
        sesion.dataAEntregar = """
        [{"id":1,"name":"Leanne Graham","username":"Bret","email":"leanne@april.biz"}]
        """.data(using: .utf8)
        sesion.respuestaAEntregar = respuesta(status: 200)
        let vm = UserViewModel(sesion: sesion)

        await vm.fetchUsers()

        XCTAssertEqual(vm.users.count, 1)
        XCTAssertEqual(vm.users.first?.name, "Leanne Graham")
    }

    // 2. addUser(_:) -> el usuario nuevo se agrega a users.
    func testAddUser_asyncAwait_agregaUsuario() async {
        let sesion = SesionDeRedSimulada()
        sesion.dataAEntregar = """
        {"id":11,"name":"Diego Nina","username":"diegonina","email":"diego@tecsup.edu.pe"}
        """.data(using: .utf8)
        sesion.respuestaAEntregar = respuesta(status: 201)
        let vm = UserViewModel(sesion: sesion)

        await vm.addUser(User(id: 0, name: "Diego Nina", username: "diegonina", email: "diego@tecsup.edu.pe"))

        XCTAssertEqual(vm.users.count, 1)
        XCTAssertEqual(vm.users.first?.id, 11)
    }

    // 3. addUser(_:) con error -> users no cambia.
    func testAddUser_asyncAwait_errorServidor_noCambiaUsers() async {
        let sesion = SesionDeRedSimulada()
        sesion.errorAEntregar = URLError(.badServerResponse)
        let vm = UserViewModel(sesion: sesion)

        await vm.addUser(User(id: 0, name: "Diego Nina", username: "diegonina", email: "diego@tecsup.edu.pe"))

        XCTAssertTrue(vm.users.isEmpty)
    }

    // 4. updateUser(_:) -> se actualiza el usuario correcto por id.
    func testUpdateUser_asyncAwait_actualizaElUsuarioCorrectoPorId() async {
        let sesion = SesionDeRedSimulada()
        sesion.dataAEntregar = Data()
        sesion.respuestaAEntregar = respuesta(status: 200)
        let vm = UserViewModel(sesion: sesion)
        vm.users = [
            User(id: 1, name: "Leanne Graham", username: "Bret", email: "leanne@april.biz"),
            User(id: 2, name: "Ervin Howell", username: "Antonette", email: "ervin@melissa.tv")
        ]

        await vm.updateUser(User(id: 2, name: "Ervin H. Editado", username: "Antonette", email: "ervin@melissa.tv"))

        XCTAssertEqual(vm.users.first(where: { $0.id == 2 })?.name, "Ervin H. Editado")
        XCTAssertEqual(vm.users.first(where: { $0.id == 1 })?.name, "Leanne Graham")
    }

    // 5. deleteUser(_:) -> el usuario desaparece de users.
    func testDeleteUser_asyncAwait_eliminaUsuario() async {
        let sesion = SesionDeRedSimulada()
        sesion.dataAEntregar = Data()
        sesion.respuestaAEntregar = respuesta(status: 200)
        let vm = UserViewModel(sesion: sesion)
        vm.users = [
            User(id: 1, name: "Leanne Graham", username: "Bret", email: "leanne@april.biz"),
            User(id: 2, name: "Ervin Howell", username: "Antonette", email: "ervin@melissa.tv")
        ]

        await vm.deleteUser(vm.users[0])

        XCTAssertEqual(vm.users.count, 1)
        XCTAssertEqual(vm.users.first?.id, 2)
    }
}
