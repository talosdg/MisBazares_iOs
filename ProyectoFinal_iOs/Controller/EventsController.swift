//
//  EventsViewController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 11/06/25.
//

import UIKit

class EventsController:  UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var eventos = [Eventos]()
    
    var estatusActual = "publicado" // es para admin
    
    
    @IBOutlet weak var EventosList: UITableView!

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventos.count
    }
    /* LISTADO DE EVENTOS EN EL TABLE VIEW*/
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier:"eventCell", for:indexPath)
        let m = eventos[indexPath.row]
        cell.textLabel?.text = m.nombre ?? "Evento sin nombre"
        return cell
    }
    //**************************************************************************/
    // TODO: - Lanzar el detalle del evento
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let e = eventos[indexPath.row] // obtener el evento (touch del usuario)
        let dv = EventDetailViewController() // instanciamos el detailview
        dv.elEvento = e // asignamos el evento al dv
        dv.modalPresentationStyle = .automatic // indicamos el modo de presentacion

        self.present(dv, animated:true) // lo mostramos
    }
    //**************************************************************************/
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        EventosList.dataSource = self
        EventosList.delegate = self
        actualizar() // llega con "pendiente a falta de parámetro"
        NotificationCenter.default.addObserver(self, selector: #selector(eventoBorrado), name: NSNotification.Name("DELETED_OBJECT"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventoDespublicado), name: NSNotification.Name("DESPUBLISHED_OBJECT"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventoPublicado), name: NSNotification.Name("PUBLISHED_OBJECT"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(eventoCancelado), name: NSNotification.Name("CANCELED_OBJECT"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(guardaCambios), name: Notification.Name("EVENTO_EDITADO"), object: nil)
  
        NotificationCenter.default.addObserver(self, selector: #selector(actualizaSolicitados), name: Notification.Name("ACTUALIZA_SOLICITUD"), object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        actualizar(elEstatus: estatusActual)
    }

    @objc
    func actualizar(elEstatus: String  = "publicado" ){
        eventos = DataManager.shared.todosLosEventos(estatus: elEstatus)
        EventosList.reloadData()
    }
    @objc // actualizar el observer BORRADO
    func eventoBorrado(_ notification: Notification) {
        actualizar(elEstatus: "cancelado") // tag queda en
    }
    @objc // actualizar el observer CANCELADO
    func eventoCancelado(_ notification: Notification) {
        actualizar(elEstatus: "pendiente") // tag queda en
    }
    @objc // actualizar el observer PUBLICADO
    func eventoPublicado(_ notification: Notification) {
        actualizar(elEstatus: "pendiente") // tag queda en
    }
    @objc // actualizar el observer DESPUBLICADO
    func eventoDespublicado(_ notification: Notification) {
        actualizar(elEstatus: "publicado") // tag queda en
    }
    @objc func guardaCambios() {
        actualizar(elEstatus:  self.estatusActual) // tag queda en
    }
    @objc func actualizaSolicitados() {
        print("⚠️ Notificación recibida: actualizaSolicitados")
           actualizar(elEstatus: self.estatusActual)
           EventosList.reloadData()
    }

    @IBAction func cambiaListado(_ sender: UISegmentedControl) {
        print("Segment cambiado: \(sender.selectedSegmentIndex)")
        cambiaLista(numEstatus: sender.selectedSegmentIndex)
    }
    @objc
    func cambiaLista(numEstatus: Int) {
        //print("cambiaLista con: \(numEstatus) en \(estatusActual)")
        switch numEstatus {
          case 0:
            estatusActual = "publicado"
          case 1:
            estatusActual = "pendiente"
          case 2:
            estatusActual = "terminado"
          case 3:
            estatusActual = "cancelado"
          default:
              eventos = []
          }
        actualizar(elEstatus: estatusActual)
    }

}
