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
                let id = entity.value(forKey: "id") as? Int,
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
        //increase name up to photosArray.count
        let requestIncrease = NSFetchRequest<NSFetchRequestResult>(entityName: "Character")
        let titleSort = NSSortDescriptor(key: "id", ascending: true)
        requestIncrease.sortDescriptors = [titleSort]
        //        let managedObjectContext =
        //            CoredataStack.mainContext

        var curI = 0
        for el in usersCur {
            print("el = \(el)")
            print("el[\"id\"]  = \(String(describing: el.id))  ")
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Character")
            request.predicate = NSPredicate(format: "(id == %@)",
                                            argumentArray: [el.id as Any])
            do {
                let managedObjectContext = CoreDataStack.shared.persistentContainer.viewContext //CoredataStack.shared.persistentContainer.viewContext
                if let fetchedObjects = try managedObjectContext.fetch(request) as? [Character] {
                    if fetchedObjects.count == 0 {
                        //save new in local database
                        
                        let curUser = NSEntityDescription.insertNewObject(forEntityName: "Character", into: managedObjectContext) as? Character
                        curUser?.id =  Int64(Int(el.id))
                        curUser?.created = el.created
                        curUser?.name = el.name
                        curUser?.image = el.image
                        curUser?.species = el.species

                        managedObjectContext.performAndWait { () -> Void in
                            if managedObjectContext.hasChanges {
                                do {
                                    try managedObjectContext.save()
                                } catch let error {
                                    print(error)
                                }
                            }
                        }
                        curI = curI + 1
                    }
                }
            } catch {
                fatalError("Failed to fetch UserCur: \(error)")
                //return nil
            }
        }
    }

    func deleteAllUsers() {
        let userEntities: [NSManagedObject] = coreDataWorker.fetchEntities(
            entityName: "Character",
            predicate: nil,
            sortDescriptors: nil
        )
        
        coreDataWorker.performBackgroundTask { context in
            for entity in userEntities {
                context.delete(entity)
            }
        }
    }
}
