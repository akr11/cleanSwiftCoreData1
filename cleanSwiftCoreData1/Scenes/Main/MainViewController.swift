import UIKit
import Kingfisher

protocol MainDisplayLogic: AnyObject {
    func addCharactersToVariable(viewModel: Main.displayCartoonCharacters.ViewModel)
    func displayFetchFailed()
}

class MainViewController: UIViewController, MainDisplayLogic {

    // MARK: VIP variables
    
    var interactor: MainBusinessLogic?
    var router: (NSObjectProtocol & MainRoutingLogic & MainDataPassing)?
    
    // MARK: Class variables

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

    func displayFetchFailed() {
        refreshControl.endRefreshing()
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
        if let url = URL(string: user.image) {
            cell?.curImageView.kf.setImage(with: url)
        }
        cell?.setupLabels(name: user.name /*characters[indexPath.row].name*/, species: characters[indexPath.row].species)
        return cell ?? UITableViewCell()
    }
    
    
}
