//
//  DataManager+Vendedores.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 27/06/25.
//

import Foundation
import CoreData

extension DataManager {

    func guardaVendedores(_ vendedoresVOs: [VendedoresVO]) {
        let context = persistentContainer.viewContext
        guard let entidadDesc = NSEntityDescription.entity(forEntityName: "Vendedores", in: context) else { return }

        vendedoresVOs.forEach { vendedorVO in
            let vendedor = Vendedores(entity: entidadDesc, insertInto: context)
            vendedor.inicializa(vendedorVO, context: context)
        }

        saveContext()
    }

    func obtenVendedores() {
        print("ejecutando obtensión vendedores")
        if let laURL = URL(string: "https://chocodelizzia.com/data/vendedores.json") {
            let sesion = URLSession(configuration: .default)
            let tarea = sesion.dataTask(with:URLRequest(url:laURL)) { data, response, error in
                if error != nil && data == nil  {
                    print ("no se pudo descargar el feed de vendedores \(error?.localizedDescription ?? "")")
                    return
                }
                if let data = data {
                    if let jsonString = String(data: data, encoding: .utf8) {
                      print("Datos descargados vendedores OK")
                      print("Datos descargados: \(jsonString)")  // mostrando el contenido en
                    } else {
                        print("Error al convertir los datos a String.")
                    }
                } else {
                    print("No se recibieron datos.")
                }
                do {
                    let tmp = try JSONDecoder().decode([VendedoresVO].self, from:data!)
                    print("tratando de guardar \(tmp)")
                    self.guardaVendedores(tmp)
                }
                catch { print ("no se obtuvo un JSON en la respuesta") }
            }
            tarea.resume()
        }
    }

    func todosLosVendedores() -> [Vendedores] {
        let request: NSFetchRequest<Vendedores> = Vendedores.fetchRequest()
        return (try? persistentContainer.viewContext.fetch(request)) ?? []
    }

    func resumenEventos() -> String {
        let context = persistentContainer.viewContext
        let qEventos = Eventos.fetchRequest()
        let qVendedores = Vendedores.fetchRequest()
        
        var resumen = ""
        do {
            qEventos.predicate = NSPredicate(format: "estatus == %@", "pendiente")
            let cuentaEventos = try context.count(for: qEventos)
            resumen += "Hay \(cuentaEventos) eventos pendientes de publicar\n"
            
            let cuentaVendedores = try context.count(for: qVendedores)
            resumen += "Hay \(cuentaVendedores) vendedores por aceptar"
        } catch {
            print("Error generando resumen: \(error)")
        }
        return resumen
    }
}
