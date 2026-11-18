//
//  RegistroViewController.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import UIKit
import CoreData

/// Pantalla A2: crea una cuenta nueva y entra directo a la app (sin pasar por Login).
final class RegistroViewController: UIViewController {

    // MARK: - UI

    private let campoNombre = UITextField()
    private let campoUsuario = UITextField()
    private let campoClave = UITextField()
    private let campoConfirmarClave = UITextField()
    private let selectorRol = UISegmentedControl(items: ["Vendedor", "Supervisor"])
    private let botonRegistrar = UIButton(type: .system)

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        self.context = PersistenceController.shared.viewContext
        super.init(coder: coder)
    }

    // MARK: - Ciclo de vida

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Crear cuenta"
        construirUI()
    }

    private func construirUI() {
        campoNombre.placeholder = "Nombre completo"
        campoUsuario.placeholder = "Usuario"
        campoUsuario.autocapitalizationType = .none
        campoUsuario.autocorrectionType = .no
        campoClave.placeholder = "Clave (mínimo 6 caracteres)"
        campoClave.isSecureTextEntry = true
        campoConfirmarClave.placeholder = "Confirmar clave"
        campoConfirmarClave.isSecureTextEntry = true

        for campo in [campoNombre, campoUsuario, campoClave, campoConfirmarClave] {
            campo.borderStyle = .roundedRect
        }

        selectorRol.selectedSegmentIndex = 0

        botonRegistrar.setTitle("Registrar", for: .normal)
        botonRegistrar.addTarget(self, action: #selector(registrarUsuario), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            campoNombre, campoUsuario, campoClave, campoConfirmarClave, selectorRol, botonRegistrar
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
    }

    // MARK: - Registro

    @objc private func registrarUsuario() {
        let nombre = (campoNombre.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let usuario = (campoUsuario.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let clave = campoClave.text ?? ""
        let confirmacion = campoConfirmarClave.text ?? ""

        guard !nombre.isEmpty, !usuario.isEmpty, !clave.isEmpty else {
            mostrarError("Completa nombre, usuario y clave.")
            return
        }

        guard clave.count >= 6 else {
            mostrarError("La clave debe tener al menos 6 caracteres.")
            return
        }

        guard clave == confirmacion else {
            mostrarError("Las claves no coinciden.")
            return
        }

        guard !usuarioYaExiste(usuario) else {
            mostrarError("Ya existe una cuenta con el usuario \"\(usuario)\". Elige otro.")
            return
        }

        let rol = selectorRol.selectedSegmentIndex == 0 ? "Vendedor" : "Supervisor"

        let nuevoUsuario = Usuario(context: context)
        nuevoUsuario.nombre = nombre
        nuevoUsuario.usuario = usuario
        nuevoUsuario.clave = clave
        nuevoUsuario.rol = rol

        PersistenceController.shared.guardar()
        SesionUsuario.shared.usuarioActual = nuevoUsuario

        entrarComo(nuevoUsuario)
    }

    /// Fetch con `usuario ==[c] %@` para validar unicidad sin distinguir mayúsculas/minúsculas.
    private func usuarioYaExiste(_ usuario: String) -> Bool {
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "usuario ==[c] %@", usuario)
        let conteo = try? context.count(for: fetchRequest)
        return (conteo ?? 0) > 0
    }

    private func mostrarError(_ mensaje: String) {
        let alerta = UIAlertController(title: "No se pudo registrar", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        present(alerta, animated: true)
    }

    /// Entra directo a la app con el rol del usuario recién creado (sin pasar por Login).
    private func entrarComo(_ usuario: Usuario) {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else { return }
        sceneDelegate.mostrarRoot(MainTabBarController())
    }
}
