//
//  ExitController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 09/06/25.
//

import Foundation
import UIKit

import UIKit

class ExitController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showExitAlert()
    }
    
    func showExitAlert() {
        let alert = UIAlertController(
            title: "Cerrar sesión",
            message: "¿Deseas cerrar tu sesión?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { _ in
            // Regresar a la pestaña anterior
            self.tabBarController?.selectedIndex = 0
        }))

        alert.addAction(UIAlertAction(title: "Cerrar sesión", style: .destructive, handler: { _ in
            self.cerrarSesion()
        }))
        
        if self.presentedViewController == nil {
            self.present(alert, animated: true)
        }
    }

    func cerrarSesion() {
        // Limpiar UserDefaults
        UserDefaults.standard.removeObject(forKey: "sesionActiva")
        UserDefaults.standard.removeObject(forKey: "usuarioActual")
        UserDefaults.standard.removeObject(forKey: "rol")
        
        // Volver al Login 
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginView") as? ViewController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? SceneDelegate,
               let window = sceneDelegate.window {
                window.rootViewController = loginVC
                window.makeKeyAndVisible()
            }
        }
    }
}
