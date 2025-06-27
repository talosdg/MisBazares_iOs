//
//  HomeViewController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 06/06/25.
//

import UIKit

class HomeViewController: UIViewController {

    @IBAction func btGenerarEvento(_ sender: Any) {
        let vc = EventDetailViewController()
        vc.modalPresentationStyle = .automatic
        vc.elEvento = Eventos() // dummy, no importa si se modifica luego
        vc.esNuevoEvento = true
        self.present(vc, animated: true)
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
