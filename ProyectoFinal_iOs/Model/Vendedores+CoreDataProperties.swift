//
//  Vendedores+CoreDataProperties.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 27/06/25.
//
//

import Foundation
import CoreData


extension Vendedores {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Vendedores> {
        return NSFetchRequest<Vendedores>(entityName: "Vendedores")
    }

    @NSManaged public var apellido_materno: String?
    @NSManaged public var apellido_paterno: String?
    @NSManaged public var ciudad: String?
    @NSManaged public var email: String?
    @NSManaged public var estado: String?
    @NSManaged public var id: Int16
    @NSManaged public var rol: Int16
    @NSManaged public var nombre: String?
    @NSManaged public var tel: String?
    @NSManaged public var eventos: NSSet?
    @NSManaged public var inscripciones: NSSet?

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

// MARK: Generated accessors for inscripciones
extension Vendedores {

    @objc(addInscripcionesObject:)
    @NSManaged public func addToInscripciones(_ value: Inscripcion)

    @objc(removeInscripcionesObject:)
    @NSManaged public func removeFromInscripciones(_ value: Inscripcion)

    @objc(addInscripciones:)
    @NSManaged public func addToInscripciones(_ values: NSSet)

    @objc(removeInscripciones:)
    @NSManaged public func removeFromInscripciones(_ values: NSSet)

}

extension Vendedores : Identifiable {

}
