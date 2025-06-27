//
//  VendedoresEventController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 23/06/25.
//

import UIKit
import CoreData

class VendedorEventsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var eventosDisponibles: [Eventos] = []
    
    var eventosPorSeccion: [String: [Eventos]] = [:] // para el vendedor
    let seccionesOrdenadas = ["disponibles", "solicitado", "aceptado", "cancelado"] // diccionario eventos vendedor
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tintColor = UIColor.midblue

        /// se paso al if eventosDisponibles = obtenerEventosPublicados()
        
        if let vendedor = SessionManager.shared.vendedorActual {
          /*  eventosDisponibles = obtenerEventosPublicados() // o tu método de fetch
            print("Eventos recargados para el vendedor: \(String(vendedor.id)) \(vendedor.nombre ?? "")") */
            
            clasificarEventosParaVendedor(vendedor)
            tableView.reloadData()
    
        }
        
        tableView.reloadData()
       
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return seccionesOrdenadas.count
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let clave = seccionesOrdenadas[section]
        return eventosPorSeccion[clave]?.count ?? 0
        // anterior a seccionar    return eventosDisponibles.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let clave = seccionesOrdenadas[section]
        return clave.capitalized
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let clave = seccionesOrdenadas[indexPath.section]
            let evento = eventosPorSeccion[clave]?[indexPath.row]

            let cell = tableView.dequeueReusableCell(withIdentifier: "eventoCell", for: indexPath)
            cell.textLabel?.text = evento?.nombre ?? "Sin nombre"

            switch clave {
             
                case "solicitado":
                    cell.accessoryView = Iconos.icono(.pendiente, color: .darkrose, size: 28)
                    cell.backgroundColor = UIColor.rosewood
                case "cancelado":
                    cell.accessoryView = Iconos.icono(.cancelado, color: .systemRed, size: 28)
                    cell.backgroundColor = UIColor.red.withAlphaComponent(0.10)
                case "aceptado":
                    cell.accessoryView = Iconos.icono(.inscrito, color: .midblue, size: 28)
                    cell.backgroundColor = UIColor.midblue.withAlphaComponent(0.1)
                default:
                    cell.accessoryView = Iconos.icono(.solicitar, color: .gray, size: 28)
                    cell.backgroundColor = .systemGray6
            }

            return cell
        
        /*
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventoCell", for: indexPath)
 
        if let vendedorGuardado = SessionManager.shared.vendedorActual {
            //print(">>>> cellForRowAt actualizando con: \(vendedorGuardado.id) ")
            let context = DataManager.shared.persistentContainer.viewContext
            do {
                let vendedorRefrescado = try context.existingObject(with: vendedorGuardado.objectID) as! Vendedores
                SessionManager.shared.vendedorActual = vendedorRefrescado // 🔁 Actualizamos el objeto vivo
            } catch {
                print("❌ Error al refrescar vendedor: \(error)")
            }
        }


         let evento = eventosDisponibles[indexPath.row]
         cell.textLabel?.text = evento.nombre ?? "Sin nombre"
        if let vendedorGuardado = SessionManager.shared.vendedorActual {
            let context = DataManager.shared.persistentContainer.viewContext
            do {
               // print("Refrescando y pintando en tableView cellForRowAt")
                //print("Estatus entrado: \(evento.estatus ?? "")")
                let vendedorRefrescado = try context.existingObject(with: vendedorGuardado.objectID) as! Vendedores
                        SessionManager.shared.vendedorActual = vendedorRefrescado

                        // 👉 Buscar si hay una inscripción de ese vendedor a ese evento
                        let fetch: NSFetchRequest<Inscripcion> = Inscripcion.fetchRequest()
                        fetch.predicate = NSPredicate(format: "vendedor == %@ AND evento == %@", vendedorRefrescado, evento)

                        if let inscripcion = try context.fetch(fetch).first {
                            let estatusInscripcion = inscripcion.estatus ?? "sin estatus"
                            print("📌 Estatus inscripción encontrada: \(estatusInscripcion)")

                            switch estatusInscripcion {
                                case "solicitado":
                                    cell.accessoryView = Iconos.icono(.pendiente, color: .darkrose, size: 28)
                                    cell.backgroundColor = UIColor.rosewood
                                case "cancelado":
                                    cell.accessoryView = Iconos.icono(.cancelado, color: .systemRed, size: 28)
                                    cell.backgroundColor = UIColor.red.withAlphaComponent(0.10)
                                case "aceptado":
                                    cell.accessoryView = Iconos.icono(.inscrito, color: .midblue, size: 28)
                                    cell.backgroundColor = UIColor.midblue.withAlphaComponent(0.1)
                                default:
                                    cell.accessoryView = Iconos.icono(.solicitar, color: .gray, size: 28)
                                    cell.backgroundColor = .systemGray6
                            }
                        } else {
                            // Sin inscripción: mostrar como disponible
                            cell.accessoryView = Iconos.icono(.solicitar, color: .systemGreen, size: 28)
                            cell.backgroundColor = UIColor.green.withAlphaComponent(0.15)
                        }
                
            } catch {
                print("❌ Error al refrescar vendedor o cargar inscripción: \(error)")
            }
        }
     
        return cell*/
    }

    // MARK: - TableView Delegate
    internal func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Aquí luego abrimos el detalle (opción C)

        let evento = eventosDisponibles[indexPath.row]

        let detalleVC = EventDetailViewController()
        detalleVC.elEvento = evento
        detalleVC.esNuevoEvento = false
        detalleVC.onSoloLectura = true
        detalleVC.modalPresentationStyle = .automatic

        // avisando refresco por inscripción/desinscripción
        detalleVC.onCambioInscripcion = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        // avisando refresco para solicitar/desistir
        detalleVC.onInscripcionCambiada = { [weak self] in
            print("🔄 Recargando tabla después de solicitud")
            self?.actualizarEventos()
        }

        self.present(detalleVC, animated: true, completion: nil)
    }
    
    func obtenerEventosPublicados() -> [Eventos] {
        let request: NSFetchRequest<Eventos> = Eventos.fetchRequest()
        request.predicate = NSPredicate(format: "estatus == %@", "publicado", "solicitado")
        let sort = NSSortDescriptor(key: "nombre", ascending: true)
        request.sortDescriptors = [sort]

        do {
            return try DataManager.shared.persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error al obtener eventos publicados: \(error)")
            return []
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //print("Se ejecuta viewWillApear")
        eventosDisponibles = obtenerEventosPublicados()
        tableView.reloadData()
    }
    func actualizarEventos() {
        // Aquí tu lógica de recarga
        if let vendedor = SessionManager.shared.vendedorActual {
            self.eventosDisponibles = DataManager.shared.eventosDisponiblesParaVendedor(vendedor)
            self.tableView.reloadData()
        }
    }
    
    func clasificarEventosParaVendedor(_ vendedor: Vendedores) {
        // Limpiar las secciones
        eventosPorSeccion = ["disponibles": [], "solicitado": [], "aceptado": [], "cancelado": []]

        let contexto = DataManager.shared.persistentContainer.viewContext

        // Obtener todos los eventos que están publicados (son "disponibles" en general)
        let fetchRequest: NSFetchRequest<Eventos> = Eventos.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "estatus == %@", "publicado")

        guard let todosPublicados = try? contexto.fetch(fetchRequest) else {
            print("❌ Error al obtener eventos publicados")
            return
        }

        // Obtener las inscripciones del vendedor
        let inscripcionesDelVendedor = (vendedor.inscripciones as? Set<Inscripcion>) ?? []

        // Clasificar las inscripciones existentes
        for inscripcion in inscripcionesDelVendedor {
            if let evento = inscripcion.evento, let estado = inscripcion.estatus {
                eventosPorSeccion[estado, default: []].append(evento)
            }
        }

        // Calcular disponibles: publicados que NO tengan inscripción con este vendedor
        let eventosYaInscritos = inscripcionesDelVendedor.compactMap { $0.evento }
        let eventosDisponiblesParaVendedor = todosPublicados.filter { !eventosYaInscritos.contains($0) }
        eventosPorSeccion["disponibles"] = eventosDisponiblesParaVendedor

        // Debug
        print("✅ Eventos clasificados para vendedor \(vendedor.id):")
        for (seccion, eventos) in eventosPorSeccion {
            print(" - \(seccion): \(eventos.count)")
        }
    }


}
