//
//  Person.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import Foundation

struct Person: Codable, Equatable {
    var documentId: String?
    var name: String
    var occupation: String
    var nationality: String
    var birthDate: TimeInterval?
    var birthPlace: String
    var bio: String?
    var achievements: [String]
    var image: String?
    var isExpanded: Bool = false
    
    var birthYear: Int? {
        guard let birthDate = birthDate else { return nil }
        let date = Date(timeIntervalSince1970: birthDate)
        return Calendar.current.component(.year, from: date)
    }
    
    var imageUrl: URL? {
        guard let image = image else { return nil }
        return URL(string: image)
    }
    
    private enum CodingKeys: String, CodingKey {
        case name
        case occupation
        case nationality
        case birthDate = "birth_date"
        case birthPlace = "birth_place"
        case bio
        case achievements
        case image
    }
    
}

// MARK: - Exposed Helpers
extension Person {
    
    static func createObject(with documentId: String) -> Person {
        return Person(
            documentId: documentId,
            name: String(),
            occupation: String(),
            nationality: String(),
            birthDate: nil,
            birthPlace: String(),
            bio: String(),
            achievements: []
        )
    }
    
}
