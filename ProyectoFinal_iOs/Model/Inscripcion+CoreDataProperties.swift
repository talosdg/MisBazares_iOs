//
//  Inscripcion+CoreDataProperties.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 27/06/25.
//
//

import Foundation
import CoreData


extension Inscripcion {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Inscripcion> {
        return NSFetchRequest<Inscripcion>(entityName: "Inscripcion")
    }

    @NSManaged public var estatus: String?
    @NSManaged public var evento: Eventos?
    @NSManaged public var vendedor: Vendedores?

}

extension Inscripcion : Identifiable {

}
