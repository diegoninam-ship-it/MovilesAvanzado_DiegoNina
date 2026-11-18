//
//  MainTabBarController.swift
//  Ventas
//
//  Created by Diego Nina Malqui on 17/11/26.
//

import UIKit

/// Pestañas visibles según el rol del usuario de la sesión activa.
final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        configurarPestanas(rol: SesionUsuario.shared.usuarioActual?.rol ?? "Vendedor")
    }

    private func configurarPestanas(rol: String) {
        let productos = envolver(ProductosViewController(), titulo: "Productos", icono: "shippingbox")
        let clientes = envolver(ClientesViewController(), titulo: "Clientes", icono: "person.2")
        let cuenta = envolver(CuentaViewController(), titulo: "Cuenta", icono: "person.crop.circle")

        if rol == "Supervisor" {
            let resumen = envolver(ResumenViewController(), titulo: "Resumen", icono: "chart.bar")
            let ventas = envolver(VentasSupervisorViewController(), titulo: "Ventas", icono: "list.bullet.rectangle")
            viewControllers = [resumen, ventas, productos, clientes, cuenta]
        } else {
            let venta = envolver(NuevaVentaViewController(), titulo: "Venta", icono: "cart.badge.plus")
            let misVentas = envolver(MisVentasViewController(), titulo: "Mis ventas", icono: "doc.text")
            viewControllers = [productos, clientes, venta, misVentas, cuenta]
        }
    }

    private func envolver(_ viewController: UIViewController, titulo: String, icono: String) -> UIViewController {
        viewController.tabBarItem = UITabBarItem(title: titulo, image: UIImage(systemName: icono), tag: 0)
        return UINavigationController(rootViewController: viewController)
    }
}
