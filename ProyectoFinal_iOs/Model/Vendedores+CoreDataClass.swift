//
//  Vendedores+CoreDataClass.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 27/06/25.
//
//

import Foundation
import CoreData


public class Vendedores: NSManagedObject {
    
    func inicializa(_ vendedoresVO: VendedoresVO, context: NSManagedObjectContext) {
        self.id = vendedoresVO.id ?? 0
        self.nombre = vendedoresVO.nombre
        self.apellido_paterno = vendedoresVO.apellidoPaterno
        self.apellido_materno = vendedoresVO.apellidoMaterno
        self.ciudad = vendedoresVO.ciudad
        self.estado = vendedoresVO.estado
        self.email = vendedoresVO.email
        self.tel = vendedoresVO.tel

        // Relación: eventos
        if let ids = vendedoresVO.eventos {
            for eid in ids {
                if let evento = buscarEventoPorID(eid, context: context) {
                    self.addToEventos(evento)
                }
            }
        }
    }

    private func buscarEventoPorID(_ id: Int16, context: NSManagedObjectContext) -> Eventos? {
        let req: NSFetchRequest<Eventos> = Eventos.fetchRequest()
        req.predicate = NSPredicate(format: "id == %d", id)
        req.fetchLimit = 1
        return try? context.fetch(req).first
    }

}
