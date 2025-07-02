//
//  ViewController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 06/06/25.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    
    //@IBOutlet weak var swAdmin: UISwitch!
    
    @IBOutlet weak var txtUsuario: UITextField!
    
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBAction func btGoHome(_ sender: Any) {
        guard let usuario = txtUsuario.text, !usuario.isEmpty,
              let password = txtPassword.text, !password.isEmpty else {
            mostrarAlerta(mensaje: "Debes ingresar usuario y contraseña")
            return
        }

        let url = URL(string: "https://chocodelizzia.com/data/login.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = [
            "usuario": usuario,
            "password": password
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.mostrarAlerta(mensaje: "Error de red: \(error.localizedDescription)")
                }
                return
            }

            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                DispatchQueue.main.async {
                    self.mostrarAlerta(mensaje: "Respuesta inválida del servidor")
                }
                return
            }

            if let success = json["success"] as? Bool, success,
               let rol = json["rol"] as? Int {
                
                let usuarioServer = json["usuario"] as? String ?? ""

                DispatchQueue.main.async {
                    if rol == 2 {
                        // ADMIN
                        SessionManager.esAdmin = true
                        SessionManager.usuarioActual = usuarioServer
                        SessionManager.shared.vendedorActual = nil
         
                        self.irAPantallaAdmin()
                    } else {
                        // VENDEDOR
                        SessionManager.esAdmin = false

                        let context = DataManager.shared.persistentContainer.viewContext
                        let fetchRequest: NSFetchRequest<Vendedores> = Vendedores.fetchRequest()
                        fetchRequest.predicate = NSPredicate(format: "nombre == %@", usuarioServer)
    
                        if let resultados = try? context.fetch(fetchRequest), let vendedor = resultados.first {
                            SessionManager.shared.vendedorActual = vendedor
                        } else {
                            // Crear nuevo vendedor si no existe
                            let nuevoVendedor = Vendedores(context: context)
                            
                            let nombreNormalizado = usuarioServer.lowercased()
                            nuevoVendedor.nombre = nombreNormalizado
                            
                            nuevoVendedor.id = Int16(rol)
                            try? context.save()
                            SessionManager.shared.vendedorActual = nuevoVendedor
                        }

                        self.irAPantallaVendedor()
                    }
                }
            } else {
                let errorMsg = json["error"] as? String ?? "Error desconocido"
                DispatchQueue.main.async {
                    self.mostrarAlerta(mensaje: errorMsg)
                }
            }
        }
        task.resume()
    }


    @IBAction func btGoRegister(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let registerVC = storyboard.instantiateViewController(withIdentifier: "RegisterView") as? RegisterViewController {
            self.present(registerVC, animated: true, completion: nil)
 
        }
    }
    func mostrarAlerta(mensaje: String) {
        let alerta = UIAlertController(title: "Error", message: mensaje, preferredStyle: .alert)
        alerta.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alerta, animated: true)
    }

    func irAPantallaAdmin() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
               let window = sceneDelegate.window {
                window?.rootViewController = tabBarVC
                window?.makeKeyAndVisible()
            }
        }
    }

    func irAPantallaVendedor() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let tabBarVC = storyboard.instantiateViewController(withIdentifier: "SellerTabBarController") as? UITabBarController {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let sceneDelegate = windowScene.delegate as? UIWindowSceneDelegate,
               let window = sceneDelegate.window {
                window?.rootViewController = tabBarVC
                window?.makeKeyAndVisible()
            }
        }
    }
    func buscarVendedorEnLocal(rol: Int) {
        let context = DataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Vendedores> = Vendedores.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", rol)
        
        do {
            let vendedores = try context.fetch(fetchRequest)
            if let vendedor = vendedores.first {
                SessionManager.shared.vendedorActual = vendedor
                print("Login como: \(vendedor.nombre ?? "")")
                self.irAPantallaVendedor()
            } else {
                self.mostrarAlerta(mensaje: "No se encontró vendedor con ID \(rol) en la base local")
            }
        } catch {
            self.mostrarAlerta(mensaje: "Error al buscar vendedor local")
        }
    }
    func obtenerOVerificarUsuarioEnCoreData(usuario: String, rol: Int16) -> Vendedores {
        let context = DataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Vendedores> = Vendedores.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "nombre == %@", usuario)
        
        do {
            let resultados = try context.fetch(fetchRequest)
            if let encontrado = resultados.first {
                // Ya existe en CoreData
                print("✅ Usuario encontrado: \(encontrado.nombre ?? "Sin nombre")")
                return encontrado
            } else {
                // No existe -> lo creamos
                let nuevo = Vendedores(context: context)
                nuevo.nombre = usuario
                nuevo.rol = rol
                // Generar un id automático si no tienes
                nuevo.id = Int16.random(in: 1000...9999)
                
                try context.save()
                print("✅ Usuario creado: \(usuario)")
                return nuevo
            }
        } catch {
            fatalError("Error consultando/creando usuario: \(error)")
        }
    }

    


}

