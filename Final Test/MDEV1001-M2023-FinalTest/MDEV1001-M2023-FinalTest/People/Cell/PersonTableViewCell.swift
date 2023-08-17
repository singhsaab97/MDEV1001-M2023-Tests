//
//  PersonTableViewCell.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import UIKit
import SDWebImage

final class PersonTableViewCell: UITableViewCell,
                           ViewLoadable {
    
    static var name = Constants.personCell
    static var identifier = Constants.personCell

    @IBOutlet private weak var yearContainerView: UIView!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var occupationLabel: UILabel!
    @IBOutlet private weak var personImageView: UIImageView!
    @IBOutlet private weak var bioLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension PersonTableViewCell {
    
    func configure(with viewModel: PersonCellViewModelable) {
        yearContainerView.backgroundColor = viewModel.state.color.withAlphaComponent(0.6)
        yearContainerView.layer.borderColor = viewModel.state.color.cgColor
        yearLabel.text = viewModel.birthYear
        nameLabel.text = viewModel.person.name
        occupationLabel.text = viewModel.person.occupation
        let imageUrl = viewModel.person.imageUrl
        personImageView.sd_setImage(with: imageUrl)
        personImageView.isHidden = imageUrl == nil
        let bio = viewModel.person.bio
        bioLabel.text = bio
        bioLabel.isHidden = bio == nil || !viewModel.person.isExpanded
    }
    
}

// MARK: - Private Helpers
private extension PersonTableViewCell {
    
    func setup() {
        yearContainerView.layer.cornerRadius = 12
        yearContainerView.layer.borderWidth = 3
        personImageView.layer.cornerRadius = 12
    }
    
}

// MARK: - PersonCellViewModel.YearState Helpers
private extension PersonCellViewModel.YearState {
    
    var color: UIColor {
        switch self {
        case .pre1850:
            return .systemRed
        case .pre1870:
            return .systemOrange
        case .pre1900:
            return .systemYellow
        case .current:
            return .systemGreen
        case .unknown:
            return .systemGray
        }
    }
    
}
