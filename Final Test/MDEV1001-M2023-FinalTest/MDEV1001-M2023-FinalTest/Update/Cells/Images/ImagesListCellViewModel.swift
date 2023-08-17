//
//  ImagesListCellViewModel.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import Foundation

protocol ImagesListCellListener: AnyObject {
    func newImageSelected(_ imageUrl: URL?)
    func oldImageDeselected()
}

protocol ImagesListCellPresenter: AnyObject {
    func updateImage(from currentIndexPath: IndexPath, to newIndexPath: IndexPath)
    func reloadItems(at indexPaths: [IndexPath])
}

protocol ImagesListCellViewModelable: CellViewModelable {
    var numberOfImages: Int { get }
    var presenter: ImagesListCellPresenter? { get set }
    func getCellViewModel(at indexPath: IndexPath) -> ImageCellViewModelable?
    func didSelectImage(at indexPath: IndexPath)
}

final class ImagesListCellViewModel: ImagesListCellViewModelable {
    
    private let images: [URL?]
    private var isSelectedDict: [URL?: Bool]
    private weak var listener: ImagesListCellListener?
    
    weak var presenter: ImagesListCellPresenter?
    
    init(images: [URL?], currentImage: URL?, listener: ImagesListCellListener?) {
        self.images = images
        self.isSelectedDict = [:]
        self.listener = listener
        setup(with: currentImage)
    }
    
}

// MARK: - Exposed Helpers
extension ImagesListCellViewModel {
    
    var numberOfImages: Int {
        return images.count
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> ImageCellViewModelable? {
        guard let imageUrl = images[safe: indexPath.item],
              let isSelected = isSelectedDict[imageUrl] else { return nil }
        return ImageCellViewModel(imageUrl: imageUrl, isSelected: isSelected)
    }
    
    func didSelectImage(at indexPath: IndexPath) {
        guard let newImage = images[safe: indexPath.item] else { return }
        if let currentImage = isSelectedDict.first(where: { $0.value })?.key,
           let index = images.firstIndex(of: currentImage) {
            // Image is available for the musician
            isSelectedDict[currentImage] = false
            let currentIndexPath = IndexPath(item: index, section: 0)
            guard newImage != currentImage else {
                // Deselect the assigned image
                presenter?.reloadItems(at: [currentIndexPath])
                listener?.oldImageDeselected()
                return
            }
            isSelectedDict[newImage] = true
            presenter?.updateImage(from: currentIndexPath, to: indexPath)
        } else {
            // Image is unavailable for the musician
            isSelectedDict[newImage] = true
            presenter?.reloadItems(at: [indexPath])
        }
        listener?.newImageSelected(newImage)
    }
    
}

// MARK: - Private Helpers
private extension ImagesListCellViewModel {
    
    func setup(with currentImage: URL?) {
        // Initialize isSelectedDict based on currently selected image
        images.forEach { url in
            isSelectedDict[url] = url == currentImage
        }
    }
    
}
