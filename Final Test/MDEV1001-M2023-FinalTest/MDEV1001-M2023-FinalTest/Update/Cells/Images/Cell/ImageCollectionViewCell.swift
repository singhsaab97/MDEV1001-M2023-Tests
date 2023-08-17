//
//  ImageCollectionViewCell.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import UIKit
import SDWebImage

final class ImageCollectionViewCell: UICollectionViewCell,
                                      ViewLoadable {
    
    static var name = Constants.imageCell
    static var identifier = Constants.imageCell
    
    @IBOutlet private weak var personImageView: UIImageView!
    @IBOutlet private weak var highlightingView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension ImageCollectionViewCell {
    
    func configure(with viewModel: ImageCellViewModelable) {
        let color = viewModel.isSelected ? UIColor.systemPink : UIColor.clear
        layer.borderColor = color.cgColor
        highlightingView.backgroundColor = color
        personImageView.sd_setImage(with: viewModel.imageUrl)
    }
    
}

// MARK: - Private Helpers
private extension ImageCollectionViewCell {
    
    func setup() {
        layer.cornerRadius = 12
        layer.borderWidth = 3
        highlightingView.alpha = 0.3
    }
    
}
