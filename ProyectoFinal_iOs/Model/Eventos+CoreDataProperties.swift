//
//  Eventos+CoreDataProperties.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 12/06/25.
//
//

import Foundation
import CoreData


extension Eventos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Eventos> {
        return NSFetchRequest<Eventos>(entityName: "Eventos")
        
    }

    @NSManaged public var plazas: Int16
    @NSManaged public var lugar: String?
    @NSManaged public var id: Int16
    @NSManaged public var nombre: String?
    @NSManaged public var estatus: String?
    @NSManaged public var vendedor: NSSet?

}

// MARK: Generated accessors for vendedor
extension Eventos {

    @objc(addVendedorObject:)
    @NSManaged public func addToVendedor(_ value: Vendedores)

    @objc(removeVendedorObject:)
    @NSManaged public func removeFromVendedor(_ value: Vendedores)

    @objc(addVendedor:)
    @NSManaged public func addToVendedor(_ values: NSSet)

    @objc(removeVendedor:)
    @NSManaged public func removeFromVendedor(_ values: NSSet)

}

extension Eventos : Identifiable {

}
