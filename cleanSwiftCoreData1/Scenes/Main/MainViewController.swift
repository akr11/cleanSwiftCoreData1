import UIKit
import CoreData
import Kingfisher

protocol MainDisplayLogic: AnyObject {
    func addCharactersToVariable(viewModel: Main.displayCartoonCharacters.ViewModel)
}

class MainViewController: UIViewController, MainDisplayLogic, NSFetchedResultsControllerDelegate {

    // MARK: VIP variables
    
    var interactor: MainBusinessLogic?
    var router: (NSObjectProtocol & MainRoutingLogic & MainDataPassing)?
    
    // MARK: Class variables

    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!

    private lazy var mainTable = UITableView()
    private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return refreshControl
    }()

    private lazy var characters: [Main.displayCartoonCharacters.ViewModel.characterInformationModel] = []
    private var displayedUsers: [Main.displayCartoonCharacters.ViewModel.characterInformationModel] = []


    // MARK: Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController = self
        let interactor = MainInteractor()
        let presenter = MainPresenter()
        let router = MainRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    private func setupConstraints() {
        let safeArea = view.safeAreaLayoutGuide
        
        mainTable.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mainTable.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 0),
            mainTable.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 0),
            mainTable.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: 0),
            mainTable.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: 0)
        ])
    }
    
    private func mainTableSetup() {
        mainTable.delegate = self
        mainTable.dataSource = self
        mainTable.register(
            MainTableViewCell.self,
            forCellReuseIdentifier: "CharacterInformation")
    }

    @objc private func refreshData() {
        fetchUsers(forceRefresh: true)
    }

    private func fetchUsers(forceRefresh: Bool) {
//        let request = UserListScene.FetchUsers.Request(forceRefresh: forceRefresh)
        let request = Main.displayCartoonCharacters.Request(forceRefresh: forceRefresh)
        interactor?.fetchCartoonCharacters(request: request)
    }

    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(mainTable)
        mainTable.refreshControl = refreshControl
        mainTableSetup()
        setupConstraints()
        fetchUsers(forceRefresh: false)
//        requestCartoonCharacters()
    }
    
    // MARK: Class functions
    
//    private func requestCartoonCharacters() {
//        let request = Main.displayCartoonCharacters.Request(forceRefresh: Bool)
//        interactor?.fetchCartoonCharacters(request: request)
//    }
    
    func addCharactersToVariable(viewModel: Main.displayCartoonCharacters.ViewModel) {
        let characterInformation = viewModel.characterInformation
        self.characters = characterInformation
        mainTable.reloadData()
        refreshControl.endRefreshing()
    }

    //MARK: - fetched controller

    func initializeFetchedResultsController() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Character")
        let created_atSort = NSSortDescriptor(key: "created", ascending: true)
        request.sortDescriptors = [created_atSort]
        let managedObjectContext =
        CoreDataStack.shared.viewContext //.shared.viewContext

        fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = self


        do {
            try fetchedResultsController.performFetch()
            mainTable.reloadData()
        } catch {
            fatalError("Failed to initialize FetchedResultsController: \(error)")
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        print("photo didChange sectionInfo type = \(type)")
        self.mainTable.reloadData()
        switch type {
        case .insert:
            self.mainTable.performBatchUpdates({
                mainTable.insertSections(IndexSet(integer: sectionIndex), with: .automatic)
                mainTable.reloadData()
            }, completion: nil)

        case .delete:
            self.mainTable.performBatchUpdates({
                mainTable.deleteSections(IndexSet(integer: sectionIndex), with: .automatic)
                mainTable.reloadData()
            }, completion: nil)

        case .move:
            if self.mainTable.numberOfSections > 0 {
                self.mainTable.reloadSections(IndexSet(integer: 0), with: .automatic)
            }
            break
        case .update:
            break
        @unknown default:
                break
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        DispatchQueue.main.async {
            self.mainTable.reloadData()
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("post create edit didChange indexPath type = \(type.rawValue)")
        switch type {
        case .insert:
            DispatchQueue.main.async {
                self.mainTable.reloadData()
            }
            break

        case .delete:
            DispatchQueue.main.async {
                self.mainTable.reloadData()
            }
        case .move:
            self.mainTable.reloadData()
            break
        case .update:
            DispatchQueue.main.async {
                self.mainTable.reloadData()
            }
            break
        @unknown default:
            break
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {

        print("controllerDidChangeContent  fetchedResultsController.fetchedObjects?.count =  \(String(describing: fetchedResultsController.fetchedObjects?.count))")
        DispatchQueue.main.async {
            self.mainTable.reloadData()
        }
    }

}

// MARK: - UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = characters[indexPath.row]
        interactor?.saveSelectedItem(character: user /*characters[indexPath.row]*/)
        router?.routeToDetailedViewController()
    }
}

// MARK: - UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return characters.count //characters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CharacterInformation") as? MainTableViewCell
        cell?.curImageView.kf.indicatorType = .activity
        let user = characters[indexPath.row]
        let urlString =  String(format: user.image) //characters[indexPath.row].image)
        if let url = URL(string:urlString) {
            cell?.curImageView.kf.setImage(with: url)
        }
        cell?.setupLabels(name: user.name /*characters[indexPath.row].name*/, species: characters[indexPath.row].species)
        return cell ?? UITableViewCell()
    }
    
    
}
