// Desarrollado por: Diego Nina Malqui

import XCTest

final class BusquedaUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    private func filas() -> XCUIElementQuery {
        app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'userRow_'"))
    }

    // 1. La lista muestra al menos una fila tras cargar.
    func testListaMuestraAlMenosUnaFilaTrasCargar() throws {
        XCTAssertTrue(filas().firstMatch.waitForExistence(timeout: 15), "Deberia cargar al menos un usuario desde la API")
    }

    // 2. Escribir un texto de busqueda sin coincidencias -> aparece el estado vacio.
    func testBusquedaSinCoincidencias_muestraEstadoVacio() throws {
        XCTAssertTrue(filas().firstMatch.waitForExistence(timeout: 15))

        let campoBusqueda = app.searchFields.firstMatch
        XCTAssertTrue(campoBusqueda.waitForExistence(timeout: 5))
        campoBusqueda.tap()
        campoBusqueda.typeText("zzzzzNoExiste")

        XCTAssertTrue(app.staticTexts["Sin resultados"].waitForExistence(timeout: 5))
    }

    // 3. Escribir un texto que coincide con un usuario conocido -> la lista se reduce a esa fila.
    func testBusquedaConCoincidencia_reduceLaLista() throws {
        XCTAssertTrue(filas().firstMatch.waitForExistence(timeout: 15))

        let campoBusqueda = app.searchFields.firstMatch
        XCTAssertTrue(campoBusqueda.waitForExistence(timeout: 5))
        campoBusqueda.tap()
        campoBusqueda.typeText("Leanne")

        XCTAssertTrue(app.staticTexts["Leanne Graham"].waitForExistence(timeout: 5))
        XCTAssertEqual(filas().count, 1)
    }
}
