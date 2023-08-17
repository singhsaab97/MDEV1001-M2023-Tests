//
//  PeopleViewModel.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import UIKit

protocol ThemeListener: AnyObject {
    func changeTheme(to style: UIUserInterfaceStyle)
}

protocol PeopleListener: ThemeListener {
    func userLoggingOut()
}

protocol PeoplePresenter: AnyObject {
    func setNavigationTitle(_ title: String)
    func setThemeButton(with image: UIImage?)
    func startLoading()
    func stopLoading()
    func reloadSections(_ indexSet: IndexSet)
    func reloadRows(at indexPaths: [IndexPath])
    func insertRows(at indexPaths: [IndexPath])
    func deleteRows(at indexPaths: [IndexPath])
    func scroll(to indexPath: IndexPath)
    func present(_ viewController: UIViewController)
    func push(_ viewController: UIViewController)
    func dismiss()
}

protocol PeopleViewModelable {
    var logoutButtonImage: UIImage? { get }
    var userInterfaceStyle: UIUserInterfaceStyle { get }
    var numberOfPersons: Int { get }
    var presenter: PeoplePresenter? { get set }
    func screenWillAppear()
    func screenLoaded()
    func logoutButtonTapped()
    func themeButtonTapped()
    func addButtonTapped()
    func getCellViewModel(at indexPath: IndexPath) -> PersonCellViewModelable?
    func didSelectPerson(at indexPath: IndexPath)
    func leadingSwipedPerson(at indexPath: IndexPath) -> UIContextualAction
    func trailingSwipedPerson(at indexPath: IndexPath) -> UISwipeActionsConfiguration
}

final class PeopleViewModel: PeopleViewModelable,
                             Toastable {
    
    private var people: [Person]
    private weak var listener: PeopleListener?
       
    weak var presenter: PeoplePresenter?
    
    init(listener: PeopleListener?) {
        self.people = []
        self.listener = listener
    }
    
}

// MARK: - Exposed Helpers
extension PeopleViewModel {
    
    var logoutButtonImage: UIImage? {
        return UIImage(systemName: "arrowshape.turn.up.backward")
    }
    
    var userInterfaceStyle: UIUserInterfaceStyle {
        return UserDefaults.userInterfaceStyle
    }
    
    var numberOfPersons: Int {
        return people.count
    }
    
    func screenWillAppear() {
        presenter?.setNavigationTitle(Constants.peopleViewControllerTitle)
    }
    
    func screenLoaded() {
        fetchPeople()
    }
    
    func logoutButtonTapped() {
        prepareLogoutAlert { [weak self] in
            self?.listener?.userLoggingOut()
            self?.presenter?.dismiss()
        }
    }
    
    func themeButtonTapped() {
        let newStyle = userInterfaceStyle.overridingStyle
        presenter?.setThemeButton(with: newStyle.image)
        listener?.changeTheme(to: newStyle)
        UserDefaults.appSuite.set(
            newStyle.rawValue,
            forKey: UserDefaults.userInterfaceStyleKey
        )
    }
    
