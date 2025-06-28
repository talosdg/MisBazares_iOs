//
//  Eventos+CoreDataProperties.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 27/06/25.
//
//

import Foundation
import CoreData


extension Eventos {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Eventos> {
        return NSFetchRequest<Eventos>(entityName: "Eventos")
    }

    @NSManaged public var estatus: String?
    @NSManaged public var id: Int16
    @NSManaged public var lugar: String?
    @NSManaged public var nombre: String?
    @NSManaged public var plazas: Int16
    @NSManaged public var inscripciones: NSSet?
    @NSManaged public var vendedor: NSSet?

}

// MARK: Generated accessors for inscripciones
extension Eventos {

    @objc(addInscripcionesObject:)
    @NSManaged public func addToInscripciones(_ value: Inscripcion)

    @objc(removeInscripcionesObject:)
    @NSManaged public func removeFromInscripciones(_ value: Inscripcion)

    @objc(addInscripciones:)
    @NSManaged public func addToInscripciones(_ values: NSSet)

    @objc(removeInscripciones:)
    @NSManaged public func removeFromInscripciones(_ values: NSSet)

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
