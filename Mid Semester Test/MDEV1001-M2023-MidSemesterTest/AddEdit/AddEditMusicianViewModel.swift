//
//  AddEditMusicianViewModel.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import UIKit
import CoreData

protocol AddEditMusicianListener: AnyObject {
    func addNewMusician(_ musician: LocalMusician)
    func updateMusician(_ musician: Musician, with editedMusician: LocalMusician)
    func doesMusicianExist(_ musician: LocalMusician) -> Bool
}

protocol AddEditMusicianPresenter: AnyObject {
    func setNavigationTitle(_ title: String)
    func updateHeaderView(with scrollView: UIScrollView)
    func updateHeaderView(with image: UIImage?)
    func showKeyboard(with height: CGFloat, duration: TimeInterval)
    func hideKeyboard(with duration: TimeInterval)
    func pop(completion: (() -> Void)?)
}

protocol AddEditMusicianViewModelable {
    var sections: [AddEditMusicianViewModel.Section] { get }
    var headerViewImage: UIImage? { get }
    var presenter: AddEditMusicianPresenter? { get set }
    func screenWillAppear()
    func getNumberOfFields(in section: Int) -> Int
    func getCellViewModel(at indexPath: IndexPath) -> CellViewModelable?
    func cancelButtonTapped()
    func doneButtonTapped()
    func didScroll(with scrollView: UIScrollView)
    func keyboardWillShow(with frame: CGRect)
    func keyboardWillHide()
}

