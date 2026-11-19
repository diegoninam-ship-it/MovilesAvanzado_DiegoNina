// Desarrollado por: Diego Nina Malqui

import Foundation
@testable import Semana13_ConsumoAPI

final class TareaDeRedSimulada: URLSessionDataTask {
    override func resume() {
        // No hace ninguna llamada de red real: la respuesta ya se entrego via completionHandler.
    }
}

struct PeticionRegistrada {
    let url: URL?
    let metodoHTTP: String?
    let body: Data?
}

final class SesionDeRedSimulada: SesionDeRed {

    var dataAEntregar: Data?
    var respuestaAEntregar: URLResponse?
    var errorAEntregar: Error?

    private(set) var peticiones: [PeticionRegistrada] = []

    private func registrar(_ request: URLRequest) {
        peticiones.append(
            PeticionRegistrada(url: request.url, metodoHTTP: request.httpMethod, body: request.httpBody)
        )
    }

    // MARK: - Variante dataTask (Actividad 2)

    func dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        registrar(request)
        completionHandler(dataAEntregar, respuestaAEntregar, errorAEntregar)
        return TareaDeRedSimulada()
    }

    // MARK: - Variante async/await (Actividad 3)

    func data(from url: URL) async throws -> (Data, URLResponse) {
        registrar(URLRequest(url: url))
        if let errorAEntregar { throw errorAEntregar }
        return (dataAEntregar ?? Data(), respuestaAEntregar ?? URLResponse())
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        registrar(request)
        if let errorAEntregar { throw errorAEntregar }
        return (dataAEntregar ?? Data(), respuestaAEntregar ?? URLResponse())
    }
}
