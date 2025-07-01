//
//  DataManager.swift
//  ProyectoFinal_iOs
//
//  Created by Edgar Vargas on 12/06/25.
//

import Foundation
import CoreData

class DataManager: NSObject {
    static let shared = DataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Eventos")
        container.loadPersistentStores { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error: \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error saving context: \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
