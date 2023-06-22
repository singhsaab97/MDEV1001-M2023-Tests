//
//  AddEditMusicianCellViewModel.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import UIKit

protocol AddEditMusicianCellListener: AnyObject {
    func musicianFieldUpdated(_ field: AddEditMusicianViewModel.Field, with text: String?, formatter: DateFormatter?)
}

protocol AddEditMusicianCellPresenter: AnyObject {
    func updateDobField(with dob: String)
    func dismissDatePicker()
}

protocol AddEditMusicianCellViewModelable: CellViewModelable {
    var field: AddEditMusicianViewModel.Field { get }
    var fieldText: String? { get }
    var minimumAllowedDate: Date { get }
    var maximumAllowedDate: Date { get }
    var birthDate: Date { get }
    var presenter: AddEditMusicianCellPresenter? { get set }
    func didChangeDate(to date: Date)
    func didTypeText(_ text: String?, newText: String) -> Bool
    func doneButtonTapped()
}

final class AddEditMusicianCellViewModel: AddEditMusicianCellViewModelable {

    let mode: AddEditMusicianViewModel.Mode
    let field: AddEditMusicianViewModel.Field
    
    weak var presenter: AddEditMusicianCellPresenter?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    private weak var listener: AddEditMusicianCellListener?
    
    init(mode: AddEditMusicianViewModel.Mode,
         field: AddEditMusicianViewModel.Field,
         listener: AddEditMusicianCellListener?) {
        self.mode = mode
        self.field = field
        self.listener = listener
    }
    
}

// MARK: - Exposed Helpers
extension AddEditMusicianCellViewModel {
    
    var fieldText: String? {
        switch mode {
        case .add:
            return nil
        case let .edit(musician):
            switch field {
            case .name:
                return musician.fullname
            case .genres:
                return musician.genres
            case .instruments:
                return musician.instruments
            case .labels:
                return musician.labels
            case .dob:
                return dateFormatter.string(from: birthDate)
            case .startYear:
                guard let year = LocalMusician.getStartYear(from: musician) else { return nil }
                return String(year)
            case .endYear:
                guard let year = LocalMusician.getEndYear(from: musician) else { return nil }
                return String(year)
            case .spouses:
                return musician.spouses
            case .kids:
                return musician.kids
            case .relatives:
                return musician.relatives
            case .works:
                return musician.works
            }
        }
    }
    
    var minimumAllowedDate: Date {
        return Constants.minimumDate
    }
    
    var maximumAllowedDate: Date {
        return Constants.maximumDate
    }
    
    var birthDate: Date {
        switch mode {
        case .add:
            return Date(timeIntervalSince1970: Constants.defaultDate)
        case let .edit(musician):
            return Date(timeIntervalSince1970: musician.dob)
        }
    }
    
    func didChangeDate(to date: Date) {
        let dob = dateFormatter.string(from: date)
        presenter?.updateDobField(with: dob)
        listener?.musicianFieldUpdated(.dob, with: dob, formatter: dateFormatter)
    }
    
    func didTypeText(_ text: String?, newText: String) -> Bool {
        guard !field.isDateField else { return false }
        guard let text = text else { return false }
        var fieldText: String?
        if newText.isEmpty {
            // Deleting
            fieldText = text.count <= 1 ? nil : String(text.dropLast())
        } else {
            // Typing
            fieldText = text.appending(newText)
        }
        listener?.musicianFieldUpdated(field, with: fieldText, formatter: nil)
        return true
    }
    
    func doneButtonTapped() {
        presenter?.dismissDatePicker()
    }
    
}

// MARK: - AddEditMusicianViewModel.Field Helpers
extension AddEditMusicianViewModel.Field {

    var placeholder: String {
        switch self {
        case .name:
            return Constants.nameFieldPlaceholder
        case .genres:
            return Constants.genresFieldPlaceholder
        case .instruments:
            return Constants.instrumentsFieldPlaceholder
        case .labels:
            return Constants.labelsFieldPlaceholder
        case .dob:
            return Constants.dobFieldPlaceholder
        case .startYear:
            return Constants.startYearFieldPlaceholder
        case .endYear:
            return Constants.endYearFieldPlaceholder
        case .spouses:
            return Constants.spousesFieldPlaceholder
        case .kids:
            return Constants.kidsFieldPlaceholder
        case .relatives:
            return Constants.relativesFieldPlaceholder
        case .works:
            return Constants.worksFieldPlaceholder
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .name, .genres, .instruments, .labels, .spouses, .kids, .relatives, .works:
            return .alphabet
        case .dob:
            return .numbersAndPunctuation
        case .startYear, .endYear:
            return .numberPad
        }
    }
    
    var isDateField: Bool {
        switch self {
        case .name, .genres, .instruments, .labels, .startYear, .endYear, .spouses, .kids, .relatives, .works:
            return false
        case .dob:
            return true
        }
    }
    
}
