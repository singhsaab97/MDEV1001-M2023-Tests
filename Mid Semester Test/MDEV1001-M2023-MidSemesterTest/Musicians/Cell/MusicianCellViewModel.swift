//
//  MusicianCellViewModel.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import Foundation
import CoreData

protocol MusicianCellViewModelable {
    var musician: Musician { get }
    var birthYear: Int { get }
    var isExpanded: Bool { get }
    var state: MusicianCellViewModel.YearState { get }
}

final class MusicianCellViewModel: MusicianCellViewModelable {
    
    /// Determines the background color of musician's birth year
    enum YearState {
        case pre1940
        case pre1950
        case pre1960
        case pre1970
        case current
        case unknown
    }
    
    let musician: Musician
    let isExpanded: Bool
    
    private(set) var state: YearState
    
    init(musician: Musician, isExpanded: Bool) {
        self.musician = musician
        self.isExpanded = isExpanded
        self.state = .unknown
        setYearState()
    }
    
}

// MARK: - Exposed Helpers
extension MusicianCellViewModel {
    
    var birthYear: Int {
        let date = Date(timeIntervalSince1970: musician.dob)
        return Calendar.current.component(.year, from: date)
    }
    
}

// MARK: - Private Helpers
private extension MusicianCellViewModel {
    
    func setYearState() {
        let year = birthYear
        if year <= Constants.pre1940Period {
            state = .pre1940
        } else if year <= Constants.pre1950Period {
            state = .pre1950
        } else if year <= Constants.pre1960Period {
            state = .pre1960
        } else if year <= Constants.pre1970Period {
            state = .pre1970
        } else {
            state = .current
        }
    }
    
}
