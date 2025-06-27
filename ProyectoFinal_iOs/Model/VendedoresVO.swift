//
//  VendedoresVO.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 12/06/25.
//

import Foundation

struct VendedoresVO: Codable {
    let id: Int16?
    let nombre: String?
    let apellidoPaterno: String?
    let apellidoMaterno: String?
    let ciudad: String?
    let estado: String?
    let email: String?
    let tel: String?
    let eventos: [Int16]? 

}