final class AddEditMusicianViewModel: AddEditMusicianViewModelable,
                                   Toastable {
    
    enum Mode {
        case add
        case edit(musician: Musician)
    }
    
    enum Section: Hashable {
        case posters
        case fields([Field])
    }
    
    enum Field: CaseIterable {
        case name
        case genres
        case instruments
        case labels
        case dob
        case startYear
        case endYear
        case spouses
        case kids
        case relatives
        case works
    }
    
    let sections: [Section]
    
    private let mode: Mode
    private let posters: [String]
    private var updatedMusician: LocalMusician
    private weak var listener: AddEditMusicianListener?
    
    weak var presenter: AddEditMusicianPresenter?
    
    init(mode: Mode, posters: [String], listener: AddEditMusicianListener?) {
        self.mode = mode
        self.posters = posters
        self.sections = [.posters, .fields(Field.allCases)]
        self.listener = listener
        self.updatedMusician = LocalMusician()
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension AddEditMusicianViewModel {
    
    var headerViewImage: UIImage? {
        switch mode {
        case .add:
            return nil
        case let .edit(musician):
            guard let photo = musician.photo else { return nil }
            return UIImage(named: photo)
        }
    }
    
    func screenWillAppear() {
        presenter?.setNavigationTitle(mode.title)
    }
    
    func cancelButtonTapped() {
        presenter?.pop(completion: nil)
    }
    
    func doneButtonTapped() {
        guard validateMusicianEntry() else { return }
        guard validateActiveYears() else { return }
        switch self.mode {
        case .add:
            guard !(listener?.doesMusicianExist(updatedMusician) ?? false) else {
                showToast(with: Constants.musicianExistsErrorMessage)
                return
            }
            presenter?.pop { [weak self] in
                guard let self = self else { return }
                self.listener?.addNewMusician(self.updatedMusician)
            }
        case let .edit(musician):
            presenter?.pop { [weak self] in
                guard let self = self else { return }
                self.listener?.updateMusician(musician, with: self.updatedMusician)
            }
        }
    }
    
    func getNumberOfFields(in section: Int) -> Int {
        guard let section = sections[safe: section] else { return 0 }
        switch section {
        case .posters:
            return 1
        case let .fields(fields):
            return fields.count
        }
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> CellViewModelable? {
        guard let section = sections[safe: indexPath.section] else { return nil }
        switch section {
        case .posters:
            switch mode {
            case .add:
                return PostersListCellViewModel(posters: posters, currentPoster: nil, listener: self)
            case let .edit(musician):
                return PostersListCellViewModel(posters: posters, currentPoster: musician.photo, listener: self)
            }
        case let .fields(fields):
            guard let field = fields[safe: indexPath.row] else { return nil }
            return AddEditMusicianCellViewModel(mode: mode, field: field, listener: self)
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
private extension AddEditMusicianViewModel {
    
    func setup() {
        // Initialize updatedMusician with the current musician
        switch mode {
        case .add:
            // Empty musician object initialized
            return
        case let .edit(musician):
            updatedMusician = LocalMusician.transform(with: musician)
        }
    }
    
    func validateMusicianEntry() -> Bool {
        // Validate mandatory fields
        let mandatoryFields = Field.allCases.filter { $0.isMandatory }
        for field in mandatoryFields {
            switch field {
            case .name:
                guard updatedMusician.fullName == nil else { continue }
                return showError(for: field)
            case .genres:
                guard updatedMusician.genres == nil else { continue }
                return showError(for: field)
            case .instruments:
                guard updatedMusician.instruments == nil else { continue }
                return showError(for: field)
            case .labels:
                guard updatedMusician.labels == nil else { continue }
                return showError(for: field)
            case .dob:
                guard updatedMusician.dob == nil else { continue }
                return showError(for: field)
            case .startYear:
                guard updatedMusician.startYear == nil else { continue }
                return showError(for: field)
            case .endYear:
                guard updatedMusician.endYear == nil else { continue }
                return showError(for: field)
            case .spouses:
                guard updatedMusician.spouses == nil else { continue }
                return showError(for: field)
            case .kids:
                guard updatedMusician.kids == nil else { continue }
                return showError(for: field)
            case .relatives:
                guard updatedMusician.relatives == nil else { continue }
                return showError(for: field)
            case .works:
                guard updatedMusician.works == nil else { continue }
                return showError(for: field)
            }
        }
        return true
    }
    
    func validateActiveYears() -> Bool {
        // Validate start year and end year
        let startYear = updatedMusician.startYear
        let endYear = updatedMusician.endYear
        if startYear == nil && endYear == nil {
            return true
        } else if startYear != nil && endYear == nil {
            return showError(for: .endYear)
        } else if startYear == nil && endYear != nil {
            return showError(for: .startYear)
        } else if let startYear = startYear,
                  let endYear = endYear {
            guard endYear <= startYear else { return true }
            showToast(with: Constants.activeYearsErrorMessage)
            return false
        }
        return true
    }
    
    func showError(for field: Field) -> Bool {
        showToast(with: field.errorMessage)
        return false
    }
    
}

// MARK: - PostersListCellListener Methods
extension AddEditMusicianViewModel: PostersListCellListener {
    
    func newPosterSelected(_ poster: String) {
        updatedMusician.photo = poster
        switch mode {
        case .add:
            return
        case .edit:
            let image = UIImage(named: poster)
            presenter?.updateHeaderView(with: image)
        }
    }
    
    func oldPosterDeselected() {
        updatedMusician.photo = nil
    }
    
}

// MARK: - AddEditMusicianCellListener Methods
extension AddEditMusicianViewModel: AddEditMusicianCellListener {
    
    func musicianFieldUpdated(_ field: Field, with text: String?, formatter: DateFormatter?) {
        switch field {
        case .name:
            guard let text = text else { return }
            updatedMusician.fullName = text
        case .genres:
            guard let text = text else { return }
            updatedMusician.genres = text
        case .instruments:
            guard let text = text else { return }
            updatedMusician.instruments = text
        case .labels:
            guard let text = text else { return }
            updatedMusician.labels = text
        case .dob:
            guard let text = text else { return }
            updatedMusician.dob = formatter?.date(from: text)?.timeIntervalSince1970
        case .startYear:
            let text = text ?? String()
            updatedMusician.startYear = Int(text)
        case .endYear:
            let text = text ?? String()
            updatedMusician.endYear = Int(text)
        case .spouses:
            guard let text = text else { return }
            updatedMusician.spouses = text
        case .kids:
            guard let text = text else { return }
            updatedMusician.kids = text
        case .relatives:
            guard let text = text else { return }
            updatedMusician.relatives = text
        case .works:
            guard let text = text else { return }
            updatedMusician.works = text
        }
    }
    
}

// MARK: - AddEditMusicianViewModel.Mode Helpers
private extension AddEditMusicianViewModel.Mode {
    
    var title: String {
        switch self {
        case .add:
            return Constants.addMusician
        case .edit:
            return Constants.editMusician
        }
    }
    
}

// MARK: - AddEditMusicianViewModel.Field Helpers
private extension AddEditMusicianViewModel.Field {
    
    var isMandatory: Bool {
        switch self {
        case .name, .genres, .instruments:
            return true
        case .labels, .dob, .startYear, .endYear, .spouses, .kids, .relatives, .works:
            return false
        }
    }
    
    var errorMessage: String {
        return "\(placeholder) \(Constants.fieldErrorMessageSubtext)"
    }
    
}
