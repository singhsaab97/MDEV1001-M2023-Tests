//
//  UserDefaults+Extensions.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import UIKit

extension UserDefaults {
    
    static let appSuite = UserDefaults(suiteName: Constants.suiteName) ?? UserDefaults()
    static let userInterfaceStyleKey = "userInterfaceStyleKey"
    static let availableImagesKey = "availableImagesKey"
    
    static var userInterfaceStyle: UIUserInterfaceStyle {
        let value = appSuite.integer(forKey: userInterfaceStyleKey)
        return UIUserInterfaceStyle(rawValue: value) ?? .unspecified
    }
    
    static var availableImages: [String] {
        return appSuite.array(forKey: availableImagesKey) as? [String] ?? []
    }
    
}
