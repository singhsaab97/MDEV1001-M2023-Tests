//
//  String+Extensions.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import Foundation

extension String {
    
    /// Assumes that the values are separated by `,`
    var toArray: [String] {
        return components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }
    
    var toUrl: URL? {
        return URL(string: self)
    }
    
}
