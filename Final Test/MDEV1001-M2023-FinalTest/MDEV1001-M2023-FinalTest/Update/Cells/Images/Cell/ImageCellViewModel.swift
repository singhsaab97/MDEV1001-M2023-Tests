//
//  ImageCellViewModel.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import Foundation

protocol ImageCellViewModelable {
    var imageUrl: URL? { get }
    var isSelected: Bool { get }
}

final class ImageCellViewModel: ImageCellViewModelable {
    
    let imageUrl: URL?
    let isSelected: Bool
    
    init(imageUrl: URL?, isSelected: Bool) {
        self.imageUrl = imageUrl
        self.isSelected = isSelected
    }
    
}
