//
//  Eventos+CoreDataClass.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 30/06/25.
//
//

import Foundation
import CoreData


public class Eventos: NSManagedObject {
    @nonobjc public override init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
    }
    
    @nonobjc public init(context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entity(forEntityName: "Eventos", in: context)!
        super.init(entity: entity, insertInto: context)
    }
        func inicializa(_ eventosVO: EventosVO) {
        self.id = eventosVO.id
        self.nombre = eventosVO.nombre
        self.estatus = eventosVO.estatus
        self.lugar = eventosVO.lugar
        self.plazas = eventosVO.plazas
        self.latitud = eventosVO.latitud ?? 0
        self.longitud = eventosVO.longitud ?? 0
        self.duenoAdmin = eventosVO.duenoAdmin
            
        self.fechaInicio = eventosVO.fechaInicio
        self.fechaTermino = eventosVO.fechaTermino

    }
}
