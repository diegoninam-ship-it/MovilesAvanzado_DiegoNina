//
//  LoginViewController.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import UIKit
import CoreData

/// Pantalla A1: autentica al usuario y da acceso a la app o a Registro.
final class LoginViewController: UIViewController {

    // MARK: - UI

    private let etiquetaLogo = UILabel()
    private let campoUsuario = UITextField()
    private let campoClave = UITextField()
    private let botonIngresar = UIButton(type: .system)
    private let botonCrearCuenta = UIButton(type: .system)

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
        navigationItem.hidesBackButton = true
        construirUI()
    }

    private func construirUI() {
        etiquetaLogo.text = "Ventas"
        etiquetaLogo.font = .systemFont(ofSize: 34, weight: .bold)
        etiquetaLogo.textAlignment = .center

        campoUsuario.placeholder = "Usuario"
        campoUsuario.autocapitalizationType = .none
        campoUsuario.autocorrectionType = .no
        campoUsuario.borderStyle = .roundedRect

        campoClave.placeholder = "Clave"
        campoClave.isSecureTextEntry = true
        campoClave.borderStyle = .roundedRect

        botonIngresar.setTitle("Ingresar", for: .normal)
        botonIngresar.addTarget(self, action: #selector(ingresar), for: .touchUpInside)

        botonCrearCuenta.setTitle("Crear cuenta", for: .normal)
        botonCrearCuenta.addTarget(self, action: #selector(irARegistro), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [
            etiquetaLogo, campoUsuario, campoClave, botonIngresar, botonCrearCuenta
        ])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(40, after: etiquetaLogo)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }

    // MARK: - Acciones

    @objc private func ingresar() {
        let usuario = (campoUsuario.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let clave = campoClave.text ?? ""

        guard !usuario.isEmpty, !clave.isEmpty,
              let usuarioEncontrado = buscarUsuario(usuario),
              usuarioEncontrado.clave == clave else {
            mostrarError("Usuario o clave incorrectos")
            return
        }

        SesionUsuario.shared.usuarioActual = usuarioEncontrado
        entrarComo(usuarioEncontrado)
    }

    @objc private func irARegistro() {
        navigationController?.pushViewController(RegistroViewController(), animated: true)
    }

    /// Fetch con `usuario ==[c] %@`, sin distinguir mayúsculas/minúsculas, igual que en el registro.
    private func buscarUsuario(_ usuario: String) -> Usuario? {
        let fetchRequest: NSFetchRequest<Usuario> = Usuario.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "usuario ==[c] %@", usuario)
        fetchRequest.fetchLimit = 1
        return try? context.fetch(fetchRequest).first
    }

    private func mostrarError(_ mensaje: String) {
        let alerta = UIAlertController(title: nil, message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        present(alerta, animated: true)
    }

    private func entrarComo(_ usuario: Usuario) {
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else { return }
        sceneDelegate.mostrarRoot(MainTabBarController())
    }
}
