import UIKit
import Kingfisher

protocol DetailedDisplayLogic: AnyObject {
    func displayCharacterInformation(viewModel: Detailed.displayDetailedInformation.ViewModel)
}

class DetailedViewController: UIViewController, DetailedDisplayLogic {
    
    var interactor: DetailedBusinessLogic?
    var router: (NSObjectProtocol & DetailedRoutingLogic & DetailedDataPassing)?
    
    // MARK: View setup
    
    // Отображение имени героя
    private lazy var characterName: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    // Отображение вида героя
    private lazy var characterSpecies: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    // Картинка героя
    private lazy var characterImage = UIImageView()
    
    // Все три сущности помещаем в стек один под одним
    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        stack.addArrangedSubview(characterName)
        stack.addArrangedSubview(characterSpecies)
        stack.addArrangedSubview(characterImage)
        
        return stack
    }()
    
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
        let interactor = DetailedInteractor()
        let presenter = DetailedPresenter()
        let router = DetailedRouter()
        viewController.interactor = interactor
        viewController.router = router
        interactor.presenter = presenter
        presenter.viewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
    }
    
    // MARK: View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(stack) // не забываем добавить стек в сабвью
        setupConstraints() // устанавливаем констрейнты
        showDetailedCharacterInformation()
    }
    
    private func setupConstraints() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
        ])
    }
    
    // MARK: Class functions
    
    func showDetailedCharacterInformation() {
        interactor?.fetchDetailedInformation()
    }
    
    func displayCharacterInformation(viewModel: Detailed.displayDetailedInformation.ViewModel) {
        characterImage.kf.indicatorType = .activity
        characterName.text = viewModel.name
        characterSpecies.text = viewModel.species
        if let image = viewModel.image as? UIImage {
            characterImage.image = image
        } else {
            guard let url = URL.init(string: viewModel.imageUrl) else {
                return
            }
            KingfisherManager.shared.retrieveImage(with: url) { result in
                if case .success(let value) = result {
                    DispatchQueue.main.async {
                        let cashedImage = value.image
                        self.characterImage.image = cashedImage
                    }
                } else {
                    print("no image")
                }
            }

        }
    }


}
