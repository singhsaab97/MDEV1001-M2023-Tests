//
//  AddEditPersonCellViewModel.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import UIKit

protocol AddEditPersonCellListener: AnyObject {
    func personFieldUpdated(_ field: AddEditPersonViewModel.Field, with text: String?, formatter: DateFormatter?)
}

protocol AddEditPersonCellPresenter: AnyObject {
    func updateBirthDateField(with birthDate: String)
    func dismissDatePicker()
}

protocol AddEditPersonCellViewModelable: CellViewModelable {
    var field: AddEditPersonViewModel.Field { get }
    var fieldText: String? { get }
    var minimumAllowedDate: Date { get }
    var birthDate: Date? { get }
    var presenter: AddEditPersonCellPresenter? { get set }
    func didChangeDate(to date: Date)
    func didTypeText(_ text: String?, newText: String) -> Bool
    func doneButtonTapped()
}

final class AddEditPersonCellViewModel: AddEditPersonCellViewModelable {

    let mode: AddEditPersonViewModel.Mode
    let field: AddEditPersonViewModel.Field
    
    weak var presenter: AddEditPersonCellPresenter?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    private weak var listener: AddEditPersonCellListener?
    
    init(mode: AddEditPersonViewModel.Mode,
         field: AddEditPersonViewModel.Field,
         listener: AddEditPersonCellListener?) {
        self.mode = mode
        self.field = field
        self.listener = listener
    }
    
}

// MARK: - Exposed Helpers
extension AddEditPersonCellViewModel {
    
    var fieldText: String? {
        switch mode {
        case .add:
            return nil
        case let .edit(person):
            switch field {
            case .name:
                return person.name
            case .occupation:
                return person.occupation
            case .nationality:
                return person.nationality
            case .birthDate:
                guard let date = birthDate else { return nil }
                return dateFormatter.string(from: date)
            case .birthPlace:
                return person.birthPlace
            case .achievements:
                return person.achievements.toCsv
            case .bio:
                return person.bio
            }
        }
    }
    
    var minimumAllowedDate: Date {
        return Constants.minimumDate
    }
    
    var birthDate: Date? {
        switch mode {
        case .add:
            return nil
        case let .edit(person):
            guard let date = person.birthDate else { return nil }
            return Date(timeIntervalSince1970: date)
        }
    }
    
    func didChangeDate(to date: Date) {
        let birthDate = dateFormatter.string(from: date)
        presenter?.updateBirthDateField(with: birthDate)
        listener?.personFieldUpdated(.birthDate, with: birthDate, formatter: dateFormatter)
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
        listener?.personFieldUpdated(field, with: fieldText, formatter: nil)
        return true
    }
    
    func doneButtonTapped() {
        presenter?.dismissDatePicker()
    }
    
}

// MARK: - AddEditPersonViewModel.Field Helpers
extension AddEditPersonViewModel.Field {

    var placeholder: String {
        switch self {
        case .name:
            return Constants.personNameFieldPlaceholder
        case .occupation:
            return Constants.personOccupationFieldPlaceholder
        case .nationality:
            return Constants.personNationalityFieldPlaceholder
        case .birthDate:
            return Constants.personBirthDateFieldPlaceholder
        case .birthPlace:
            return Constants.personBirthPlaceFieldPlaceholder
        case .achievements:
            return Constants.personAchievementsFieldPlaceholder
        case .bio:
            return Constants.personBioFieldPlaceholder
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        case .name, .occupation, .nationality, .birthPlace, .achievements, .bio:
            return .alphabet
        case .birthDate:
            return .default
        }
    }
    
    var isDateField: Bool {
        switch self {
        case .name, .occupation, .nationality, .birthPlace, .achievements, .bio:
            return false
        case .birthDate:
            return true
        }
    }
    
}
