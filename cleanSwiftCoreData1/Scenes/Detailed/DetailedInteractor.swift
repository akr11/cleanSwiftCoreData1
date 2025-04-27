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
    let network = Network()
    var presenter: DetailedPresentationLogic?
    var worker: DetailedWorker?
    
    // MARK: Do something
    
    func fetchDetailedInformation() {
        var cashedImage = UIImage()
//        var url1 = URL(string: "https://github.com/")
        if let imageString = character?.image,
           let url = URL(string: imageString) {
//            url1 = url
            KingfisherManager.shared.retrieveImage(with: url) { result in
                if case .success(let value) = result {
                    DispatchQueue.main.async {
                        cashedImage = value.image
                    }
                } else {
                    print("no image")
                }
            }
        } else {
            return
        }

        DispatchQueue.main.async {
                let response = Detailed.displayDetailedInformation.Response(
                    name: self.character?.name ?? "",
                    species: self.character?.species ?? "",
                    image: cashedImage,
                    imageUrl: self.character?.image ?? "")
            self.presenter?.presentDetailedInformation(response: response)
        }

//        network.loadImage(for: url1!) { [weak self] result in
//            DispatchQueue.main.async {
//                switch result {
//                case .success(let fetchedImage):
//                    let response = Detailed.displayDetailedInformation.Response(
//                        name: self?.character?.name ?? "",
//                        species: self?.character?.species ?? "",
//                        image: fetchedImage ?? cashedImage,
//                        imageUrl: self?.character?.image ?? "")
//                    self?.presenter?.presentDetailedInformation(response: response)
//                case .failure(_):
//                    let response = Detailed.displayDetailedInformation.Response(
//                        name: self?.character?.name ?? "",
//                        species: self?.character?.species ?? "",
//                        image: cashedImage,
//                        imageUrl: self?.character?.image ?? "")
//                    self?.presenter?.presentDetailedInformation(response: response)
//                    break
//                }
//            }
//        }
    }
}


