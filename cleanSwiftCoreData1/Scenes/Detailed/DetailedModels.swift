import UIKit

enum Detailed {
    // MARK: Use cases
    
    enum displayDetailedInformation {
        struct Response {
            let name: String
            let species: String
            let image: UIImage
            let imageUrl: String
        }
        struct ViewModel {
            let name: String
            let species: String
            let image: UIImage
            let imageUrl: String
        }
    }
}
