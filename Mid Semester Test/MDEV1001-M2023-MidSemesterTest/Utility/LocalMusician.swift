//
//  LocalMusician.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import Foundation
import CoreData

struct LocalMusician {
    var fullName: String?
    var genres: String?
    var instruments: String?
    var labels: String?
    var dob: Double?
    var startYear: Int?
    var endYear: Int?
    var spouses: String?
    var kids: String?
    var relatives: String?
    var works: String?
    var photo: String?
}

// MARK: - Exposed Helpers
extension LocalMusician {
    
    var activeYears: String? {
        guard let startYear = startYear,
              let endYear = endYear else { return nil }
        return "\(startYear)-\(endYear)"
    }
    
    func isEqual(to musician: Musician) -> Bool {
        return fullName == musician.fullname && dob == musician.dob
    }

    static func transform(with musician: Musician) -> LocalMusician {
        return LocalMusician(
            fullName: musician.fullname,
            genres: musician.genres,
            instruments: musician.instruments,
            labels: musician.labels,
            dob: musician.dob,
            startYear: LocalMusician.getStartYear(from: musician),
            endYear: LocalMusician.getEndYear(from: musician),
            spouses: musician.spouses,
            kids: musician.kids,
            relatives: musician.relatives,
            works: musician.works,
            photo: musician.photo
        )
    }
    
    static func getStartYear(from musician: Musician) -> Int? {
        return Int(musician.activeyears?.prefix(4) ?? Substring())
    }
    
    static func getEndYear(from musician: Musician) -> Int? {
        return Int(musician.activeyears?.suffix(4) ?? Substring())
    }
    
}
