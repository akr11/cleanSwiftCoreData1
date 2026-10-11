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

        if !cachedUsers.isEmpty && !request.forceRefresh {
            showCachedUsers(cachedUsers)
            return
        }

        network.fatchCharacters { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let result):
                    let characters = result.results
                    self?.characters = characters
                    let response = Main.displayCartoonCharacters.Response(characters: characters)
                    self?.dataStoreWorker.treatmentUsers(characters)
                    self?.presenter?.presentFetchedCartoonCharacters(response: response)
                case .failure(let failure):
                    print(failure)
                    if !cachedUsers.isEmpty {
                        self?.showCachedUsers(cachedUsers)
                    } else {
                        self?.presenter?.presentFetchFailed()
                    }
                }
            }
        }
    }

    private func showCachedUsers(_ cachedUsers: [Main.displayCartoonCharacters.ViewModel.characterInformationModel]) {
        characters = cachedUsers.map { el in
            CharResult(
                id: el.id,
                name: el.name,
                status: .unknown,
                species: el.species,
                type: "",
                gender: .unknown,
                origin: Location(name: "", url: ""),
                location: Location(name: "", url: ""),
                image: el.image,
                episode: [""],
                url: "",
                created: el.created
            )
        }
        presenter?.presentFetchedCartoonCharactersFromDB(responseFromDB: cachedUsers)
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





