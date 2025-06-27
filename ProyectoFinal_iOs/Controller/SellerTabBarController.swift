//
//  SellerTabBarController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 23/06/25.
//

import UIKit

class SellerTabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    // Este método se llama antes de cambiar de pestaña
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {

        if let nav = viewController as? UINavigationController,
           let exitVC = nav.viewControllers.first as? ExitController {
            
            // Mostramos la alerta personalizada de salida
            exitVC.showExitAlert()
            return false // No cambiar de pestaña
        }

        return true // Cambiar de pestaña normalmente
    }
}
