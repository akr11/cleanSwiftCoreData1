import UIKit

protocol MainPresentationLogic {
    func presentFetchedCartoonCharacters(response: Main.displayCartoonCharacters.Response)
    func presentFetchedCartoonCharactersFromDB(responseFromDB: [Main.displayCartoonCharacters.ViewModel.characterInformationModel])
}

class MainPresenter: MainPresentationLogic {
    weak var viewController: MainDisplayLogic?
    
    // MARK: Do something
    
    func presentFetchedCartoonCharacters(response: Main.displayCartoonCharacters.Response) {

        let characterArray = response.characters

        var characterInformation: [Main.displayCartoonCharacters.ViewModel.characterInformationModel] = []

        for character in characterArray {
            let characterModel = Main.displayCartoonCharacters.ViewModel.characterInformationModel(
                id: character.id,
                name: character.name,
                species: character.species,
                image: character.image,
                created: character.created)
            characterInformation.append(characterModel)
        }

        let viewModel = Main.displayCartoonCharacters.ViewModel(characterInformation: characterInformation)

        viewController?.addCharactersToVariable(viewModel: viewModel)
    }

    func presentFetchedCartoonCharactersFromDB(responseFromDB: [Main.displayCartoonCharacters.ViewModel.characterInformationModel]) {

        let characterArray = responseFromDB

        var characterInformation: [Main.displayCartoonCharacters.ViewModel.characterInformationModel] = []

        for character in characterArray {
            let characterModel = Main.displayCartoonCharacters.ViewModel.characterInformationModel(
                id: character.id,
                name: character.name,
                species: character.species,
                image: character.image,
                created: character.created)
            characterInformation.append(characterModel)
        }

        let viewModel = Main.displayCartoonCharacters.ViewModel(characterInformation: characterInformation)

        viewController?.addCharactersToVariable(viewModel: viewModel)
    }
}
