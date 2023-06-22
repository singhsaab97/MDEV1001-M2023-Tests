//
//  UserDefaults+Extensions.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    static let appSuite = UserDefaults(suiteName: Constants.suiteName) ?? UserDefaults()
    static let areMusiciansSavedKey = "isDataSavedKey"
    static let availablePostersKey = "availablePostersKey"
    static let sortOptionKey = "sortOptionKey"
    
    static var areMusiciansSaved: Bool {
        return appSuite.bool(forKey: areMusiciansSavedKey)
    }
    
    static var availablePosters: [String] {
        return appSuite.array(forKey: availablePostersKey) as? [String] ?? []
    }
    
    static var sortOption: MusiciansViewModel.SortOption {
        let value = appSuite.integer(forKey: sortOptionKey)
        return MusiciansViewModel.SortOption(rawValue: value) ?? .alphabetically
    }
    
}
