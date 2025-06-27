//
//  ViewController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 06/06/25.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    
    @IBOutlet weak var swAdmin: UISwitch!
    
    @IBAction func btGoHome(_ sender: Any) {
        
        SessionManager.esAdmin = swAdmin.isOn
        
        let fetchRequest: NSFetchRequest<Vendedores> = Vendedores.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", 0) // Juana tiene ID = 0
        
        
        if !SessionManager.esAdmin {
            let context = DataManager.shared.persistentContainer.viewContext
            let fetchRequest: NSFetchRequest<Vendedores> = Vendedores.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", 0) // Juana tiene ID = 0
            
            do {
                let vendedores = try context.fetch(fetchRequest)
                if let vendedor = vendedores.first {
                    SessionManager.esAdmin = false
                    SessionManager.shared.vendedorActual = vendedor
                    
                    print("Login como: \(vendedor.nombre ?? "") \(vendedor.apellido_paterno ?? "")")
                    print("Eventos asignados:")
                    if let eventos = vendedor.eventos as? Set<Eventos> {
                        for evento in eventos {
                            print("- \(evento.nombre ?? "Sin nombre")")
                        }
                    }
                }
            } catch {
                print("Error al buscar vendedor")
            }
        }

       
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        
        if SessionManager.esAdmin{
            if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
                   let window = sceneDelegate.window {
                    
                    window?.rootViewController = tabBarVC
                    window?.makeKeyAndVisible()
                }
            }
        }else{
            
            
            if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "SellerTabBarController") as? UITabBarController {
                
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
                   let window = sceneDelegate.window {
                    
                    window?.rootViewController = tabBarVC
                    window?.makeKeyAndVisible()
                }
            }
            
            
        }

    }

    @IBAction func btGoRegister(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterView") as? RegisterViewController {
            self.present(registerVC, animated: true, completion: nil)
 
        }
    }
    

}

