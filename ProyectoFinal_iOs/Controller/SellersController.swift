//
//  SellerController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 19/06/25.
//

import UIKit

class SellersController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var vendedores = [Vendedores]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        VendedoresList.dataSource = self
        VendedoresList.delegate = self
      
        // 🔁 Cargar eventos desde Core Data
        vendedores = DataManager.shared.todosLosVendedores()
        VendedoresList.reloadData()
 
    }

    @IBOutlet weak var VendedoresList: UITableView!
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vendedores.count
    }
    
    /* LISTADO DE VENDEDORES EN EL TABLE VIEW*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"sellersCell", for:indexPath)
        let vendedor = vendedores[indexPath.row]
        cell.textLabel?.text = vendedor.nombre ?? "Vendedor sin nombre"
        
        // Verificar si tiene inscripciones solicitadas
        let solicitudes = DataManager.shared.inscripcionesSolicitadasParaVendedor(vendedor)
        if solicitudes.count > 0 {
            cell.detailTextLabel?.text = "⚠️ \(solicitudes.count) solicitud(es)"
            cell.accessoryType = .disclosureIndicator
            cell.backgroundColor = UIColor.systemYellow.withAlphaComponent(0.2)
        } else {
            cell.detailTextLabel?.text = nil
            cell.accessoryType = .none
            cell.backgroundColor = UIColor.systemBackground
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vendedor = vendedores[indexPath.row]
        let solicitudes = DataManager.shared.inscripcionesSolicitadasParaVendedor(vendedor)
        
        if solicitudes.isEmpty {
            let alerta = UIAlertController(title: "Sin solicitudes", message: "Este vendedor no tiene solicitudes pendientes.", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            present(alerta, animated: true)
            return
        }else{
            
            print("Antes de abrir solicitados ")
            print("navigationController es nil? \(navigationController == nil)")
            let detalleVC = SellerRequestsController()
            detalleVC.vendedor = vendedor
            detalleVC.solicitudes = solicitudes
            navigationController?.pushViewController(detalleVC, animated: true)
            print("Despues de solicitados")
            
        }

    }

    class SellerRequestsController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
        var vendedor: Vendedores!
        var solicitudes: [Inscripcion] = []
        
        let tableView = UITableView()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = vendedor.nombre ?? "Solicitudes"
            
            view.addSubview(tableView)
            tableView.frame = view.bounds
            tableView.dataSource = self
            tableView.delegate = self
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "requestCell")
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return solicitudes.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath)
            let inscripcion = solicitudes[indexPath.row]
            cell.textLabel?.text = "Evento: \(inscripcion.evento?.nombre ?? "Sin nombre")"
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let inscripcion = solicitudes[indexPath.row]
            
            let alerta = UIAlertController(title: "Acción", message: "Aprobar o Cancelar inscripción", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "Aprobar", style: .default) { _ in
                DataManager.shared.aprobarInscripcion(inscripcion)
                self.recargarSolicitudes()
            })
            alerta.addAction(UIAlertAction(title: "Cancelar", style: .destructive) { _ in
                DataManager.shared.cancelarInscripcion(inscripcion)
                self.recargarSolicitudes()
            })
            alerta.addAction(UIAlertAction(title: "Cerrar", style: .cancel))
            present(alerta, animated: true)
        }
        
        func recargarSolicitudes() {
            solicitudes = DataManager.shared.inscripcionesSolicitadasParaVendedor(vendedor)
            tableView.reloadData()
        }
    }

    
    
}
