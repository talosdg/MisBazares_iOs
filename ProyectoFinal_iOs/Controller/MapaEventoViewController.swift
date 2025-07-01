//
//  MapaEventoViewController.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 30/06/25.
//
import UIKit
import MapKit
import CoreLocation

class MapaEventoViewController: UIViewController, MKMapViewDelegate {

    var mapView: MKMapView!
    
    var coordenadaEvento: CLLocationCoordinate2D?
    var direccionEvento: String?
    var nombreEvento: String = "Evento"
    var lugarEvento: String = "Dirección"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Crear y agregar el mapa
        mapView = MKMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(mapView)
        mapView.delegate = self

        if let coord = coordenadaEvento {
            mostrarMapa(coordenada: coord, subtitulo: direccionEvento ?? "Ubicación del evento")
        } else if let direccion = direccionEvento {
            geocodificar(direccion: direccion)
        } else {
            // Coordenadas por defecto
            mostrarMapa(coordenada: CLLocationCoordinate2D(latitude: 19.3326, longitude: -99.1820),
                        subtitulo: "Ubicación no disponible")
        }

        agregarBotonCerrar()
    }

    func geocodificar(direccion: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(direccion) { [weak self] placemarks, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let location = placemarks?.first?.location {
                    self.mostrarMapa(coordenada: location.coordinate, subtitulo: direccion)
                } else {
                    self.mostrarMapa(coordenada: CLLocationCoordinate2D(latitude: 19.3326, longitude: -99.1820),
                                     subtitulo: "No se pudo ubicar dirección")
                }
            }
        }
    }

    func mostrarMapa(coordenada: CLLocationCoordinate2D, subtitulo: String) {
        let region = MKCoordinateRegion(center: coordenada, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)

        mapView.removeAnnotations(mapView.annotations)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordenada
        annotation.title = nombreEvento
        annotation.subtitle = lugarEvento
        mapView.addAnnotation(annotation)
    }

    func agregarBotonCerrar() {
        let cerrarButton = UIButton(type: .system)
        cerrarButton.setTitle("Cerrar", for: .normal)
        cerrarButton.backgroundColor = .systemBlue
        cerrarButton.setTitleColor(.white, for: .normal)
        cerrarButton.layer.cornerRadius = 8
        cerrarButton.translatesAutoresizingMaskIntoConstraints = false
        cerrarButton.addTarget(self, action: #selector(cerrarMapa), for: .touchUpInside)
        view.addSubview(cerrarButton)

        NSLayoutConstraint.activate([
            cerrarButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            cerrarButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cerrarButton.widthAnchor.constraint(equalToConstant: 80),
            cerrarButton.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    @objc func cerrarMapa() {
        dismiss(animated: true)
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }

        let identifier = "eventoMarker"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.markerTintColor = .systemRed
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            annotationView?.annotation = annotation
        }
        return annotationView
    }
}
