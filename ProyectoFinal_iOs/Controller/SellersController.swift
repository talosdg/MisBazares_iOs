//
//  SellerController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 19/06/25.
//

import UIKit

class SellersController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var vendedores = [Vendedores]()

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
        let m = vendedores[indexPath.row]
        cell.textLabel?.text = m.nombre ?? "Vendedor sin nombre"
        return cell
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        VendedoresList.dataSource = self
        VendedoresList.delegate = self
      
        // 🔁 Cargar eventos desde Core Data
        vendedores = DataManager.shared.todosLosVendedores()
        VendedoresList.reloadData()
 
    }
    /*
    @IBAction func cambiaListado(_ sender: UISegmentedControl) {
        print("Segment cambiado: \(sender.selectedSegmentIndex)")
        actualizar(numEstatus: sender.selectedSegmentIndex)
    }
    
    
    
    
    
    @objc
    func actualizar(numEstatus: Int) {
        
        switch numEstatus {
          case 0:
              eventos = DataManager.shared.todosLosEventos(estatus: "publicado")
          case 1:
              eventos = DataManager.shared.todosLosEventos(estatus: "pendiente")
          case 2:
              eventos = DataManager.shared.todosLosEventos(estatus: "terminado")
          case 3:
              eventos = DataManager.shared.todosLosEventos(estatus: "cancelado")
          default:
              eventos = []
          }
          
          EventosList.reloadData()
        
    }
*/
    
    
    
    
}
