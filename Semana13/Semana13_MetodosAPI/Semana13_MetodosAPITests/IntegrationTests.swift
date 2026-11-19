// Desarrollado por: Diego Nina Malqui
//
// Pruebas de integracion: golpean la API real jsonplaceholder.typicode.com.
// jsonplaceholder es un mock: acepta POST/PUT/DELETE y responde 200/201,
// pero no persiste los cambios entre llamadas. Por eso estas pruebas
// verifican unicamente el codigo de respuesta y que el body decodifica,
// no que el cambio haya quedado guardado. Si no hay conexion a internet,
// se saltan (XCTSkip) en vez de fallar.

import XCTest
@testable import Semana13_MetodosAPI

final class IntegrationTests: XCTestCase {

    private let baseURL = "https://jsonplaceholder.typicode.com/users"

    private func verificarConexion() async throws {
        do {
            _ = try await URLSession.shared.data(from: URL(string: baseURL)!)
        } catch {
            throw XCTSkip("Sin conexion a internet en este entorno: \(error.localizedDescription)")
        }
    }

    func testGetUsers_apiReal_200YBodyDecodifica() async throws {
        try await verificarConexion()

        let (data, response) = try await URLSession.shared.data(from: URL(string: baseURL)!)
        let http = response as? HTTPURLResponse

        XCTAssertEqual(http?.statusCode, 200)
        let usuarios = try JSONDecoder().decode([User].self, from: data)
        XCTAssertFalse(usuarios.isEmpty)
    }

    func testPostUser_apiReal_201YBodyDecodifica() async throws {
        try await verificarConexion()

        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            User(id: 0, name: "Diego Nina", username: "diegonina", email: "diego@tecsup.edu.pe")
        )

        let (data, response) = try await URLSession.shared.data(for: request)
        let http = response as? HTTPURLResponse

        XCTAssertEqual(http?.statusCode, 201)
        XCTAssertNoThrow(try JSONDecoder().decode(User.self, from: data))
    }

    func testPutUser_apiReal_200() async throws {
        try await verificarConexion()

        var request = URLRequest(url: URL(string: "\(baseURL)/1")!)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(
            User(id: 1, name: "Leanne Graham Editada", username: "Bret", email: "leanne@april.biz")
        )

        let (_, response) = try await URLSession.shared.data(for: request)
        let http = response as? HTTPURLResponse

        XCTAssertEqual(http?.statusCode, 200)
    }

    func testDeleteUser_apiReal_200() async throws {
        try await verificarConexion()

        var request = URLRequest(url: URL(string: "\(baseURL)/1")!)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)
        let http = response as? HTTPURLResponse

        XCTAssertEqual(http?.statusCode, 200)
    }
}