    func addButtonTapped() {
        showAddEditViewController(for: .add(documentId: UUID().uuidString))
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> PersonCellViewModelable? {
        guard let person = people[safe: indexPath.row] else { return nil }
        return PersonCellViewModel(person: person)
    }
    
    func didSelectPerson(at indexPath: IndexPath) {
        guard var person = people[safe: indexPath.row] else { return }
        person.isExpanded = !person.isExpanded
        people[indexPath.row] = person
        presenter?.reloadRows(at: [indexPath])
    }
    
    func leadingSwipedPerson(at indexPath: IndexPath) -> UIContextualAction {
        // Edit action
        return UIContextualAction(style: .normal, title: Constants.edit) { [weak self] (_, _, _) in
            self?.editPerson(at: indexPath)
        }
    }
    
    func trailingSwipedPerson(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        // Delete action
        let action = UIContextualAction(style: .destructive, title: Constants.delete) { [weak self] (_, _, _) in
            self?.deletePerson(at: indexPath)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}

// MARK: - Private Helpers
private extension PeopleViewModel {
    
    func fetchPeople() {
        presenter?.startLoading()
        PeopleDataHandler.instance.fetchPeople { [weak self] (people, error) in
            self?.presenter?.stopLoading()
            guard let error = error else {
                self?.people = people
                // Save image urls
                let availableImages = UserDefaults.appSuite.array(forKey: UserDefaults.availableImagesKey)
                if availableImages == nil {
                    let images = people.map { $0.image }.removedDuplicates
                    UserDefaults.appSuite.set(
                        images,
                        forKey: UserDefaults.availableImagesKey
                    )
                }
                self?.presenter?.reloadSections(IndexSet(integer: 0))
                return
            }
            self?.showToast(with: error)
        }
    }
    
    func editPerson(at indexPath: IndexPath) {
        guard let person = people[safe: indexPath.row] else { return }
        showAddEditViewController(for: .edit(person: person))
    }
    
    func deletePerson(at indexPath: IndexPath) {
        // Delete Person
        guard let person = people[safe: indexPath.row],
              let documentId = person.documentId,
              let index = people.firstIndex(of: person) else { return }
        let alertTitle = "\(Constants.delete) \"\(person.name)\"?"
        prepareDeleteAlert(with: alertTitle) { [weak self] in
            PeopleDataHandler.instance.deletePerson(at: documentId) { [weak self] error in
                let indexPath = IndexPath(row: index, section: 0)
                self?.people.remove(at: index)
                self?.presenter?.deleteRows(at: [indexPath])
            }
        }
    }
    
    func showAddEditViewController(for mode: AddEditPersonViewModel.Mode) {
        let images = UserDefaults.availableImages.map { $0.toUrl }
        let viewModel = AddEditPersonViewModel(
            mode: mode,
            images: images,
            listener: self
        )
        let viewController = AddEditPersonViewController.loadFromStoryboard()
        viewController.viewModel = viewModel
        viewModel.presenter = viewController
        presenter?.push(viewController)
    }
    
    func scroll(to indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            self?.presenter?.scroll(to: indexPath)
        }
    }
    
    func prepareDeleteAlert(with title: String, action: @escaping () -> Void) {
        let alertController = UIAlertController(
            title: title,
            message: Constants.deleteAlertMessage,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: Constants.alertCancelTitle,
            style: .default
        )
        let deleteAction = UIAlertAction(
            title: Constants.deleteAlertDeleteTitle,
            style: .destructive
        ) {_ in
            action()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        presenter?.present(alertController)
    }
    
    func prepareLogoutAlert(action: @escaping () -> Void) {
        let alertController = UIAlertController(
            title: Constants.logoutAlertTitle,
            message: Constants.logoutAlertMessage,
            preferredStyle: .alert
        )
        let cancelAction = UIAlertAction(
            title: Constants.alertCancelTitle,
            style: .default
        )
        let logoutAction = UIAlertAction(
            title: Constants.logoutAlertLogoutTitle,
            style: .destructive
        ) {_ in
            action()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(logoutAction)
        presenter?.present(alertController)
    }
    
}

// MARK: - AddEditPersonListener Methods
extension PeopleViewModel: AddEditPersonListener {

    func addNewPerson(_ person: Person?) {
        // Add person
        guard let person = person else { return }
        PeopleDataHandler.instance.addPerson(person) { [weak self] error in
            guard let self = self else { return }
            guard let error = error else {
                let indexPath = IndexPath(row: self.people.count, section: 0)
                self.people.append(person)
                self.presenter?.insertRows(at: [indexPath])
                self.scroll(to: indexPath)
                return
            }
            self.showToast(with: error)
        }
    }

    func updatePerson(_ person: Person, with updatedPerson: Person?) {
        // Update person
        guard let documentId = person.documentId,
              let person = updatedPerson else { return }
        PeopleDataHandler.instance.updatePerson(at: documentId, with: person) { [weak self] error in
            guard let error = error else {
                if let index = self?.people.firstIndex(where: { $0.documentId == person.documentId }) {
                    let indexPath = IndexPath(row: index, section: 0)
                    self?.people[index] = person
                    self?.presenter?.reloadRows(at: [indexPath])
                    self?.scroll(to: indexPath)
                }
                return
            }
            self?.showToast(with: error)
        }
    }

    func doesPersonExist(_ person: Person?) -> Bool {
        return people.contains(where: {
            return $0.name == person?.name
                && $0.occupation == person?.occupation
                && $0.nationality == person?.nationality
                && $0.image == person?.image
        })
    }

}

// MARK: - UIUserInterfaceStyle Helpers
extension UIUserInterfaceStyle {
    
    var image: UIImage? {
        switch self {
        case .light:
            return UIImage(systemName: "sun.max")
        case .dark:
            return UIImage(systemName: "moon")
        default:
            return UIImage(systemName: "iphone.gen2")
        }
    }
    
    var overridingStyle: UIUserInterfaceStyle {
        switch self {
        case .light:
            return .dark
        case .dark:
            return .unspecified
        default:
            return .light
        }
    }
    
}
