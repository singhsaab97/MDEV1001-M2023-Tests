//
//  PosterCellViewModel.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import Foundation

protocol PosterCellViewModelable {
    var poster: String { get }
    var isSelected: Bool { get }
}

final class PosterCellViewModel: PosterCellViewModelable {
    
    let poster: String
    let isSelected: Bool
    
    init(poster: String, isSelected: Bool) {
        self.poster = poster
        self.isSelected = isSelected
    }
    
}
