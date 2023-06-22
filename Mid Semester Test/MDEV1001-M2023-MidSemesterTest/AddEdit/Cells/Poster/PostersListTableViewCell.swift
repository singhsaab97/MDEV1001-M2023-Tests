//
//  PostersListTableViewCell.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import UIKit

final class PostersListTableViewCell: UITableViewCell,
                                      ViewLoadable {
    
    static var name = Constants.postersListCellName
    static var identifier = Constants.postersListCellIdentifier
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    private var viewModel: PostersListCellViewModelable?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

}

// MARK: - Exposed Helpers
extension PostersListTableViewCell {
    
    func configure(with viewModel: PostersListCellViewModelable, height: CGFloat) {
        self.viewModel = viewModel
        self.viewModel?.presenter = self
        collectionViewHeightConstraint.constant = height + 30 // To accommodate for vertical section inset
    }
    
}

// MARK: - Private Helpers
private extension PostersListTableViewCell {
    
    func setup() {
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        layout?.minimumLineSpacing = 15
        layout?.sectionInset = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        PosterCollectionViewCell.register(for: collectionView)
    }
    
}

// MARK: - UICollectionViewDelegate Methods
extension PostersListTableViewCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel?.didSelectPoster(at: indexPath)
    }
    
}

// MARK: - UICollectionViewDataSource Methods
extension PostersListTableViewCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.numberOfPosters ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let viewModel = viewModel?.getCellViewModel(at: indexPath) else { return UICollectionViewCell() }
        let posterCell = PosterCollectionViewCell.dequeReusableCell(from: collectionView, at: indexPath)
        posterCell.configure(with: viewModel)
        return posterCell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout Methods
extension PostersListTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let posterWidth = 0.18 * collectionView.bounds.width
        return CGSize(width: posterWidth, height: posterWidth)
    }
    
}

// MARK: - PostersListCellPresenter Methods
extension PostersListTableViewCell: PostersListCellPresenter {
    
    func updatePoster(from currentIndexPath: IndexPath, to newIndexPath: IndexPath) {
        collectionView.performBatchUpdates { [weak self] in
            self?.collectionView.reloadItems(at: [currentIndexPath, newIndexPath])
        }
    }
    
    func reloadItems(at indexPaths: [IndexPath]) {
        collectionView.reloadItems(at: indexPaths)
    }
    
}
