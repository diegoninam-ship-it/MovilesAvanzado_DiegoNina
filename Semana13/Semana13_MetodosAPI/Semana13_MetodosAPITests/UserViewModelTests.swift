// Desarrollado por: Diego Nina Malqui
//
// Nota: UserViewModel de Semana13_MetodosAPI ya fue migrado por completo a
// async/await en el prompt de desarrollo (Actividad 3); no quedo ninguna
// ruta basada en dataTask en produccion. Este archivo cubre los escenarios
// de CRUD pedidos para la Actividad 2 ejercitando la unica implementacion
// que existe hoy (la async). El Checkpoint 5 (UserViewModelAsyncTests)
// repite los mismos escenarios de forma explicita como prueba de regresion.

import XCTest
@testable import Semana13_MetodosAPI

final class UserViewModelTests: XCTestCase {

    // MARK: - CRUD con SesionDeRedSimulada (caja negra: valores limite en codigos de respuesta)

    private func respuesta(status: Int, url: String = "https://jsonplaceholder.typicode.com/users") -> HTTPURLResponse {
        HTTPURLResponse(url: URL(string: url)!, statusCode: status, httpVersion: nil, headerFields: nil)!
    }

    // 1. fetchUsers() con respuesta 200 y JSON valido -> users se llena correctamente.
    func testFetchUsers_200_llenaUsers() async {
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

    // 2. addUser(_:) con respuesta 201 -> el usuario nuevo se agrega a users.
    func testAddUser_201_agregaUsuario() async {
        let sesion = SesionDeRedSimulada()
        sesion.dataAEntregar = """
        {"id":11,"name":"Diego Nina","username":"diegonina","email":"diego@tecsup.edu.pe"}
        """.data(using: .utf8)
        sesion.respuestaAEntregar = respuesta(status: 201)
        let vm = UserViewModel(sesion: sesion)

        let nuevo = User(id: 0, name: "Diego Nina", username: "diegonina", email: "diego@tecsup.edu.pe")
        await vm.addUser(nuevo)

        XCTAssertEqual(vm.users.count, 1)
        XCTAssertEqual(vm.users.first?.id, 11)
    }

    // 3. addUser(_:) con respuesta de error (4xx/5xx simulado) -> users no cambia.
    func testAddUser_errorServidor_noCambiaUsers() async {
        let sesion = SesionDeRedSimulada()
        sesion.errorAEntregar = URLError(.badServerResponse)
        let vm = UserViewModel(sesion: sesion)

        let nuevo = User(id: 0, name: "Diego Nina", username: "diegonina", email: "diego@tecsup.edu.pe")
        await vm.addUser(nuevo)

        XCTAssertTrue(vm.users.isEmpty)
        XCTAssertNotNil(vm.errorMessage)
    }

    // 4. updateUser(_:) con respuesta 200 -> se actualiza el usuario correcto por id.
    func testUpdateUser_200_actualizaElUsuarioCorrectoPorId() async {
        let sesion = SesionDeRedSimulada()
        sesion.dataAEntregar = Data()
        sesion.respuestaAEntregar = respuesta(status: 200)
        let vm = UserViewModel(sesion: sesion)
        vm.users = [
            User(id: 1, name: "Leanne Graham", username: "Bret", email: "leanne@april.biz"),
            User(id: 2, name: "Ervin Howell", username: "Antonette", email: "ervin@melissa.tv")
        ]

        let actualizado = User(id: 2, name: "Ervin H. Editado", username: "Antonette", email: "ervin@melissa.tv")
        await vm.updateUser(actualizado)

        XCTAssertEqual(vm.users.count, 2)
        XCTAssertEqual(vm.users.first(where: { $0.id == 2 })?.name, "Ervin H. Editado")
        XCTAssertEqual(vm.users.first(where: { $0.id == 1 })?.name, "Leanne Graham")
    }

    // 5. deleteUser(_:) con respuesta 200 -> el usuario desaparece de users.
    func testDeleteUser_200_eliminaUsuario() async {
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

    // 6. Verbo HTTP y URL correctos por metodo (GET/POST/PUT/DELETE, incluyendo /users/{id}).
    func testVerbosYURLsCorrectos() async {
        let sesionGet = SesionDeRedSimulada()
        sesionGet.dataAEntregar = "[]".data(using: .utf8)
        sesionGet.respuestaAEntregar = respuesta(status: 200)
        await UserViewModel(sesion: sesionGet).fetchUsers()
        XCTAssertEqual(sesionGet.peticiones.first?.metodoHTTP, "GET")
        XCTAssertEqual(sesionGet.peticiones.first?.url?.absoluteString, "https://jsonplaceholder.typicode.com/users")

        let sesionPost = SesionDeRedSimulada()
        sesionPost.dataAEntregar = """
        {"id":11,"name":"Diego Nina","username":"diegonina","email":"diego@tecsup.edu.pe"}
        """.data(using: .utf8)
        sesionPost.respuestaAEntregar = respuesta(status: 201)
        await UserViewModel(sesion: sesionPost).addUser(User(id: 0, name: "Diego Nina", username: "diegonina", email: "diego@tecsup.edu.pe"))
        XCTAssertEqual(sesionPost.peticiones.first?.metodoHTTP, "POST")
        XCTAssertEqual(sesionPost.peticiones.first?.url?.absoluteString, "https://jsonplaceholder.typicode.com/users")

        let sesionPut = SesionDeRedSimulada()
        sesionPut.dataAEntregar = Data()
        sesionPut.respuestaAEntregar = respuesta(status: 200)
        let vmPut = UserViewModel(sesion: sesionPut)
        vmPut.users = [User(id: 7, name: "X", username: "x", email: "x@x.com")]
        await vmPut.updateUser(User(id: 7, name: "Y", username: "x", email: "x@x.com"))
        XCTAssertEqual(sesionPut.peticiones.first?.metodoHTTP, "PUT")
        XCTAssertEqual(sesionPut.peticiones.first?.url?.absoluteString, "https://jsonplaceholder.typicode.com/users/7")

        let sesionDelete = SesionDeRedSimulada()
        sesionDelete.dataAEntregar = Data()
        sesionDelete.respuestaAEntregar = respuesta(status: 200)
        let vmDelete = UserViewModel(sesion: sesionDelete)
        let usuario = User(id: 9, name: "Z", username: "z", email: "z@z.com")
        vmDelete.users = [usuario]
        await vmDelete.deleteUser(usuario)
        XCTAssertEqual(sesionDelete.peticiones.first?.metodoHTTP, "DELETE")
        XCTAssertEqual(sesionDelete.peticiones.first?.url?.absoluteString, "https://jsonplaceholder.typicode.com/users/9")
    }

    // MARK: - Validacion de formulario (caja negra: particion de equivalencia + valores limite)

    // 7. Los 3 campos vacios -> invalido.
    func testValidacion_tresCamposVacios_invalido() {
        XCTAssertFalse(formularioEsValido(nombre: "", username: "", correo: ""))
    }

    // 8. Nombre vacio, resto lleno -> invalido.
    func testValidacion_nombreVacio_invalido() {
        XCTAssertFalse(formularioEsValido(nombre: "", username: "diegonina", correo: "diego@tecsup.edu.pe"))
    }

    // 9. Todos los campos con contenido -> valido.
    func testValidacion_todosConContenido_valido() {
        XCTAssertTrue(formularioEsValido(nombre: "Diego Nina", username: "diegonina", correo: "diego@tecsup.edu.pe"))
    }

    // 10. Campo con solo espacios en blanco -> invalido (caso limite).
    // Decision documentada: un campo de solo espacios no cuenta como contenido real,
    // por eso se recorta (trimmingCharacters) antes de evaluar si esta vacio.
    func testValidacion_soloEspacios_invalido() {
        XCTAssertFalse(formularioEsValido(nombre: "   ", username: "diegonina", correo: "diego@tecsup.edu.pe"))
    }
}
