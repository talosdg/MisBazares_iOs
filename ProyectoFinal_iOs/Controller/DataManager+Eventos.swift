//
//  DataManager+Vendedores.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 27/06/25.
//

import Foundation
import CoreData

extension DataManager {
    
    func llenaBD() {
        let ud = UserDefaults.standard
        if ud.integer(forKey: "BD-OK") != 1 {
            if let url = URL (string:"https://chocodelizzia.com/data/eventos.json") {
                let sesion = URLSession(configuration:.default)
                let task = sesion.dataTask(with: URLRequest(url: url)) { datos, respuesta, err in
                    if err != nil && datos == nil {
                        print ("no se pudo descargar el feed de eventos")
                        return
                    }
                    do {
            
                        let arreglo = try JSONDecoder().decode([EventosVO].self, from: datos!)
                        print("Cantidad de eventos decodificados: \(arreglo.count)")
                        self.guardaEventos(arreglo)
                        self.obtenVendedores()
       
                    }
                    catch {
                       print ("algo falló \(error.localizedDescription)")
                    }
                }
                task.resume()
            }
           ud.setValue(1, forKey: "BD-OK")
            
        }

    }

    func guardaEventos(_ eventos: [EventosVO]) {
        guard let entidadDesc = NSEntityDescription.entity(forEntityName: "Eventos", in: persistentContainer.viewContext) else { return }
        eventos.forEach { eventosVO in
            let evento = Eventos(entity: entidadDesc, insertInto: persistentContainer.viewContext)
            evento.inicializa(eventosVO)
        }
        saveContext()
    }

    func agregarEvento(nombre: String, estatus: String?, lugar: String?, plazas: Int16) {
        let contexto = persistentContainer.viewContext

        // Generar ID nuevo
        let fetchRequest: NSFetchRequest<Eventos> = Eventos.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1

        var nuevoID: Int16 = 1
        if let ultimo = try? contexto.fetch(fetchRequest).first {
            nuevoID = ultimo.id + 1
        }

        let nuevoEvento = Eventos(context: contexto)
        nuevoEvento.id = nuevoID
        nuevoEvento.nombre = nombre
        nuevoEvento.estatus = estatus
        nuevoEvento.lugar = lugar
        nuevoEvento.plazas = plazas

        saveContext()
        NotificationCenter.default.post(name: .init("NEW_EVENT_ADDED"), object: nuevoEvento)
    }


    func buscarEventoConId(_ idEvento: Int16) -> Eventos? {
        let request = Eventos.fetchRequest()
        request.predicate = NSPredicate(format: "id == %d", idEvento)
        return try? persistentContainer.viewContext.fetch(request).first
    }

    func todosLosEventos(estatus: String) -> [Eventos] {
        let request = Eventos.fetchRequest()
        request.predicate = NSPredicate(format: "estatus == %@", estatus)
        return (try? persistentContainer.viewContext.fetch(request)) ?? []
    }
    
    func publicarEvento(_ evento: Eventos) {
        evento.estatus = "publicado"
        saveContext()
        NotificationCenter.default.post(name: .init("PUBLISHED_OBJECT"), object: evento)
    }

    func despublicarEvento(_ evento: Eventos) {
        evento.estatus = "pendiente"
        saveContext()
        NotificationCenter.default.post(name: .init("DESPUBLISHED_OBJECT"), object: evento)
    }

    func cancelarEvento(_ evento: Eventos) {
        evento.estatus = "cancelado"
        saveContext()
        NotificationCenter.default.post(name: .init("CANCELED_OBJECT"), object: evento)
    }

    func borrar(objeto: NSManagedObject) {
        persistentContainer.viewContext.delete(objeto)
        saveContext()
        NotificationCenter.default.post(name: .init("DELETED_OBJECT"), object: nil)
    }
}
