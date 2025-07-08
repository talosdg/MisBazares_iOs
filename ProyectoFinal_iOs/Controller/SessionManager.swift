//
//  SessionManager.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 09/06/25.
//

import Foundation

import UIKit

class SessionManager {
    
    static let shared = SessionManager() // patrón singleton
    
    static var esAdmin: Bool = false
    static var usuarioActual = ""
    var vendedorActual: Vendedores?
  
    private init() {}
    
    func logout(from controller: UIViewController) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
         let loginVC = storyboard.instantiateViewController(withIdentifier: "ViewController")
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let delegate = scene.delegate as? SceneDelegate,
           let window = delegate.window {
            
            UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window.rootViewController = loginVC
            }, completion: nil)
        }
    }
}
