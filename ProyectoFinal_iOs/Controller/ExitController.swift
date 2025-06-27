//
//  ExitController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 09/06/25.
//

import Foundation
import UIKit

class ExitController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showExitAlert()
    }
    
    func showExitAlert() {
        let alert = UIAlertController(
            title: "Cerrar aplicación",
            message: "¿Deseas salir de la aplicación?",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: { _ in
            // Regresar a la pestaña anterior
            self.tabBarController?.selectedIndex = 0
        }))

        alert.addAction(UIAlertAction(title: "Salir", style: .destructive, handler: { _ in
            // Forzar salida (solo para pruebas)
            exit(0)
        }))
        
        // Evita mostrar múltiples veces la alerta si el usuario vuelve
        if self.presentedViewController == nil {
            self.present(alert, animated: true)
        }
    }
}
