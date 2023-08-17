//
//  ImagesListTableViewCell.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import UIKit

final class ImagesListTableViewCell: UITableViewCell,
                                     ViewLoadable {
    
    static var name = Constants.imagesListCell
    static var identifier = Constants.imagesListCell

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    private var viewModel: ImagesListCellViewModelable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension ImagesListTableViewCell {
    
    func configure(with viewModel: ImagesListCellViewModelable, height: CGFloat) {
        self.viewModel = viewModel
        collectionViewHeightConstraint.constant = height + 30 // To accommodate for vertical section inset
    }
    
}

// MARK: - Private Helpers
private extension ImagesListTableViewCell {
    
    func setup() {
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.minimumLineSpacing = 15
        layout?.sectionInset = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        ImageCollectionViewCell.register(for: collectionView)
    }
    
}

// MARK: - UICollectionViewDelegate Methods
extension ImagesListTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.didSelectImage(at: indexPath)
    }
    
}

// MARK: - UICollectionViewDataSource Methods
extension ImagesListTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfImages ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel?.getCellViewModel(at: indexPath) else { return UICollectionViewCell() }
        let imageCell = ImageCollectionViewCell.dequeReusableCell(
            from: collectionView,
            at: indexPath
        )
        imageCell.configure(with: viewModel)
        return imageCell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout Methods
extension ImagesListTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let imageWidth = 0.18 * collectionView.bounds.width
        return CGSize(width: imageWidth, height: imageWidth)
    }
    
}

// MARK: - ImagesListCellPresenter Methods
extension ImagesListTableViewCell: ImagesListCellPresenter {
    
    func updateImage(from currentIndexPath: IndexPath, to newIndexPath: IndexPath) {
        collectionView.performBatchUpdates { [weak self] in
            self?.collectionView.reloadItems(at: [currentIndexPath, newIndexPath])
        }
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        collectionView.reloadItems(at: indexPaths)
    }
    
}
