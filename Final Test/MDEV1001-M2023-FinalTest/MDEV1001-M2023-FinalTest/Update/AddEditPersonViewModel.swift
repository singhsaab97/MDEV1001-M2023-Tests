//
//  AddEditPersonViewModel.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import UIKit

protocol AddEditPersonListener: AnyObject {
    func addNewPerson(_ person: Person?)
    func updatePerson(_ person: Person, with updatedPerson: Person?)
    func doesPersonExist(_ person: Person?) -> Bool
}

protocol AddEditPersonPresenter: AnyObject {
    func setNavigationTitle(_ title: String)
    func updateHeaderView(with scrollView: UIScrollView)
    func updateHeaderView(with imageUrl: URL?)
    func showKeyboard(with height: CGFloat, duration: TimeInterval)
    func hideKeyboard(with duration: TimeInterval)
    func pop(completion: (() -> Void)?)
}

protocol AddEditPersonViewModelable {
    var sections: [AddEditPersonViewModel.Section] { get }
    var headerViewImageUrl: URL? { get }
    var presenter: AddEditPersonPresenter? { get set }
    func screenWillAppear()
    func getNumberOfFields(in section: Int) -> Int
    func getCellViewModel(at indexPath: IndexPath) -> CellViewModelable?
    func cancelButtonTapped()
    func doneButtonTapped()
    func didScroll(with scrollView: UIScrollView)
    func keyboardWillShow(with frame: CGRect)
    func keyboardWillHide()
}

final class AddEditPersonViewModel: AddEditPersonViewModelable,
                                    Toastable {
    
    enum Mode {
        case add(documentId: String)
        case edit(person: Person)
    }
    
    enum Section: Hashable {
        case images
        case fields([Field])
    }
    
    enum Field: CaseIterable {
        case name
        case occupation
        case nationality
        case birthDate
        case birthPlace
        case achievements
        case bio
    }
    
    let sections: [Section]
    
    private let mode: Mode
    private let images: [URL?]
    private var updatedPerson: Person?
    private weak var listener: AddEditPersonListener?
    
    weak var presenter: AddEditPersonPresenter?
    
    init(mode: Mode, images: [URL?], listener: AddEditPersonListener?) {
        self.mode = mode
        self.images = images
        self.sections = [.images, .fields(Field.allCases)]
        self.listener = listener
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension AddEditPersonViewModel {
    
    var headerViewImageUrl: URL? {
        switch mode {
        case .add:
            return nil
        case let .edit(person):
            return person.imageUrl
        }
    }
    
    func screenWillAppear() {
        presenter?.setNavigationTitle(mode.title)
    }
    
    func cancelButtonTapped() {
        presenter?.pop(completion: nil)
    }
    
    func doneButtonTapped() {
        guard validatePersonEntry() else { return }
        switch mode {
        case .add:
            guard !(listener?.doesPersonExist(updatedPerson) ?? false) else {
                showToast(with: Constants.personExistsErrorMessage)
                return
            }
            presenter?.pop { [weak self] in
                self?.listener?.addNewPerson(self?.updatedPerson)
            }
        case let .edit(person):
            presenter?.pop { [weak self] in
                self?.listener?.updatePerson(person, with: self?.updatedPerson)
            }
        }
    }
    
    func getNumberOfFields(in section: Int) -> Int {
        guard let section = sections[safe: section] else { return 0 }
        switch section {
        case .images:
            return 1
        case let .fields(fields):
            return fields.count
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> CellViewModelable? {
        guard let section = sections[safe: indexPath.section] else { return nil }
        switch section {
        case .images:
            switch mode {
            case .add:
                return ImagesListCellViewModel(
                    images: images,
                    currentImage: nil,
                    listener: self
                )
            case let .edit(person):
                return ImagesListCellViewModel(
                    images: images,
                    currentImage: person.imageUrl,
                    listener: self
                )
            }
        case let .fields(fields):
            guard let field = fields[safe: indexPath.row] else { return nil }
            return AddEditPersonCellViewModel(mode: mode, field: field, listener: self)
        }
    }
    
    func didScroll(with scrollView: UIScrollView) {
        presenter?.updateHeaderView(with: scrollView)
    }
    
    func keyboardWillShow(with frame: CGRect) {
        presenter?.showKeyboard(with: frame.height, duration: Constants.animationDuration)
    }
    
    func keyboardWillHide() {
        presenter?.hideKeyboard(with: Constants.animationDuration)
    }
    
}

// MARK: - Private Helpers
private extension AddEditPersonViewModel {
    
    func setup() {
        switch mode {
        case let .add(documentId):
            updatedPerson = Person.createObject(with: documentId)
        case let .edit(person):
            updatedPerson = person
        }
    }
    
    func validatePersonEntry() -> Bool {
        guard let person = updatedPerson else { return false }
        // Validate mandatory fields
        let mandatoryFields = Field.allCases.filter { $0.isMandatory }
        for field in mandatoryFields {
            switch field {
            case .name:
                guard person.name.isEmpty else { continue }
                return showError(for: field)
            case .occupation:
                guard person.occupation.isEmpty else { continue }
                return showError(for: field)
            case .nationality:
                guard person.nationality.isEmpty else { continue }
                return showError(for: field)
            case .birthDate:
                guard person.birthDate == nil else { continue }
                return showError(for: field)
            case .birthPlace:
                guard person.birthPlace.isEmpty else { continue }
                return showError(for: field)
            case .achievements:
                guard person.achievements.isEmpty else { continue }
                return showError(for: field)
            case .bio:
                guard person.bio == nil else { continue }
                return showError(for: field)
            }
        }
        return true
    }
    
    func showError(for field: Field) -> Bool {
        showToast(with: field.errorMessage)
        return false
    }
    
}

// MARK: - ImagesListCellListener Methods
extension AddEditPersonViewModel: ImagesListCellListener {
    
    func newImageSelected(_ imageUrl: URL?) {
        updatedPerson?.image = imageUrl?.absoluteString
        switch mode {
        case .add:
            return
        case .edit:
            presenter?.updateHeaderView(with: imageUrl)
        }
    }
    
    func oldImageDeselected() {
        updatedPerson?.image = nil
    }
    
}

// MARK: - AddEditPersonCellListener Methods
extension AddEditPersonViewModel: AddEditPersonCellListener {
    
    func personFieldUpdated(_ field: Field, with text: String?, formatter: DateFormatter?) {
        guard let text = text else { return }
        switch field {
        case .name:
            updatedPerson?.name = text
        case .occupation:
            updatedPerson?.occupation = text
        case .nationality:
            updatedPerson?.nationality = text
        case .birthDate:
            updatedPerson?.birthDate = formatter?.date(from: text)?.timeIntervalSince1970
        case .birthPlace:
            updatedPerson?.birthPlace = text
        case .achievements:
            updatedPerson?.achievements = text.toArray
        case .bio:
            updatedPerson?.bio = text
        }
    }
    
}

// MARK: - AddEditPersonViewModel.Mode Helpers
private extension AddEditPersonViewModel.Mode {
    
    var title: String {
        switch self {
        case .add:
            return Constants.addPerson
        case .edit:
            return Constants.editPerson
        }
    }
    
}

// MARK: - AddEditPersonViewModel.Field Helpers
private extension AddEditPersonViewModel.Field {
    
    var isMandatory: Bool {
        switch self {
        case .name, .occupation, .nationality:
            return true
        case .birthDate, .birthPlace, .achievements, .bio:
            return false
        }
    }
    
    var errorMessage: String {
        return "\(placeholder) \(Constants.fieldErrorMessageSubtext)"
    }
    
}
