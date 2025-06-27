//
//  Vendedores+CoreDataProperties.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 12/06/25.
//
//

import Foundation
import CoreData


extension Vendedores {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vendedores> {
        return NSFetchRequest<Vendedores>(entityName: "Vendedores")
    }
    @NSManaged public var id: Int16
    @NSManaged public var apellido_materno: String?
    @NSManaged public var apellido_paterno: String?
    @NSManaged public var ciudad: String?
    @NSManaged public var eventos: NSSet? 
    @NSManaged public var email: String?
    @NSManaged public var estado: String?
    @NSManaged public var nombre: String?
    @NSManaged public var tel: String?

}

// MARK: Generated accessors for eventos
extension Vendedores {

    @objc(addEventosObject:)
    @NSManaged public func addToEventos(_ value: Eventos)

    @objc(removeEventosObject:)
    @NSManaged public func removeFromEventos(_ value: Eventos)

    @objc(addEventos:)
    @NSManaged public func addToEventos(_ values: NSSet)

    @objc(removeEventos:)
    @NSManaged public func removeFromEventos(_ values: NSSet)

}

extension Vendedores : Identifiable {

}
