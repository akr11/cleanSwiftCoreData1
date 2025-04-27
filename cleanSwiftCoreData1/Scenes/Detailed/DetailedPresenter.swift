import UIKit

protocol DetailedPresentationLogic {
    func presentDetailedInformation(response: Detailed.displayDetailedInformation.Response)
}

class DetailedPresenter: DetailedPresentationLogic {
    weak var viewController: DetailedDisplayLogic?
    
    // MARK: Do something
    
    func presentDetailedInformation(response: Detailed.displayDetailedInformation.Response) {
        let name = "Character name: " + response.name
        let species = "Character species: " + response.species
        let viewModel = Detailed.displayDetailedInformation.ViewModel(
            name: name,
            species: species,
            image: response.image,
            imageUrl: response.imageUrl)
        viewController?.displayCharacterInformation(viewModel: viewModel)
    }
}
