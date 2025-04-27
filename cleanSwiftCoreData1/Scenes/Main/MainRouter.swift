import UIKit

@objc protocol MainRoutingLogic {
    func routeToDetailedViewController()
}

protocol MainDataPassing {
    var dataStore: MainDataStore? { get }
}

class MainRouter: NSObject, MainRoutingLogic, MainDataPassing {
    
    weak var viewController: MainViewController?
    var dataStore: MainDataStore?
    
    // MARK: Routing
    
    func routeToDetailedViewController() {

        let destinationVC = DetailedViewController()


        var destinationDS = destinationVC.router!.dataStore!
        passDataToSomewhere(source: dataStore!, destination: &destinationDS)
        navigateToSomewhere(source: viewController!, destination: destinationVC)

    }
    
    // MARK: Navigation
    
    func navigateToSomewhere(
        source: MainViewController,
        destination: DetailedViewController) {
            source.show(destination, sender: nil)
    }
    
    // MARK: Passing data
    
    func passDataToSomewhere(
        source: MainDataStore,
        destination: inout DetailedDataStore) {
            destination.character = source.chosenCharacter
    }
}
