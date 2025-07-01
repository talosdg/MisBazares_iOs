//
//  HomeViewController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 06/06/25.
//

import UIKit

class HomeViewController: UIViewController {

    @IBAction func btGenerarEvento(_ sender: Any) {
        
        
        let contexto = DataManager.shared.persistentContainer.viewContext
          let nuevoEvento = Eventos(context: contexto)
          
          let vc = EventDetailViewController()
          vc.modalPresentationStyle = .automatic
          vc.elEvento = nuevoEvento
          vc.esNuevoEvento = true
          self.present(vc, animated: true)
        // print("Si se crea el evento vacio: \(String(describing: vc.elEvento))")

    }
    
    @IBAction func btVerEventos(_ sender: Any) {
        self.tabBarController?.selectedIndex = 1
    }
    
    @IBAction func btVerVendedores(_ sender: Any) {
        self.tabBarController?.selectedIndex = 2
    }

    @IBOutlet weak var tvResumen: UITextView!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // TODO: - Generar el resumen de la Base de Datos
        tvResumen.text = DataManager.shared.resumenEventos()
       
    }
    
}
