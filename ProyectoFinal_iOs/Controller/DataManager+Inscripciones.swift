//
//  DataManager+Vendedores.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 27/06/25.
//

import Foundation
import CoreData

extension DataManager {

    func solicitarInscripcion(vendedor: Vendedores, al evento: Eventos) {
        let context = persistentContainer.viewContext
        let fetch: NSFetchRequest<Inscripcion> = Inscripcion.fetchRequest()
        fetch.predicate = NSPredicate(format: "vendedor == %@ AND evento == %@", vendedor, evento)

        if let existentes = try? context.fetch(fetch), let existente = existentes.first {
            if existente.estatus == nil || existente.estatus == "" {
                existente.estatus = "solicitado"
                saveContext()
            }
            return
        }

        let nueva = Inscripcion(context: context)
        nueva.estatus = "solicitado"
        nueva.vendedor = vendedor
        nueva.evento = evento
        saveContext()

        NotificationCenter.default.post(name: .init("INSCRIP_STATUS_OBJECT"), object: evento)
    }

    func cancelarInscripcion(vendedor: Vendedores, de evento: Eventos) {
        let context = persistentContainer.viewContext
        let request: NSFetchRequest<Inscripcion> = Inscripcion.fetchRequest()
        request.predicate = NSPredicate(format: "vendedor == %@ AND evento == %@", vendedor, evento)
        if let resultado = try? context.fetch(request).first {
            context.delete(resultado)
            saveContext()
        }
    }

    func aprobarInscripcion(_ inscripcion: Inscripcion) {
        inscripcion.estatus = "aceptado"
        saveContext()
    }

    func cancelarInscripcion(_ inscripcion: Inscripcion) {
        inscripcion.estatus = "cancelado"
        saveContext()
    }

    func obtenerInscripcionesSolicitadas() -> [Inscripcion] {
        let request: NSFetchRequest<Inscripcion> = Inscripcion.fetchRequest()
        request.predicate = NSPredicate(format: "estatus == %@", "solicitado")
        return (try? persistentContainer.viewContext.fetch(request)) ?? []
    }

    func inscripcionesSolicitadasParaVendedor(_ vendedor: Vendedores) -> [Inscripcion] {
        let request: NSFetchRequest<Inscripcion> = Inscripcion.fetchRequest()
        request.predicate = NSPredicate(format: "vendedor == %@ AND estatus == %@", vendedor, "solicitado")
        return (try? persistentContainer.viewContext.fetch(request)) ?? []
    }

    func eventosDisponiblesParaVendedor(_ vendedor: Vendedores) -> [Eventos] {
        let context = persistentContainer.viewContext
        let fetchEventos: NSFetchRequest<Eventos> = Eventos.fetchRequest()
        fetchEventos.predicate = NSPredicate(format: "estatus == %@", "publicado")

        do {
            let publicados = try context.fetch(fetchEventos)
            let fetchInscripciones: NSFetchRequest<Inscripcion> = Inscripcion.fetchRequest()
            fetchInscripciones.predicate = NSPredicate(format: "vendedor == %@", vendedor)
            let inscripciones = try context.fetch(fetchInscripciones)
            let eventosInscritos = inscripciones.compactMap { $0.evento }
            return publicados.filter { !eventosInscritos.contains($0) }
        } catch {
            print("Error obteniendo eventos disponibles: \(error)")
            return []
        }
    }

    func obtenerEstatusInscripcion(vendedor: Vendedores, evento: Eventos) -> String? {
        let request: NSFetchRequest<Inscripcion> = Inscripcion.fetchRequest()
        request.predicate = NSPredicate(format: "vendedor == %@ AND evento == %@", vendedor, evento)
        request.fetchLimit = 1
        return try? persistentContainer.viewContext.fetch(request).first?.estatus
    }
}
