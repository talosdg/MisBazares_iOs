//
//  ViewFichaController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 27/06/25.
//

import UIKit

class ViewFichaController: UIViewController {
    
    var evento: Eventos?
    var fichaView = ViewFichaEvento()

    override func loadView() {
        view = fichaView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Ficha del Evento"
        view.backgroundColor = .white
        llenarDatos()
    }

    private func llenarDatos() {
        guard let evento = evento else { return }
        fichaView.tituloLabel.text = "EVENTO DISPONIBLE"
        fichaView.nombreLabel.text = evento.nombre ?? "N/A"
        fichaView.recintoLabel.text = evento.lugar ?? "N/A"
        fichaView.plazasLabel.text = "\(evento.plazas)"
        fichaView.fechaLabel.text = "Fecha por confirmar"
        fichaView.horarioLabel.text = "Horario por confirmar"
        fichaView.ubicacionLabel.text = "Ubicación por confirmar"

        fichaView.observacionesLabel.text = "Avisos"

        // Ejemplo de mapa simulado
        fichaView.mapaImageView.image = UIImage(named: "map_placeholder")
    }
}
