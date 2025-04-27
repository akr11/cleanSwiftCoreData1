import UIKit

enum Main {
    // MARK: Use cases
    
    enum displayCartoonCharacters {
        struct Request {
            let forceRefresh: Bool
        }
        struct Response {
            let characters: [CharResult]
        }
        struct ViewModel {
            struct characterInformationModel {
                let id: Int
                let name: String
                let species: String
                let image: String
                let created: String
            }
            var characterInformation: [characterInformationModel]
        }
    }
}
