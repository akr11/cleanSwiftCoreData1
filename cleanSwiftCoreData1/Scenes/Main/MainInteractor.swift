import UIKit

protocol MainBusinessLogic {
    func fetchCartoonCharacters(request: Main.displayCartoonCharacters.Request)
    func saveSelectedItem(character: Main.displayCartoonCharacters.ViewModel.characterInformationModel)
}

protocol MainDataStore {
    var chosenCharacter: CharResult? { get set }
}

class MainInteractor: MainBusinessLogic, MainDataStore {
    
    var presenter: MainPresentationLogic?
    var worker: MainWorker?
    var characters: [CharResult] = []
    var chosenCharacter: CharResult?
    private let network = Network()
    var dataStoreWorker: UserDataStoreWorkerProtocol

    init(
//        networkWorker: UserNetworkWorkerProtocol = UserNetworkWorker(),
        dataStoreWorker: UserDataStoreWorkerProtocol = UserDataStoreWorker()
    ) {
//        self.networkWorker = networkWorker
        self.dataStoreWorker = dataStoreWorker
    }

    // MARK: class functions
    
    func fetchCartoonCharacters(request: Main.displayCartoonCharacters.Request) {

        let cachedUsers = dataStoreWorker.fetchUsers()

        // If we have cached data and don't need to refresh, use it
        if !cachedUsers.isEmpty && !request.forceRefresh {
            presenter?.presentFetchedCartoonCharactersFromDB(responseFromDB: cachedUsers)
            self.characters.removeAll()
            for el in cachedUsers {
                let el1 = CharResult(id: el.id, name: el.name, status: Status.unknown, species: el.species, type: "", gender: Gender.unknown, origin: Location(name: "", url: ""), location: Location(name: "", url: ""), image: el.image, episode: [""], url: "", created: el.created)
                self.characters.append(el1)
            }
            return
        }

        network.fatchCharacters { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    let characters = result.results
                    self?.characters.removeAll()
                    self?.characters = characters
                    let response = Main.displayCartoonCharacters.Response(characters: characters)

                    // Save to Core Data in background
//                    self?.dataStoreWorker.saveUsers(characters)
                    self?.dataStoreWorker.treatmentUsers(characters)

                    self?.presenter?.presentFetchedCartoonCharacters(response: response)
                case .failure(let failure):
                    print(failure)
//                    if !cachedUsers.isEmpty {
//                        self.presenter?.presentUsers(response: UserListScene.FetchUsers.Response(
//                            users: cachedUsers,
//                            error: nil
//                        ))
//                    } else {
//                        // Otherwise, present the error
//                        self.presenter?.presentUsers(response: UserListScene.FetchUsers.Response(
//                            users: nil,
//                            error: error
//                        ))
//                    }
                }
            }
        }
    }
    
    func saveSelectedItem(character: Main.displayCartoonCharacters.ViewModel.characterInformationModel) {
        for characterItem in characters {
            if characterItem.id == character.id {
                chosenCharacter = characterItem
                break
            }
        }
    }
}





