import UIKit

@objc protocol DetailedRoutingLogic {
}

protocol DetailedDataPassing {
    var dataStore: DetailedDataStore? { get }
}

class DetailedRouter: NSObject, DetailedRoutingLogic, DetailedDataPassing {
    weak var viewController: DetailedViewController?
    var dataStore: DetailedDataStore?
    
    // MARK: Routing

}
