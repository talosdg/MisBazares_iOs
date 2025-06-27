//
//  DataManager.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 12/06/25.
//

import Foundation
import CoreData

class DataManager : NSObject{
    static let shared = DataManager()
    
    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {

        let container = NSPersistentContainer(name: "Eventos")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
               
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            
            do {
                try context.save()
            } catch {
               
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    // MARK: - Custom methods
    
    func llenaBD(){
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
        // La BD ya fue sincronizada anteriormente
        
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
    
    func guardaEventos(_ eventos:[EventosVO]){
        guard let entidadDesc = NSEntityDescription.entity(forEntityName: "Eventos", in: persistentContainer.viewContext) else { return }
        eventos.forEach { eventosVO in
            let eventos = NSManagedObject(entity: entidadDesc, insertInto:persistentContainer.viewContext) as! Eventos
            
            eventos.inicializa(eventosVO)
            
        }
        saveContext()
                
    }
    
    func guardaVendedores(_ vendedoresVOs: [VendedoresVO]) {
        print(">>>> guardaVendedores")
        let context = persistentContainer.viewContext

        guard let entidadDesc = NSEntityDescription.entity(forEntityName: "Vendedores", in: context) else { return }

        vendedoresVOs.forEach { vendedorVO in
            let vendedor = NSManagedObject(entity: entidadDesc, insertInto: context) as! Vendedores
            vendedor.inicializa(vendedorVO, context: context) // <-- CORREGIDO
        }

        saveContext()
    }
    
    func buscaEventoConId(_ idEvento:Int16) -> Eventos?{
        let elQuery = Eventos.fetchRequest()
        let elFiltro = NSPredicate(format: "id == %d", idEvento)
        elQuery.predicate = elFiltro
        do {
            let tmp = try persistentContainer.viewContext.fetch(elQuery)
            return tmp.first // primer objeto del arreglo
        }
        catch {
            
            print ("no se puede ejecutar el query SELECT * FROM Eventos WHERE tipo='%'")
        }
        return nil
    }
    
    
    func todosLosEventos(estatus: String) -> [Eventos] {
        var arreglo = [Eventos]()
        let elQuery = Eventos.fetchRequest()
        
        let elFiltro = NSPredicate(format: "estatus == %@", estatus)
        elQuery.predicate = elFiltro
        
        do {
            arreglo = try persistentContainer.viewContext.fetch(elQuery)
            print("Al filtrar todosLosEventos hay: \(arreglo.count)")
        }
        catch {
            print("Error al obtener eventos: \(error)")
            return []
        }
        return arreglo
    }
    func todosLosVendedores() -> [Vendedores] {
        var arreglo = [Vendedores]()
        let elQuery: NSFetchRequest<Vendedores> = Vendedores.fetchRequest()
        
        do {
            arreglo = try persistentContainer.viewContext.fetch(elQuery)
            print("Vendedores encontrados: \(arreglo.count)")
        }
        catch {
            print("Error al obtener vendedores: \(error)")
            return []
        }
        return arreglo
    }

    func resumenEventos() -> String {
        var resumen = ""
        let qEventos = Eventos.fetchRequest()
        let qVendedores = Vendedores.fetchRequest()
        print(qVendedores)
        do{
            
            let evenPendientes = NSPredicate(format: "estatus == %@", "pendiente")
            qEventos.predicate = evenPendientes
            let cuentaEven = try persistentContainer.viewContext.count(for: qEventos)
            resumen = "Hay \(cuentaEven) eventos pendientes de publicar\n"
            
            
            let cuentaVend = try persistentContainer.viewContext.count(for: qVendedores)
            resumen += "Hay \(cuentaVend) vendedores por aceptar"
            
            
        }catch{
            
        }
        return resumen
    }
    
    
    func agregarEvento(nombre: String, estatus: String?, lugar: String?, plazas: Int16) {
        let contexto = persistentContainer.viewContext
        guard let entidadDesc = NSEntityDescription.entity(forEntityName: "Eventos", in: contexto) else { return }

        // Buscar el id más alto actual
        let fetchRequest: NSFetchRequest<Eventos> = Eventos.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fetchRequest.fetchLimit = 1

        var nuevoID: Int16 = 1
        if let ultimoEvento = try? contexto.fetch(fetchRequest).first {
            nuevoID = ultimoEvento.id + 1
        }

        // Crear nuevo evento
        let nuevoEvento = Eventos(entity: entidadDesc, insertInto: contexto)
        nuevoEvento.id = nuevoID
        nuevoEvento.nombre = nombre
        nuevoEvento.estatus = estatus
        nuevoEvento.lugar = lugar
        nuevoEvento.plazas = plazas

        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name("NEW_EVENT_ADDED"), object: nuevoEvento)
    }
    
    
    // BORRAR EVENTO EN BD
    func borrar(objeto:NSManagedObject){
        persistentContainer.viewContext.delete(objeto) // BORRO
        saveContext() // ACTUALIZO
        NotificationCenter.default.post(name:NSNotification.Name("DELETED_OBJECT"), object: nil)// NOTIFICA LO OCURRIDO
    }
    
    func publicarEvento(_ evento: Eventos) {
        print("publicarEvento con: \(String(describing: evento.estatus))")
        evento.estatus = "publicado" //  publicado en BD
        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name("PUBLISHED_OBJECT"), object: evento)
    }
    
    func cancelarEvento(_ evento: Eventos) {
        print("cancelarEvento con: \(String(describing: evento.estatus))")
        evento.estatus = "cancelado" // cancelado en BD
        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name("CANCELED_OBJECT"), object: evento)
    }
    func despublicarEvento(_ evento: Eventos) {
        print("despublicarEvento con: \(String(describing: evento.estatus))")
        evento.estatus = "pendiente" //  publicado en BD
        saveContext()
        NotificationCenter.default.post(name: NSNotification.Name("DESPUBLISHED_OBJECT"), object: evento)
    }
    
