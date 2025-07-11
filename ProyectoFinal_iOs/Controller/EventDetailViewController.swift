//
//  DetailEventViewController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 13/06/25.
//


import UIKit
import CoreData
import CoreLocation


class EventDetailViewController: UIViewController {
    
   
    var elEvento: Eventos!
    var elVendedor: Vendedores!
    var detalle: EventDetailView!
    let datePickerInicio = UIDatePicker()
    let datePickerTermino = UIDatePicker()



    
    var esNuevoEvento: Bool = false
    
    var estatusInscripcion: String?
    
    var vendedores: [Vendedores] = []
    
    var toolbar: UIToolbar!
    var doneButton: UIBarButtonItem!
    
    var origenEstatus: String = "pendiente"
    
    // vars para verificar cambios
    var nombreOriginal = ""
    var estatusOriginal = ""
    var lugarOriginal = ""
    var plazasOriginal = ""
    var fechaInicioOriginal = ""
    var fechaTerminoOriginal = ""
    
    
    var onSoloLectura = false
    
    var sellerActual: Vendedores? {
        return SessionManager.shared.vendedorActual
    }
    
    var onCambioInscripcion: (() -> Void)?  // original del admin
    var onInscripcionCambiada: (() -> Void)? // segunda para el vendedor


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .rosewood
        detalle = EventDetailView(frame:view.bounds.insetBy(dx: 40, dy: 40))
        view.addSubview(detalle)
        
        detalle.txtPlazas.keyboardType = .numberPad

