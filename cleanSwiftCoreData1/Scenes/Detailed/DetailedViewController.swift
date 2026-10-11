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
    private lazy var characterImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
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
        let safeArea = view.safeAreaLayoutGuide
        stack.translatesAutoresizingMaskIntoConstraints = false
        characterImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            characterImage.heightAnchor.constraint(equalToConstant: 280)
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
        if let image = viewModel.image {
            characterImage.image = image
        } else if let url = URL(string: viewModel.imageUrl) {
            characterImage.kf.setImage(with: url)
        }
    }


}
