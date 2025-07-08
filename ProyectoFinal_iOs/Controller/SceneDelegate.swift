//
//  SceneDelegate.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 06/06/25.
//

import UIKit
import CoreData

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        let sesionActiva = UserDefaults.standard.bool(forKey: "sesionActiva")

        if sesionActiva {
            let rol = UserDefaults.standard.integer(forKey: "rol")
            let usuario = UserDefaults.standard.string(forKey: "usuarioActual") ?? ""

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            var rootVC: UIViewController

            if rol == 2 {
                // ADMIN
                SessionManager.esAdmin = true
                SessionManager.usuarioActual = usuario
                rootVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController")
            } else {
                // VENDEDOR
                SessionManager.esAdmin = false
                SessionManager.usuarioActual = usuario

                let context = DataManager.shared.persistentContainer.viewContext
                let fetchRequest: NSFetchRequest<Vendedores> = Vendedores.fetchRequest()
                fetchRequest.predicate = NSPredicate(format: "nombre == %@", usuario)

                if let resultados = try? context.fetch(fetchRequest), let vendedor = resultados.first {
                    SessionManager.shared.vendedorActual = vendedor
                }

                rootVC = storyboard.instantiateViewController(withIdentifier: "SellerTabBarController")
            }

            // Configurar rootViewController
            if let windowScene = scene as? UIWindowScene {
                let window = UIWindow(windowScene: windowScene)
                window.rootViewController = rootVC
                self.window = window
                window.makeKeyAndVisible()
                return // IMPORTANTE: salir aquí para no mostrar login
            }
        }

    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        
            DataManager.shared.saveContext()
    }

}

