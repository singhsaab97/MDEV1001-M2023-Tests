//
//  PosterCollectionViewCell.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import UIKit

final class PosterCollectionViewCell: UICollectionViewCell,
                                      ViewLoadable {
    
    static var name = Constants.posterCellName
    static var identifier = Constants.posterCellIdentifier
    
    @IBOutlet private weak var posterImageView: UIImageView!
    @IBOutlet private weak var highlightingView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension PosterCollectionViewCell {
    
    func configure(with viewModel: PosterCellViewModelable) {
        let color = viewModel.isSelected ? UIColor.systemBlue : UIColor.clear
        layer.borderColor = color.cgColor
        highlightingView.backgroundColor = color
        posterImageView.image = UIImage(named: viewModel.poster)
    }
    
}

// MARK: - Private Helpers
private extension PosterCollectionViewCell {
    
    func setup() {
        layer.cornerRadius = 12
        layer.borderWidth = 3
        highlightingView.alpha = 0.3
    }
    
}
