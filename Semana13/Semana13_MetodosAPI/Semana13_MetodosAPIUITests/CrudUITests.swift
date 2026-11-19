// Desarrollado por: Diego Nina Malqui

import XCTest

final class CrudUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    private func filas() -> XCUIElementQuery {
        app.descendants(matching: .any).matching(NSPredicate(format: "identifier BEGINSWITH 'userRow_'"))
    }

    // 4. Tocar el boton de agregar -> aparece el formulario (.sheet).
    func testTocarAgregar_muestraFormulario() throws {
        XCTAssertTrue(filas().firstMatch.waitForExistence(timeout: 15))

        app.buttons["botonAgregar"].tap()

        XCTAssertTrue(app.textFields["campoNombre"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["campoUsuario"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["campoCorreo"].waitForExistence(timeout: 5))
    }

    // 5. Llenar el formulario con datos validos y guardar -> la nueva fila aparece en la lista.
    func testLlenarYGuardarFormulario_agregaFila() throws {
        XCTAssertTrue(filas().firstMatch.waitForExistence(timeout: 15))
        let cantidadInicial = filas().count

        app.buttons["botonAgregar"].tap()

        let campoNombre = app.textFields["campoNombre"]
        XCTAssertTrue(campoNombre.waitForExistence(timeout: 5))
        campoNombre.tap()
        campoNombre.typeText("Diego Nina UITest")

        let campoUsuario = app.textFields["campoUsuario"]
        campoUsuario.tap()
        campoUsuario.typeText("diegouitest")

        let campoCorreo = app.textFields["campoCorreo"]
        campoCorreo.tap()
        campoCorreo.typeText("diego.uitest@tecsup.edu.pe")

        app.buttons["botonGuardar"].tap()

        XCTAssertTrue(app.staticTexts["Diego Nina UITest"].waitForExistence(timeout: 10))
        XCTAssertEqual(filas().count, cantidadInicial + 1)
    }

    // 6. Deslizar una fila y tocar eliminar -> la fila desaparece de la lista.
    func testDeslizarYEliminar_quitaFila() throws {
        XCTAssertTrue(filas().firstMatch.waitForExistence(timeout: 15))
        let cantidadInicial = filas().count

        let primeraFila = filas().firstMatch
        primeraFila.swipeLeft()

        let botonEliminar = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Eliminar a'")).firstMatch
        XCTAssertTrue(botonEliminar.waitForExistence(timeout: 5))
        botonEliminar.tap()

        let expectativa = XCTNSPredicateExpectation(
            predicate: NSPredicate { _, _ in self.filas().count == cantidadInicial - 1 },
            object: nil
        )
        wait(for: [expectativa], timeout: 10.0)
        XCTAssertEqual(filas().count, cantidadInicial - 1)
    }
}
