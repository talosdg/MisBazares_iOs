//
//  Evento.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 12/06/25.
//

import Foundation

// MARK: - EventosVO
struct EventosVO: Codable {
    let id: Int16
    let nombre: String
    let estatus: String?
    let lugar: String?
    let plazas: Int16
    let tipo: String?
    let vendedor: String?
    let latitud: Double?
    let longitud: Double?
    let fechaInicio: Date?
    let fechaTermino: Date?
    let duenoAdmin: String?
}


//typealias Empty = [EventosVO]

