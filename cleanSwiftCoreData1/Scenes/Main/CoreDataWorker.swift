//
//  CoreDataWorker.swift
//  cleanSwiftCoreData1
//
//  Created by andriy kruglyanko on 27.04.2025.
//

import CoreData

protocol CoreDataWorkerProtocol {
    func fetchEntities<T: NSManagedObject>(entityName: String, predicate: NSPredicate?, sortDescriptors: [NSSortDescriptor]?) -> [T]
    func saveEntity<T: NSManagedObject>(_ entity: T, in context: NSManagedObjectContext?) -> Bool
    func deleteEntity<T: NSManagedObject>(_ entity: T, in context: NSManagedObjectContext?) -> Bool
    func createEntity<T: NSManagedObject>(entityName: String, in context: NSManagedObjectContext?) -> T?
    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void)
}

class CoreDataWorker: CoreDataWorkerProtocol {
    private let coreDataStack: CoreDataStack
//    let managedObjectContext =
//        CoredataStack.mainContext

    init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
        self.coreDataStack = coreDataStack
    }

    func fetchEntities<T: NSManagedObject>(entityName: String, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [T] {
        let context = coreDataStack.viewContext
        let fetchRequest = NSFetchRequest<T>(entityName: entityName)
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptors

        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Error fetching \(entityName): \(error)")
            return []
        }
    }

    func saveEntity<T: NSManagedObject>(_ entity: T, in context: NSManagedObjectContext? = nil) -> Bool {
        let context = context ?? coreDataStack.viewContext

        do {
            try context.save()
            return true
        } catch {
            print("Error saving entity: \(error)")
            return false
        }
    }

    func deleteEntity<T: NSManagedObject>(_ entity: T, in context: NSManagedObjectContext? = nil) -> Bool {
        let context = context ?? coreDataStack.viewContext
//        managedObjectContext.delete(entity)

        do {
            try context.save()
            return true
        } catch {
            print("Error deleting entity: \(error)")
            return false
        }
    }

    func createEntity<T: NSManagedObject>(entityName: String, in context: NSManagedObjectContext? = nil) -> T? {
        let context = context ?? coreDataStack.viewContext
        guard let entity = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? T else {
            return nil
        }
        return entity
    }

    func performBackgroundTask(_ task: @escaping (NSManagedObjectContext) -> Void) {
        let context = coreDataStack.backgroundContext()
        context.perform {
            task(context)
            self.coreDataStack.saveContext(context)
        }
    }
}
