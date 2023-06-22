//
//  Constants.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import UIKit

struct Constants {

    static let pre1940Period: Int = 1940
    static let pre1950Period: Int = 1950
    static let pre1960Period: Int = 1960
    static let pre1970Period: Int = 1970
    static let currentPeriod: Int = 1980
    static let defaultDate = Date().timeIntervalSince1970
    static let minimumDate = Date(timeIntervalSince1970: -2208979324)
    static let maximumDate = Date(timeIntervalSince1970: 1687401476)
    static let headerViewHeight: CGFloat = 250
    static let placeholderFont = UIFont(name: "Helvetica Neue", size: 16)!
    static let animationDuration: TimeInterval = 0.3
    static let toastDisplayDuration: TimeInterval = 3
    
    static let suiteName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    static let dbModelName = "Musician"
    static let jsonFileName = "Musicians"
    static let storyboardName = "Main"
    static let musiciansViewControllerIdentifier = String(describing: MusiciansViewController.self)
    static let addEditMusicianViewControllerIdentifier = String(describing: AddEditMusicianViewController.self)
    static let musicianCellName = String(describing: MusicianTableViewCell.self)
    static let musicianCellIdentifier = String(describing: MusicianTableViewCell.self)
    static let addEditMusicianCellName = String(describing: AddEditMusicianTableViewCell.self)
    static let addEditMusicianCellIdentifier = String(describing: AddEditMusicianTableViewCell.self)
    static let postersListCellName = String(describing: PostersListTableViewCell.self)
    static let postersListCellIdentifier = String(describing: PostersListTableViewCell.self)
    static let posterCellName = String(describing: PosterCollectionViewCell.self)
    static let posterCellIdentifier = String(describing: PosterCollectionViewCell.self)
    static let toastViewName = String(describing: ToastView.self)
    static let toastViewIdentifier = String(describing: ToastView.self)
    
    static let sort = "Sort"
    static let edit = "Edit"
    static let editMusician = "Edit Musician"
    static let addMusician = "Add Musician"
    static let delete = "Delete"
    static let alphabeticallyOption = "Alphabetically"
    static let youngestOption = "Youngest"
    static let oldestOption = "Oldest"
    static let mostActiveYearsOption = "Most active years"
    static let leastActiveYearsOption = "Least active years"
    static let musiciansViewControllerTitle = "Favourite Musicians"
    static let nameFieldPlaceholder = "Name"
    static let genresFieldPlaceholder = "Genres"
    static let instrumentsFieldPlaceholder = "Instruments"
    static let labelsFieldPlaceholder = "Labels"
    static let dobFieldPlaceholder = "DOB"
    static let startYearFieldPlaceholder = "Debut year"
    static let endYearFieldPlaceholder = "Retirement year"
    static let spousesFieldPlaceholder = "Spouses"
    static let kidsFieldPlaceholder = "Children"
    static let relativesFieldPlaceholder = "Relatives"
    static let worksFieldPlaceholder = "Notable works"
    static let fieldErrorMessageSubtext = "is required"
    static let cannotDeleteDuringSearchMessage = "Deletion cannot be performed while searching"
    static let cannotEditDuringSearchMessage = "Editing cannot be performed while searching"
    static let musicianExistsErrorMessage = "This musician already exists in the database"
    static let deleteAlertMessage = "This action will delete it from the database permanently."
    static let deleteAllAlertTitle = "Delete all musicians?"
    static let deleteAllAlertMessage = "This action will delete all the musicians from the database permanently."
    static let deleteAlertDeleteTitle = "Delete"
    static let deleteAlertCancelTitle = "Cancel"
    
}
