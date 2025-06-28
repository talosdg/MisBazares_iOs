//
//  VendedoresEventController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 23/06/25.
//

import UIKit
import CoreData

class VendedorEventsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var eventosPorSeccion: [String: [Eventos]] = [:] // para el vendedor
    let seccionesOrdenadas = ["disponibles", "solicitado", "aceptado", "cancelado"] // diccionario eventos vendedor
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tintColor = UIColor.midblue

        if let vendedor = SessionManager.shared.vendedorActual {
            clasificarEventosParaVendedor(vendedor)
        }
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
                cell.accessoryView = Iconos.icono(.pendiente, color: .amber, size: 24)
                    cell.backgroundColor = UIColor.amber.withAlphaComponent(0.1)
                case "cancelado":
                    cell.accessoryView = Iconos.icono(.cancelado, color: .systemRed, size: 24)
                    cell.backgroundColor = UIColor.red.withAlphaComponent(0.1)
                case "aceptado":
                    cell.accessoryView = Iconos.icono(.inscrito, color: .midgreen, size: 24)
                    cell.backgroundColor = UIColor.green.withAlphaComponent(0.1)
                default:
                    cell.accessoryView = Iconos.icono(.solicitar, color: .midblue, size: 24)
                    cell.backgroundColor = UIColor.cyan.withAlphaComponent(0.1)
            }

            return cell
        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let clave = seccionesOrdenadas[indexPath.section]
        guard let evento = eventosPorSeccion[clave]?[indexPath.row] else {
            print("❌ No se encontró el evento en sección \(clave)")
            return
        }

        let detalleVC = EventDetailViewController()
        detalleVC.elEvento = evento
        detalleVC.esNuevoEvento = false
        detalleVC.onSoloLectura = true
        detalleVC.modalPresentationStyle = .automatic

        // avisando refresco por inscripción/desinscripción
        detalleVC.onCambioInscripcion = { [weak self] in
            DispatchQueue.main.async {
                if let vendedor = SessionManager.shared.vendedorActual {
                    self?.clasificarEventosParaVendedor(vendedor)
                    self?.tableView.reloadData()
                }
            }
        }

        // avisando refresco para solicitar/desistir
        detalleVC.onInscripcionCambiada = { [weak self] in
            print("🔄 Recargando tabla después de solicitud")
            if let vendedor = SessionManager.shared.vendedorActual {
                self?.clasificarEventosParaVendedor(vendedor)
                self?.tableView.reloadData()
            }
        }

        self.present(detalleVC, animated: true, completion: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let vendedor = SessionManager.shared.vendedorActual {
            clasificarEventosParaVendedor(vendedor)
            tableView.reloadData()
        }
    }

    func actualizarEventos() {
        if let vendedor = SessionManager.shared.vendedorActual {
            self.clasificarEventosParaVendedor(vendedor)
            self.tableView.reloadData()
        }
    }
    
    func clasificarEventosParaVendedor(_ vendedor: Vendedores) {
        eventosPorSeccion = ["disponibles": [], "solicitado": [], "aceptado": [], "cancelado": []]

        let contexto = DataManager.shared.persistentContainer.viewContext

        // 1. Obtener eventos publicados (solo estos pueden estar 'disponibles')
        let fetchRequest: NSFetchRequest<Eventos> = Eventos.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "estatus == %@", "publicado")
        
        guard let todosPublicados = try? contexto.fetch(fetchRequest) else {
            print("❌ Error al obtener eventos publicados")
            return
        }

        // 2. Todas las inscripciones del vendedor (pueden incluir eventos cancelados)
        let inscripcionesDelVendedor = (vendedor.inscripciones as? Set<Inscripcion>) ?? []

        for inscripcion in inscripcionesDelVendedor {
            if let evento = inscripcion.evento,
               let estado = inscripcion.estatus {
                // 👇 Incluye cualquier evento (aunque cancelado), en su sección correspondiente
                eventosPorSeccion[estado, default: []].append(evento)
            }
        }

        // 3. Los disponibles solo deben ser eventos publicados y NO inscritos aún
        let eventosYaInscritos = inscripcionesDelVendedor.compactMap { $0.evento }
        let eventosDisponiblesParaVendedor = todosPublicados.filter { !eventosYaInscritos.contains($0) }
        eventosPorSeccion["disponibles"] = eventosDisponiblesParaVendedor

        print("✅ Eventos clasificados para vendedor \(vendedor.id):")
        for (seccion, eventos) in eventosPorSeccion {
            print(" - \(seccion): \(eventos.count)")
        }
    }

}
