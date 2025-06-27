//
//  Iconos.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 24/06/25.
//

import UIKit

enum Iconos {
    static func icono(_ tipo: TipoIcono, color: UIColor = .label, size: CGFloat = 24) -> UIImageView {
        let imagen = UIImageView(image: UIImage(systemName: tipo.rawValue))
        imagen.tintColor = color
        imagen.frame = CGRect(x: 0, y: 0, width: size, height: size)
        imagen.contentMode = .scaleAspectFit
        return imagen
    }
    
    enum TipoIcono: String {
        case oferta = "tag.fill"
        case saludo = "figure.wave"
        case info = "info.circle"
        case inscrito = "checkmark.circle.fill"
        case pendiente = "clock.fill"
        case cancelado = "xmark.circle.fill"
        case solicitar = "hand.point.up.fill"
    }
}
