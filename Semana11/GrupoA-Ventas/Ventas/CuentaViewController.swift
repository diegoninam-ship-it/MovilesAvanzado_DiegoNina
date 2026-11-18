//
//  CuentaViewController.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import UIKit

/// Pestaña Cuenta (ambos roles): datos de la sesión activa y cierre de sesión.
final class CuentaViewController: UIViewController {

    private let etiquetaNombre = UILabel()
    private let etiquetaUsuario = UILabel()
    private let etiquetaRol = UILabel()
    private let botonCerrarSesion = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Cuenta"
        construirUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let usuario = SesionUsuario.shared.usuarioActual
        etiquetaNombre.text = "Nombre: \(usuario?.nombre ?? "")"
        etiquetaUsuario.text = "Usuario: \(usuario?.usuario ?? "")"
        etiquetaRol.text = "Rol: \(usuario?.rol ?? "")"
    }

    private func construirUI() {
        for etiqueta in [etiquetaNombre, etiquetaUsuario, etiquetaRol] {
            etiqueta.font = .systemFont(ofSize: 17)
        }

        botonCerrarSesion.setTitle("Cerrar sesión", for: .normal)
        botonCerrarSesion.tintColor = .systemRed
        botonCerrarSesion.addTarget(self, action: #selector(cerrarSesion), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [etiquetaNombre, etiquetaUsuario, etiquetaRol, botonCerrarSesion])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(32, after: etiquetaRol)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32)
        ])
    }

    @objc private func cerrarSesion() {
        SesionUsuario.shared.cerrarSesion()
        guard let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate else { return }
        sceneDelegate.mostrarRoot(UINavigationController(rootViewController: LoginViewController()))
    }
}
