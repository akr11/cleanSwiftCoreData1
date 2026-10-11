
import UIKit

class MainTableViewCell: UITableViewCell {
    
    // MARK: View setup

    public lazy var curImageView: UIImageView = {
        //        let imageView = UIImageView()
        //        return imageView
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "person.circle") // Placeholder image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 25 // Make it circular if size is 50x50
        return imageView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Unknown"
        label.textColor = UIColor.black
        return label
    }()
    
    private lazy var speciesLabel: UILabel = {
        let label = UILabel()
        label.text = "Unknown"
        label.textColor = UIColor.gray
        return label
    }()
    
    // MARK: Initialization

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Setup functions
    
    private func setupSubviews() {
        contentView.addSubview(curImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(speciesLabel)
    }
    
    private func setupConstraints() {
        curImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        speciesLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            curImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            curImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            curImageView.widthAnchor.constraint(equalToConstant: 50),
            curImageView.heightAnchor.constraint(equalToConstant: 50),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: curImageView.bottomAnchor, constant: 10),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            nameLabel.leadingAnchor.constraint(equalTo: curImageView.trailingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            speciesLabel.leadingAnchor.constraint(equalTo: curImageView.trailingAnchor, constant: 20),
            speciesLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            speciesLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 10),
            contentView.bottomAnchor.constraint(greaterThanOrEqualTo: speciesLabel.bottomAnchor, constant: 10)
        ])
    }
    
    func setupLabels(name: String, species: String) {
        nameLabel.text = name
        speciesLabel.text = species
    }

}
