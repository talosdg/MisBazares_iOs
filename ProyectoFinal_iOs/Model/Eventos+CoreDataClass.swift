//
//  Eventos+CoreDataClass.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 12/06/25.
//
//

import Foundation
import CoreData

@objc(Eventos)
public class Eventos: NSManagedObject {
    func inicializa(_ eventosVO:EventosVO){
        self.id = eventosVO.id
        self.nombre = eventosVO.nombre
        self.estatus = eventosVO.estatus
        self.lugar = eventosVO.lugar
        self.plazas = eventosVO.plazas
        
        
    }

}
