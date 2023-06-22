//
//  MusicianTableViewCell.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import UIKit

final class MusicianTableViewCell: UITableViewCell,
                                   ViewLoadable {
    
    static var name = Constants.musicianCellName
    static var identifier = Constants.musicianCellIdentifier
        
    @IBOutlet private weak var yearContainerView: UIView!
    @IBOutlet private weak var yearLabel: UILabel!
    @IBOutlet private weak var nameLabel: UILabel!
    @IBOutlet private weak var genresLabel: UILabel!
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var worksLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension MusicianTableViewCell {
    
    func configure(with viewModel: MusicianCellViewModelable) {
        yearContainerView.backgroundColor = viewModel.state.color.withAlphaComponent(0.6)
        yearContainerView.layer.borderColor = viewModel.state.color.cgColor
        yearLabel.text = String(viewModel.birthYear)
        nameLabel.text = viewModel.musician.fullname
        genresLabel.text = viewModel.musician.genres
        if let poster = viewModel.musician.photo {
            posterImageView.image = UIImage(named: poster)
            posterImageView.isHidden = false
        } else {
            posterImageView.isHidden = true
        }
        let works = viewModel.musician.works
        worksLabel.text = works
        worksLabel.isHidden = works == nil || !viewModel.isExpanded
    }
    
}

// MARK: - Private Helpers
private extension MusicianTableViewCell {
    
    func setup() {
        yearContainerView.layer.cornerRadius = 12
        yearContainerView.layer.borderWidth = 3
        posterImageView.layer.cornerRadius = 12
    }
    
}

// MARK: - MusicianCellViewModel.YearState Helpers
private extension MusicianCellViewModel.YearState {
    
    var color: UIColor {
        switch self {
        case .pre1940:
            return .systemRed
        case .pre1950:
            return .systemOrange
        case .pre1960:
            return .systemYellow
        case .pre1970:
            return .systemMint
        case .current:
            return .systemGreen
        case .unknown:
            return .clear
        }
    }
    
}