        datePickerInicio.datePickerMode = .date
        datePickerInicio.preferredDatePickerStyle = .wheels
        datePickerInicio.addTarget(self, action: #selector(fechaInicioCambiada), for: .valueChanged)
        detalle.txtFechaInicio.inputView = datePickerInicio
        detalle.txtFechaInicio.inputAccessoryView = createToolbar(selectorDone: #selector(confirmarFechaInicio), selectorCancel: #selector(cancelarPicker))
        detalle.txtFechaInicio.isUserInteractionEnabled = true
        detalle.txtFechaInicio.addTarget(self, action: #selector(mostrarDatePickerInicio), for: .editingDidBegin)

        

        datePickerTermino.datePickerMode = .date
        datePickerTermino.preferredDatePickerStyle = .wheels
        datePickerTermino.addTarget(self, action: #selector(fechaTerminoCambiada), for: .valueChanged)
        detalle.txtFechaTermino.inputView = datePickerTermino
        detalle.txtFechaTermino.inputAccessoryView = createToolbar(selectorDone: #selector(confirmarFechaTermino), selectorCancel: #selector(cancelarPicker))


        
        //print("👀 Controller padre: \(String(describing: self.presentingViewController))")
        // Detectar cambios por guardar
        detalle.txtNombre.addTarget(self, action: #selector(verificarCambios), for: .editingChanged)
        detalle.txtLugar.addTarget(self, action: #selector(verificarCambios), for: .editingChanged)
        detalle.txtPlazas.addTarget(self, action: #selector(verificarCambios), for: .editingChanged)
        
        detalle.btnGuardarCambios.isEnabled = false
        detalle.btnGuardarCambios.alpha = 0.3
        
        
        if let evento = elEvento {
            detalle.txtNombre.text = evento.nombre
            detalle.txtLugar.text = evento.lugar
            detalle.txtPlazas.text = "\(evento.plazas)"
            detalle.txtEstatus.text = evento.estatus
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"

            if let fechaInicio = elEvento.fechaInicio {
                detalle.txtFechaInicio.text = dateFormatter.string(from: fechaInicio)
                datePickerInicio.date = fechaInicio
            }

            if let fechaTermino = elEvento.fechaTermino {
                detalle.txtFechaTermino.text = dateFormatter.string(from: fechaTermino)
                datePickerTermino.date = fechaTermino
            }

        }

        if onSoloLectura {
            detalle.inhabilitado(es: true)
            detalle.txtEstatus.isHidden = false // puedes dejarlo visible si solo es lectura
            detalle.btnGuardarCambios.isHidden = true
            detalle.btnCrear.isHidden = true
            detalle.btnCrearPublicar.isHidden = true
        }

        detalle.btnInscripcion.setTitle("Solicitar evento", for: .normal)
        detalle.btnInscripcion.backgroundColor = .amber
        
        if let vendedor = sellerActual, let evento = elEvento {
            estatusInscripcion = DataManager.shared.obtenerEstatusInscripcion(vendedor: vendedor, evento: evento)
            print("Estatus inscripción vendedor: \(estatusInscripcion ?? "ninguno")")
        }


        actualizarEstadoBotonInscripcion()

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Valores originales para guardado de cambios
        nombreOriginal = detalle.txtNombre.text ?? ""
        estatusOriginal = detalle.txtEstatus.text ?? ""
        lugarOriginal = detalle.txtLugar.text ?? ""
        plazasOriginal = detalle.txtPlazas.text ?? ""
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        fechaInicioOriginal = detalle.txtFechaInicio.text ?? ""
        fechaTerminoOriginal = detalle.txtFechaTermino.text ?? ""

        
        detalle.txtEstatus.isHidden = true // simpre oculto
        
        if esNuevoEvento {
            detalle.txtNombre.text = ""
            detalle.txtEstatus.text = "pendiente"
            detalle.txtLugar.text = ""
            detalle.txtPlazas.text = ""

            detalle.inhabilitado(es: false) // Habilita edición
       
            // Configurar y agregar botón Crear y dejar pendiente
            detalle.configurarBoton(detalle.btnCrear, titulo: "Crear y dejar pendiente", color: .opaqueturqoise)
            detalle.stackView.addArrangedSubview(detalle.btnCrear)
            detalle.btnCrear.addTarget(self, action:#selector(crearEvento), for:.touchUpInside)
            
            // Botón para crear y publicar
            detalle.configurarBoton(detalle.btnCrearPublicar, titulo: "Crear y publicar", color: .midgreen)
            detalle.stackView.addArrangedSubview(detalle.btnCrearPublicar)
            detalle.btnCrearPublicar.addTarget(self, action: #selector(crearPublicarEvento), for: .touchUpInside)
            
            return
        }
        
        // Si es edición
        detalle.txtNombre.text = elEvento.nombre ?? ""
        detalle.txtEstatus.text = elEvento.estatus ?? ""
        detalle.txtLugar.text = elEvento.lugar ?? ""
        detalle.txtPlazas.text = "\(elEvento.plazas)"

        let estatusActual = elEvento.estatus ?? "pendiente"

       

        // 👇 Solo se ejecuta si NO está cancelado
        detalle.agregarBotones(estatus: estatusActual)


        // Habilita edición si el evento está "pendiente" o "publicado"
        if estatusActual == "pendiente" || estatusActual == "publicado" {
            detalle.inhabilitado(es: false)
        } else {
            detalle.inhabilitado(es: true)
        }
        
        if !SessionManager.esAdmin{
            //print("no es admin")
            detalle.inhabilitado(es: true)
        }
        
        
        // Agregar target a botones
        detalle.btnCrear.addTarget(self, action:#selector(crearEvento), for:.touchUpInside)
        detalle.btnPublicar.addTarget(self, action:#selector(publicarEvento), for:.touchUpInside)
        detalle.btnDespublicar.addTarget(self, action:#selector(despublicarEvento), for:.touchUpInside)
        detalle.btnCancelar.addTarget(self, action:#selector(cancelarEvento), for:.touchUpInside)
        detalle.btnEliminar.addTarget(self, action:#selector(borrar), for:.touchUpInside)
        detalle.btnGuardarCambios.addTarget(self, action:#selector(guardarCambios), for: .touchUpInside)
        
        
        //detalle.btnCambiaInscripcion.addTarget(self, action: #selector(solicitarInscripcion), for: .touchUpInside)
        detalle.btnInscripcion.addTarget(self, action: #selector(solicitar), for: .touchUpInside)
        
        // BOTON DEL MAPA > FALTAN TODAS LAS CONFIGURACIONES DE ARRIBA
        detalle.btnVerMapa.addTarget(self, action: #selector(mostrarMapa), for: .touchUpInside)
        
    }
 
    @objc func mostrarMapa() {
        print("➡️ Mostrando mapa")

        let mapaVC = MapaEventoViewController()
        mapaVC.modalPresentationStyle = .fullScreen

        let lat = elEvento.latitud
        let lon = elEvento.longitud

        if lat != 0.0 && lon != 0.0 {
            mapaVC.coordenadaEvento = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        } else {
            mapaVC.direccionEvento = elEvento.lugar ?? ""
        }
        
        mapaVC.nombreEvento = elEvento.nombre ?? "Evento sin nombre"
        mapaVC.lugarEvento = elEvento.lugar ?? "Dirección desconocida"


        present(mapaVC, animated: true)
    }
    
    @objc func fechaInicioCambiada() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        detalle.txtFechaInicio.text = dateFormatter.string(from: datePickerInicio.date)
        verificarCambios()
    }

    @objc func fechaTerminoCambiada() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        detalle.txtFechaTermino.text = dateFormatter.string(from: datePickerTermino.date)
        verificarCambios()
    }


       
    @objc func crearEvento() {
        guard let nombre = detalle.txtNombre.text, !nombre.isEmpty,
             // let estatus = detalle.txtEstatus.text,    OMITIDO POR INTERFAZ
              let lugar = detalle.txtLugar.text,
              let plazasStr = detalle.txtPlazas.text, let plazas = Int16(plazasStr) else {
            let alerta = UIAlertController(title: "Faltan datos", message: "Revisa los campos", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
            return
        }

        let confirm = UIAlertController(title: "Confirmar", message: "El evento '\(nombre)' será creado pendiente de ser publicado", preferredStyle: .alert)
        confirm.addAction(UIAlertAction(title: "Sí", style: .default, handler: { _ in
            
            self.elEvento.nombre = nombre
            self.elEvento.estatus = "pendiente"  // Fuerza estado "pendiente"
            self.elEvento.lugar = lugar
            self.elEvento.plazas = plazas
            self.elEvento.fechaInicio = self.datePickerInicio.date
            self.elEvento.fechaTermino = self.datePickerTermino.date
            self.elEvento.duenoAdmin = SessionManager.usuarioActual

            DataManager.shared.saveContext()

            self.dismiss(animated: true)
        }))
        confirm.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        self.present(confirm, animated: true)
    }

    @objc func crearPublicarEvento() {
        guard let nombre = detalle.txtNombre.text, !nombre.isEmpty,
              let lugar = detalle.txtLugar.text,
              let plazasStr = detalle.txtPlazas.text, let plazas = Int16(plazasStr) else {
            let alerta = UIAlertController(title: "Faltan datos", message: "Revisa los campos", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
            return
        }

        let confirm = UIAlertController(
            title: "Confirmar publicación",
            message: "El evento '\(nombre)' será creado y publicado.",
            preferredStyle: .alert
        )

        confirm.addAction(UIAlertAction(title: "Sí", style: .default, handler: { _ in
            // Aquí se establece el estatus en "publicado"
            
            self.elEvento.nombre = nombre
            self.elEvento.estatus = "publicado"
            self.elEvento.lugar = lugar
            self.elEvento.plazas = plazas
            self.elEvento.fechaInicio = self.datePickerInicio.date
            self.elEvento.fechaTermino = self.datePickerTermino.date
            self.elEvento.duenoAdmin = SessionManager.usuarioActual


            DataManager.shared.saveContext()

            self.dismiss(animated: true)

        }))

        confirm.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        self.present(confirm, animated: true)
    }
    
    @objc func guardarCambios() {
        print("En guardarCambios Inicio: \(String(describing: elEvento.fechaInicio))")
        print("En guardarCambios Término: \(String(describing: elEvento.fechaTermino))")
        
        if datePickerTermino.date < datePickerInicio.date {
            let alerta = UIAlertController(
                title: "Error",
                message: "La fecha de término no puede ser anterior a la de inicio.",
                preferredStyle: .alert
            )
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
            return
        }


        guard let nombre = detalle.txtNombre.text, !nombre.isEmpty,
              let lugar = detalle.txtLugar.text,
              let plazasStr = detalle.txtPlazas.text,
              let plazas = Int16(plazasStr) else {
            let alerta = UIAlertController(title: "Faltan datos", message: "Revisa los campos", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            present(alerta, animated: true)
            return
        }

        let confirm = UIAlertController(
            title: "Guardar cambios",
            message: "¿Deseas actualizar la información del evento?",
            preferredStyle: .alert
        )

        confirm.addAction(UIAlertAction(title: "Cancelar", style: .cancel))

        confirm.addAction(UIAlertAction(title: "Guardar", style: .default, handler: { _ in
            self.actualizarEvento(
                nombre: nombre,
                lugar: lugar,
                plazas: plazas
            )
        }))

        present(confirm, animated: true)
    }
    @objc func confirmarFechaInicio() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        detalle.txtFechaInicio.text = formatter.string(from: datePickerInicio.date)
        detalle.txtFechaInicio.resignFirstResponder()
        verificarCambios()
    }

    @objc func confirmarFechaTermino() {
        let fechaInicio = datePickerInicio.date
        let fechaTermino = datePickerTermino.date

        if fechaTermino < fechaInicio {
            // Mostrar alerta
            let alerta = UIAlertController(
                title: "Fecha inválida",
                message: "La fecha de término no puede ser anterior a la de inicio.",
                preferredStyle: .alert
            )
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)

            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        detalle.txtFechaTermino.text = formatter.string(from: fechaTermino)
        detalle.txtFechaTermino.resignFirstResponder()
        verificarCambios()
    }


    @objc func cancelarPicker() {
        view.endEditing(true)
    }


    private func actualizarEvento(nombre: String, lugar: String, plazas: Int16) {
        // Obtener coordenadas primero
        obtenerCoordenadasDesdeDireccion(lugar) { coordenadas in
            DispatchQueue.main.async {
                self.elEvento.nombre = nombre
                self.elEvento.lugar = lugar
                self.elEvento.plazas = plazas
                self.elEvento.fechaInicio = self.datePickerInicio.date
                self.elEvento.fechaTermino = self.datePickerTermino.date

                if let coord = coordenadas {
                    self.elEvento.latitud = coord.latitude
                    self.elEvento.longitud = coord.longitude
                    print("📍 Coordenadas guardadas: \(coord.latitude), \(coord.longitude)")
                } else {
                    print("⚠️ No se pudieron obtener coordenadas")
                }

                DataManager.shared.saveContext()
                NotificationCenter.default.post(name: Notification.Name("EVENTO_EDITADO"), object: nil)
                self.dismiss(animated: true)
            }
        }
    }

    
    
    @objc
    func publicarEvento () {
        guard let nombre = detalle.txtNombre.text, !nombre.isEmpty,
              let lugar = detalle.txtLugar.text,
              let plazasStr = detalle.txtPlazas.text,
              let plazas = Int16(plazasStr) else {
            let alerta = UIAlertController(title: "Faltan datos", message: "Revisa los campos", preferredStyle: .alert)
            alerta.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alerta, animated: true)
            return
        }

        let ac = UIAlertController(
            title: "Publicando",
            message: "¿Deseas publicar el evento '\(nombre)'?",
            preferredStyle: .alert
        )

        let action = UIAlertAction(title: "Sí", style: .default) { _ in
            
            print("En pub Inicio: \(String(describing: self.elEvento.fechaInicio))")
            print("En pub Término: \(String(describing: self.elEvento.fechaTermino))")
            // 🧠 Guardar cambios antes de publicar
            self.elEvento.nombre = nombre
            self.elEvento.lugar = lugar
            self.elEvento.plazas = plazas
            self.elEvento.estatus = "publicado"
            self.elEvento.fechaInicio = self.datePickerInicio.date
            self.elEvento.fechaTermino = self.datePickerTermino.date

            DataManager.shared.saveContext()

            NotificationCenter.default.post(name: Notification.Name("EVENTO_EDITADO"), object: nil)

            self.dismiss(animated: true)
        }

        let cancel = UIAlertAction(title: "No", style: .cancel)
        ac.addAction(action)
        ac.addAction(cancel)
        self.present(ac, animated: true)
    }

    @objc
    func despublicarEvento () {
        print("click en despublicar")
        let nombreEvento = elEvento.nombre ?? ""
        let ac = UIAlertController(title: "Retirando de Publicados", message:"El evento \(nombreEvento) dejará de estar publicado.", preferredStyle: .alert)
        let action = UIAlertAction(title: "SI", style: .destructive) {
            alertaction in
            DataManager.shared.despublicarEvento(self.elEvento)
            self.dismiss(animated: true)
        }
        let action2 = UIAlertAction(title: "NO", style:.cancel)
        ac.addAction(action)
        ac.addAction(action2)
        self.present(ac, animated: true)
        
    }
    
   
    @objc
    func cancelarEvento () {
        let nombreEvento = elEvento.nombre ?? ""
        let ac = UIAlertController(title: "Cancelando", message:"Desea cancelar el evento \(nombreEvento)?", preferredStyle: .alert)
        let action = UIAlertAction(title: "SI", style: .destructive) {
            alertaction in
            DataManager.shared.cancelarEvento(self.elEvento)
            self.dismiss(animated: true)
        }
        let action2 = UIAlertAction(title: "NO", style:.cancel)
        ac.addAction(action)
        ac.addAction(action2)
        self.present(ac, animated: true)
        
    }
    @objc
    func borrar () {
        let nombreEvento = elEvento.nombre ?? ""
        let ac = UIAlertController(title: "Eliminando", message:"¿Desea eliminar el evento \(nombreEvento)?", preferredStyle: .alert)
        let action = UIAlertAction(title: "SI", style: .destructive) {
            alertaction in
            DataManager.shared.borrar(objeto:self.elEvento)
            self.dismiss(animated: true)
        }
        let action2 = UIAlertAction(title: "NO", style:.cancel)
        ac.addAction(action)
        ac.addAction(action2)
        self.present(ac, animated: true)
    }
   
    @objc func cambiarInscripcion() {
        print("@objc func cambiarInscripcion en EvDeViCont")
        guard let vendedor = sellerActual, let evento = elEvento else { return }

        let estabaInscrito = vendedor.eventos?.contains(evento) ?? false
        
     
        var mensaje = ""
        
        if estabaInscrito { mensaje = "Sera retirado del evento" }else{  mensaje =  "Será agregado al evento" }
        
        let ac = UIAlertController(title: "Solicitando evento", message: mensaje, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "SI", style: .destructive) {
            alertaction in
            
        
            if estabaInscrito {
                vendedor.removeFromEventos(evento)
                self.detalle.btnInscripcion.setTitle("Cancelar inscripción", for: .normal)
                self.detalle.btnInscripcion.backgroundColor = .darkGray

            } else {
                vendedor.addToEventos(evento)
                self.detalle.btnInscripcion.setTitle("Inscribirme", for: .normal)
                self.detalle.btnInscripcion.backgroundColor = .midgreen
            }

            // 👇 Estas dos líneas informan a CoreData que hubo un cambio en la relación
            vendedor.willChangeValue(forKey: "eventos")
            vendedor.didChangeValue(forKey: "eventos")

            do {
                try vendedor.managedObjectContext?.save()
                self.onCambioInscripcion?()
                print("💾 Cambios guardados")
                self.dismiss(animated: true)
          
            } catch {
                print("❗️Error guardando inscripción: \(error)")
            }
        }
        let action2 = UIAlertAction(title: "NO", style:.cancel)
        ac.addAction(action)
        ac.addAction(action2)
        self.present(ac, animated: true)
    }

    @objc func verificarCambios() {
        let nombre = detalle.txtNombre.text ?? ""
        let lugar = detalle.txtLugar.text ?? ""
        let plazas = detalle.txtPlazas.text ?? ""
        let fechaInicio = detalle.txtFechaInicio.text ?? ""
        let fechaTermino = detalle.txtFechaTermino.text ?? ""

        let huboCambios = (nombre != nombreOriginal) ||
                           (lugar != lugarOriginal) ||
                           (plazas != plazasOriginal) ||
                           (fechaInicio != fechaInicioOriginal) ||
                           (fechaTermino != fechaTerminoOriginal)


        detalle.btnGuardarCambios.isEnabled = huboCambios
        detalle.btnGuardarCambios.alpha = huboCambios ? 1.0 : 0.5
    }
    
    func vendedorEstaInscrito() -> Bool {
        guard let vendedor = sellerActual else { return false }
        return vendedor.eventos?.contains(elEvento!) ?? false
    }
    
    @objc
    func solicitar() {
        guard let vendedor = sellerActual, let evento = elEvento else { return }

        let contexto = DataManager.shared.persistentContainer.viewContext
        let request: NSFetchRequest<Inscripcion> = Inscripcion.fetchRequest()
        request.predicate = NSPredicate(format: "vendedor == %@ AND evento == %@", vendedor, evento)
        
        if let inscripcionExistente = try? contexto.fetch(request).first {
            // Ya existe inscripción → cancelar
            let estatusActual = inscripcionExistente.estatus ?? ""
            if estatusActual == "solicitado" || estatusActual == "aceptado" {
                let ac = UIAlertController(title: "Cancelar", message: "¿Desea cancelar su \(estatusActual)?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Sí", style: .destructive) { _ in
                    DataManager.shared.cancelarInscripcion(vendedor: vendedor, de: evento)
                    self.onInscripcionCambiada?()
                    self.dismiss(animated: true)
                })
                ac.addAction(UIAlertAction(title: "No", style: .cancel))
                self.present(ac, animated: true)
            } else {
                // Otros estados
                print("⚠️ Estado no cancelable: \(estatusActual)")
            }
        } else {
            // No existe inscripción → solicitar
            let ac = UIAlertController(title: "Solicitar", message: "¿Desea solicitar su inscripción al evento \(evento.nombre ?? "")?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Sí", style: .destructive) { _ in
                DataManager.shared.solicitarInscripcion(vendedor: vendedor, al: evento)
                self.onInscripcionCambiada?()
                self.dismiss(animated: true)
            })
            ac.addAction(UIAlertAction(title: "No", style: .cancel))
            self.present(ac, animated: true)
        }
    }
   
    
    func actualizarEstadoBotonInscripcion() {
        guard let vendedor = sellerActual, let evento = elEvento else {
            detalle.btnInscripcion.isHidden = true
            return
        }

        // Buscar inscripción existente
        let contexto = DataManager.shared.persistentContainer.viewContext
        let request: NSFetchRequest<Inscripcion> = Inscripcion.fetchRequest()
        request.predicate = NSPredicate(format: "vendedor == %@ AND evento == %@", vendedor, evento)
        
        if let inscripcion = try? contexto.fetch(request).first, let estatus = inscripcion.estatus {
            switch estatus {
            case "solicitado":
                detalle.btnInscripcion.setTitle("Cancelar solicitud", for: .normal)
                detalle.btnInscripcion.backgroundColor = .darkrose
            case "aceptado":
                detalle.btnInscripcion.setTitle("Cancelar inscripción", for: .normal)
                detalle.btnInscripcion.backgroundColor = .darkGray
            case "cancelado":
                detalle.btnInscripcion.setTitle("Cancelado", for: .normal)
                detalle.btnInscripcion.backgroundColor = .systemGray
                detalle.btnInscripcion.isEnabled = false
            default:
                detalle.btnInscripcion.setTitle("Solicitar inscripción", for: .normal)
                detalle.btnInscripcion.backgroundColor = .amber
            }
        } else {
            // No existe inscripción aún
            detalle.btnInscripcion.setTitle("Solicitar inscripción", for: .normal)
            detalle.btnInscripcion.backgroundColor = .amber
        }
    }
    
    @objc func mostrarDatePickerInicio() {
        detalle.txtFechaInicio.inputView = datePickerInicio
        detalle.txtFechaInicio.inputAccessoryView = toolbar
        detalle.txtFechaInicio.becomeFirstResponder()
    }

    
    func obtenerCoordenadasDesdeDireccion(_ direccion: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(direccion) { placemarks, error in
            if let error = error {
                print("❌ Error al geocodificar: \(error.localizedDescription)")
                completion(nil)
                return
            }

            if let location = placemarks?.first?.location {
                completion(location.coordinate)
            } else {
                completion(nil)
            }
        }
    }
    func createToolbar(selectorDone: Selector, selectorCancel: Selector) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()

        let cancel = UIBarButtonItem(title: "Cancelar", style: .plain, target: self, action: selectorCancel)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Hecho", style: .done, target: self, action: selectorDone)

        toolbar.setItems([cancel, space, done], animated: false)
        return toolbar
    }
}


