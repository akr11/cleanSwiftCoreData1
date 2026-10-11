import CoreData

// MARK: - Core Data Character Worker
protocol UserDataStoreWorkerProtocol {
    func fetchUsers() -> [Main.displayCartoonCharacters.ViewModel.characterInformationModel]
    func saveUsers(_ apiUsers: [CharResult])
    func treatmentUsers(_ usersCur: [CharResult])
    func deleteAllUsers()
}

class UserDataStoreWorker: UserDataStoreWorkerProtocol {
    private let coreDataWorker: CoreDataWorkerProtocol
    private let dateFormatter: DateFormatter
    
    init(coreDataWorker: CoreDataWorkerProtocol = CoreDataWorker()) {
        self.coreDataWorker = coreDataWorker
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    }
    
    func fetchUsers() -> [Main.displayCartoonCharacters.ViewModel.characterInformationModel] {
        let userEntities: [NSManagedObject] = coreDataWorker.fetchEntities(
            entityName: "Character",
            predicate: nil,
            sortDescriptors: [NSSortDescriptor(key: "id", ascending: true)]
        )
        
        return userEntities.compactMap { entity in
            guard
                let id = (entity.value(forKey: "id") as? NSNumber)?.intValue,
                let name = entity.value(forKey: "name") as? String,
                let species = entity.value(forKey: "species") as? String,
                let image = entity.value(forKey: "image") as? String,
                let created = entity.value(forKey: "created") as? String
            else {
                return nil
            }
            
            return Main.displayCartoonCharacters.ViewModel.characterInformationModel (
                id: id,
                name: name,
                species: species,
                image: image,
                created: created
            )
        }
    }
    
    func saveUsers(_ apiUsers: [CharResult]) {
        coreDataWorker.performBackgroundTask { context in
            for apiUser in apiUsers {
                if let userEntity: NSManagedObject = self.coreDataWorker.createEntity(
                    entityName: "Character",
                    in: context
                ) {
                    userEntity.setValue(apiUser.id, forKey: "id")
                    userEntity.setValue(apiUser.name, forKey: "name")
                    userEntity.setValue(apiUser.species, forKey: "species")
                    userEntity.setValue(apiUser.image, forKey: "image")
                    userEntity.setValue(apiUser.created, forKey: "created")
                }
            }
        }
    }

    func treatmentUsers(_ usersCur: [CharResult]) {
        let managedObjectContext = CoreDataStack.shared.viewContext
        for el in usersCur {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Character")
            request.predicate = NSPredicate(format: "id == %lld", Int64(el.id))
            do {
                let count = try managedObjectContext.count(for: request)
                if count == 0 {
                    let curUser = NSEntityDescription.insertNewObject(forEntityName: "Character", into: managedObjectContext)
                    curUser.setValue(Int64(el.id), forKey: "id")
                    curUser.setValue(el.created, forKey: "created")
                    curUser.setValue(el.name, forKey: "name")
                    curUser.setValue(el.image, forKey: "image")
                    curUser.setValue(el.species, forKey: "species")
                }
            } catch {
                print("Failed to fetch Character: \(error)")
            }
        }

        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }

    func deleteAllUsers() {
        let context = CoreDataStack.shared.viewContext
        context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "Character")
            let entities = (try? context.fetch(request)) ?? []
            entities.forEach { context.delete($0) }
            CoreDataStack.shared.saveContext(context)
        }
    }
}
