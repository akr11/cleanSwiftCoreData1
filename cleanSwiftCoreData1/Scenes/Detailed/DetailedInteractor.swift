import UIKit
import Kingfisher

protocol DetailedBusinessLogic {
    func fetchDetailedInformation()
}

protocol DetailedDataStore {
    var character: CharResult? { get set }
}

class DetailedInteractor: DetailedBusinessLogic, DetailedDataStore {
    var character: CharResult?
    var presenter: DetailedPresentationLogic?
    var worker: DetailedWorker?
    
    // MARK: Do something
    
    func fetchDetailedInformation() {
        guard let character else { return }
        let imageUrl = character.image

        guard let url = URL(string: imageUrl) else {
            presentDetails(for: character, image: nil, imageUrl: imageUrl)
            return
        }

        KingfisherManager.shared.retrieveImage(with: url) { [weak self] result in
            let image: UIImage?
            if case .success(let value) = result {
                image = value.image
            } else {
                image = nil
            }
            DispatchQueue.main.async {
                self?.presentDetails(for: character, image: image, imageUrl: imageUrl)
            }
        }
    }

    private func presentDetails(for character: CharResult, image: UIImage?, imageUrl: String) {
        let response = Detailed.displayDetailedInformation.Response(
            name: character.name,
            species: character.species,
            image: image,
            imageUrl: imageUrl
        )
        presenter?.presentDetailedInformation(response: response)
    }
}