    func solicitarInscripcion(vendedor: Vendedores, al evento: Eventos) {
        print("solicitarInscripcion en DataManager")
        let context = persistentContainer.viewContext
        
        // ✅ Verificar si ya existe una inscripción
        let fetch: NSFetchRequest<Inscripcion> = Inscripcion.fetchRequest()
        fetch.predicate = NSPredicate(format: "vendedor == %@ AND evento == %@", vendedor, evento)
        
        if let existentes = try? context.fetch(fetch), let inscripcionExistente = existentes.first {
            print("⚠️ Ya existe una inscripción: estatus = \(inscripcionExistente.estatus ?? "sin estatus")")
            // Opcional: actualizar estatus si está vacío
            if inscripcionExistente.estatus == nil || inscripcionExistente.estatus == "" {
                inscripcionExistente.estatus = "solicitado"
                try? context.save()
                print("✅ Estatus actualizado a 'solicitado'")
            }
            return
        }

        // 🆕 Crear nueva si no existe
        let nueva = Inscripcion(context: context)
        print("Esto es nueva: \(nueva) con estatus \(String(describing: nueva.estatus))")
        nueva.estatus = "solicitado"
        nueva.vendedor = vendedor
        nueva.evento = evento
        
        do {
            try context.save()
            saveContext()

            // Validación opcional
            if let resultados = try? context.fetch(fetch), let i = resultados.first {
                print("🔎 Verificación post-guardado: estatus = \(i.estatus ?? "sin estatus")")
            }

            NotificationCenter.default.post(name: NSNotification.Name("INSCRIP_STATUS_OBJECT"), object: evento)
            print("✅ Inscripción creada con estado solicitado")
        } catch {
            print("❌ Error al guardar la inscripción: \(error)")
        }
    }

        
        
         
    func crearInscripcion(para vendedor: Vendedores, al evento: Eventos, estatus: String = "solicitado") {
         
         
         let context = DataManager.shared.persistentContainer.viewContext

        // Existe la inscripción?
        let request: NSFetchRequest<Inscripcion> = Inscripcion.fetchRequest()
        request.predicate = NSPredicate(format: "vendedor == %@ AND evento == %@", vendedor, evento)
        
        do {
            let existentes = try context.fetch(request)
            if existentes.count > 0 {
                print("⚠️ Ya existe una inscripción para este vendedor y evento")
                return
            }
            
            // Crear nueva inscripción
            let nueva = Inscripcion(context: context)
            nueva.estatus = estatus
            nueva.vendedor = vendedor
            nueva.evento = evento

            try context.save()
            print("✅ Inscripción creada con estatus: \(estatus)")
            
        } catch {
            print("❌ Error al crear inscripción: \(error)")
        }
    }
    
    func eventosDisponiblesParaVendedor(_ vendedor: Vendedores) -> [Eventos] {
        let context = persistentContainer.viewContext

        // Obtener todos los eventos publicados
        let fetchRequest: NSFetchRequest<Eventos> = Eventos.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "estatus == %@", "publicado", "solicitado")

        do {
            let todosPublicados = try context.fetch(fetchRequest)

            // Obtener eventos ya solicitados por este vendedor
            let fetchInscripciones: NSFetchRequest<Inscripcion> = Inscripcion.fetchRequest()
            fetchInscripciones.predicate = NSPredicate(format: "vendedor == %@", vendedor)

            let inscripciones = try context.fetch(fetchInscripciones)
            let eventosInscritos = inscripciones.compactMap { $0.evento }

            // Filtrar solo los eventos que aún no han sido solicitados
            let disponibles = todosPublicados.filter { evento in
                return !eventosInscritos.contains(evento)
            }

            print("🔄 eventosDisponiblesParaVendedor: \(disponibles.count) encontrados")
            return disponibles

        } catch {
            print("❌ Error obteniendo eventos disponibles: \(error)")
            return []
        }
    }


    

}
