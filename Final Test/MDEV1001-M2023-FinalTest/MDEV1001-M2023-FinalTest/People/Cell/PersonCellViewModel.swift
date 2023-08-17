//
//  PersonCellViewModel.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import Foundation

protocol PersonCellViewModelable {
    var person: Person { get }
    var birthYear: String { get }
    var state: PersonCellViewModel.YearState { get }
}

final class PersonCellViewModel: PersonCellViewModelable {
    
    /// Determines the background color of person's birth year
    enum YearState {
        case pre1850
        case pre1870
        case pre1900
        case current
        case unknown
    }
    
    let person: Person
    
    private(set) var state: YearState
    
    init(person: Person) {
        self.person = person
        self.state = .unknown
        setYearState()
    }
    
}

// MARK: - Exposed Helpers
extension PersonCellViewModel {
    
    var birthYear: String {
        guard let year = person.birthYear else { return Constants.na }
        return String(year)
    }
    
}

// MARK: - Private Helpers
private extension PersonCellViewModel {
    
    func setYearState() {
        guard let year = person.birthYear else { return }
        if year <= Constants.pre1850Period {
            state = .pre1850
        } else if year <= Constants.pre1870Period {
            state = .pre1870
        } else if year <= Constants.pre1900Period {
            state = .pre1900
        } else {
            state = .current
        }
    }
    
}
