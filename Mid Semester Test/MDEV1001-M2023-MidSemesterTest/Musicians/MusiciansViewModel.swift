//
//  MusiciansViewModel.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import UIKit
import CoreData

protocol MusiciansPresenter: AnyObject {
    func setNavigationTitle(_ title: String)
    func reloadSections(_ indexSet: IndexSet)
    func reloadRows(at indexPaths: [IndexPath])
    func insertRows(at indexPaths: [IndexPath])
    func deleteRows(at indexPaths: [IndexPath])
    func scroll(to indexPath: IndexPath)
    func present(_ viewController: UIViewController)
    func push(_ viewController: UIViewController)
}

protocol MusiciansViewModelable {
    var numberOfMusicians: Int { get }
    var sortButtonImage: UIImage? { get }
    var sortContextMenu: UIMenu { get }
    var presenter: MusiciansPresenter? { get set }
    func screenWillAppear()
    func screenLoaded()
    func addButtonTapped()
    func deleteAllButtonTapped()
    func cancelSearchButtonTapped()
    func didTypeSearchText(_ text: String)
    func getCellViewModel(at indexPath: IndexPath) -> MusicianCellViewModelable?
    func didSelectMusician(at indexPath: IndexPath)
    func leadingSwipedMusician(at indexPath: IndexPath) -> UIContextualAction
    func trailingSwipedMusician(at indexPath: IndexPath) -> UISwipeActionsConfiguration
}

final class MusiciansViewModel: MusiciansViewModelable,
                                Toastable {
    
    enum SortOption: Int, CaseIterable {
        case alphabetically
        case youngest
        case oldest
        case mostActiveYears
        case leastActiveYears
    }
    
    enum Operation {
        case add(musician: Musician)
        case edit(musician: Musician)
        case delete(indexPath: IndexPath)
        case deleteAll
    }
    
    private var musicians: [Musician]
    private var filteredMusicians: [Musician]
    private var isExpandedDict: [ObjectIdentifier: Bool]
    private var isSearching: Bool
        
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: Constants.dbModelName)
        container.loadPersistentStores { [weak self] (_, error) in
            self?.logError(error)
        }
        return container
    }()
    
    weak var presenter: MusiciansPresenter?
    
    init() {
        self.musicians = []
        self.filteredMusicians = []
        self.isExpandedDict = [:]
        self.isSearching = false
        saveData()
    }
    
}

// MARK: - Exposed Helpers
extension MusiciansViewModel {
    
    var numberOfMusicians: Int {
        return isSearching ? filteredMusicians.count : musicians.count
    }
    
    var sortButtonImage: UIImage? {
        return UIImage(systemName: "square.stack")
    }
    
    var sortContextMenu: UIMenu {
        let actions = SortOption.allCases.map { option in
            return UIAction(title: option.title) { [weak self] _ in
                guard option != UserDefaults.sortOption else { return }
                self?.execute(sortingWith: option)
            }
        }
        return UIMenu(children: actions)
    }
    
    func screenWillAppear() {
        presenter?.setNavigationTitle(Constants.musiciansViewControllerTitle)
    }
    
    func screenLoaded() {
        loadData()
        presenter?.reloadSections(IndexSet(integer: 0))
    }
    
    func addButtonTapped() {
        showAddEditViewController(for: .add)
    }
    
    func deleteAllButtonTapped() {
        execute(operation: .deleteAll)
    }
    
    func cancelSearchButtonTapped() {
        isSearching = false
        filteredMusicians = []
        presenter?.reloadSections(IndexSet(integer: 0))
    }
    
    func didTypeSearchText(_ text: String) {
        isSearching = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        filteredMusicians = musicians.filter {
            return $0.fullname?.contains(text) ?? false
        }
        presenter?.reloadSections(IndexSet(integer: 0))
    }
    
    func getCellViewModel(at indexPath: IndexPath) -> MusicianCellViewModelable? {
        let musicians = isSearching ? filteredMusicians : musicians
        guard let musician = musicians[safe: indexPath.row],
              let isExpanded = isExpandedDict[musician.id] else { return nil }
        return MusicianCellViewModel(musician: musician, isExpanded: isExpanded)
    }
    
    func didSelectMusician(at indexPath: IndexPath) {
        guard let musician = musicians[safe: indexPath.row],
              let isExpanded = isExpandedDict[musician.id] else { return }
        isExpandedDict[musician.id] = !isExpanded
        presenter?.reloadRows(at: [indexPath])
        scroll(to: indexPath)
    }
    
    func leadingSwipedMusician(at indexPath: IndexPath) -> UIContextualAction {
        // Edit action
        return UIContextualAction(style: .normal, title: Constants.edit) { [weak self] (_, _, _) in
            self?.editMusician(at: indexPath)
        }
    }
    
    func trailingSwipedMusician(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        // Delete action
        let action = UIContextualAction(style: .destructive, title: Constants.delete) { [weak self] (_, _, _) in
            self?.deleteMusician(at: indexPath)
        }
        return UISwipeActionsConfiguration(actions: [action])
    }
    
}

// MARK: - Private Helpers
private extension MusiciansViewModel {
  
    /// Stores and persists data from `Musicians.json` if context doesn't exist
    func saveData() {
        guard !UserDefaults.areMusiciansSaved,
              let url = Bundle.main.url(
                forResource: Constants.jsonFileName,
                withExtension: "json"
              ),
              let data = try? Data(contentsOf: url),
              let jsonArray = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else { return }
        let context = persistentContainer.viewContext
        var posters = [String]()
        for (index, object) in jsonArray.enumerated() {
            let musicianId = Int16(index + 1)
            guard !doesMusicianExist(with: musicianId) else { continue }
            let musician = Musician(context: context)
            musician.musicianid = musicianId
            musician.fullname = object["fullName"] as? String
            musician.genres = object["genres"] as? String
            musician.instruments = object["instruments"] as? String
            musician.labels = object["labels"] as? String
            musician.dob = object["born"] as? Double ?? Constants.defaultDate
            musician.activeyears = object["yearsActive"] as? String
            musician.spouses = object["spouses"] as? String
            musician.kids = object["children"] as? String
            musician.relatives = object["relatives"] as? String
            musician.works = object["notableWorks"] as? String
            if let photo = object["imageURL"] as? String {
                musician.photo = photo
                posters.append(photo)
            }
        }
        saveContext(context)
        UserDefaults.appSuite.set(posters, forKey: UserDefaults.availablePostersKey)
        UserDefaults.appSuite.set(true, forKey: UserDefaults.areMusiciansSavedKey)
    }
    
    /// Load stored data from persistent container
    func loadData() {
        let context = persistentContainer.viewContext
        let request = Musician.fetchRequest()
        do {
            musicians = try context.fetch(request)
            musicians.forEach { musician in
                isExpandedDict[musician.id] = false
            }
            execute(sortingWith: UserDefaults.sortOption)
        } catch {
            logError(error)
        }
    }
    
    /// Check if a musician exists in the existing data model
    func doesMusicianExist(with id: Int16) -> Bool {
        let context = persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: Constants.dbModelName)
        request.predicate = NSPredicate(format: "musicianid == %@", String(id))
        do {
            let results = try context.fetch(request)
            return results.count > 0
        } catch {
            logError(error)
            return false
        }
    }
    
    func logError(_ error: Error?) {
        guard let nserror = error as? NSError else { return }
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
    }
    
    func editMusician(at indexPath: IndexPath) {
        guard !isSearching else {
            showToast(with: Constants.cannotEditDuringSearchMessage)
            return
        }
        guard let musician = musicians[safe: indexPath.row] else { return }
        showAddEditViewController(for: .edit(musician: musician))
    }
    
    func deleteMusician(at indexPath: IndexPath) {
        guard !isSearching else {
            showToast(with: Constants.cannotDeleteDuringSearchMessage)
            return
        }
        execute(operation: .delete(indexPath: indexPath))
    }
    
    func setMusician(_ musician: Musician, with updatedMusician: LocalMusician) {
        musician.fullname = updatedMusician.fullName
        musician.genres = updatedMusician.genres
        musician.instruments = updatedMusician.instruments
        musician.labels = updatedMusician.labels
        musician.dob = updatedMusician.dob ?? Constants.defaultDate
        musician.activeyears = updatedMusician.activeYears
        musician.spouses = updatedMusician.spouses
        musician.kids = updatedMusician.kids
        musician.relatives = updatedMusician.relatives
        musician.works = updatedMusician.works
        musician.photo = updatedMusician.photo
    }
    
    func saveContext(_ context: NSManagedObjectContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            logError(error)
        }
    }
    
    func showAddEditViewController(for mode: AddEditMusicianViewModel.Mode) {
        let viewModel = AddEditMusicianViewModel(
            mode: mode,
            posters: UserDefaults.availablePosters,
            listener: self
        )
        let viewController = AddEditMusicianViewController.loadFromStoryboard()
        viewController.viewModel = viewModel
        presenter?.push(viewController)
    }
    
    func execute(operation: Operation) {
        let context = persistentContainer.viewContext
        switch operation {
        case let .add(musician):
            saveContext(context)
            musicians.append(musician)
            isExpandedDict[musician.id] = false
            let indexPath = IndexPath(row: Int(musician.musicianid - 1), section: 0)
            presenter?.insertRows(at: [indexPath])
            sortAndScroll(to: musician)
        case let .edit(musician):
            guard let index = musicians.firstIndex(where: { $0.musicianid == musician.musicianid }) else { return }
            saveContext(context)
            musicians[index] = musician
            let indexPath = IndexPath(row: index, section: 0)
            presenter?.reloadRows(at: [indexPath])
            sortAndScroll(to: musician)
        case let .delete(indexPath):
            guard let musician = musicians[safe: indexPath.row],
                  let index = musicians.firstIndex(of: musician) else { return }
            var alertTitle = Constants.delete
            if let title = musician.fullname {
                alertTitle.append(" \"\(title)\"?")
            }
            prepareDeleteAlert(with: alertTitle, message: Constants.deleteAlertMessage) { [weak self] in
                guard let self = self else { return }
                context.delete(musician)
                self.saveContext(context)
                self.musicians.removeAll(where: { $0 == musician })
                self.isExpandedDict.removeValue(forKey: musician.id)
                let indexPath = IndexPath(row: index, section: 0)
                self.presenter?.deleteRows(at: [indexPath])
            }
        case .deleteAll:
            guard !isSearching else {
                showToast(with: Constants.cannotDeleteDuringSearchMessage)
                return
            }
            prepareDeleteAlert(
                with: Constants.deleteAllAlertTitle,
                message: Constants.deleteAllAlertMessage
            ) { [weak self] in
                guard let self = self else { return }
                self.musicians.forEach { musician in
                    context.delete(musician)
                    self.isExpandedDict.removeValue(forKey: musician.id)
                }
                self.saveContext(context)
                let indexPaths = self.musicians.enumerated().map { (index, _) in
                    return IndexPath(row: index, section: 0)
                }
                self.musicians.removeAll()
                self.presenter?.deleteRows(at: indexPaths)
            }
        }
    }
    
    func execute(sortingWith option: SortOption) {
        switch option {
        case .alphabetically:
            musicians = musicians.sorted(by: {
                return $0.fullname ?? String() < $1.fullname ?? String()
            })
        case .youngest:
            musicians = musicians.sorted(by: {
                return $0.dob > $1.dob
            })
        case .oldest:
            musicians = musicians.sorted(by: {
                return $0.dob < $1.dob
            })
        case .mostActiveYears:
            musicians = musicians.sorted(by: {
                return getActiveYears(for: $0) > getActiveYears(for: $1)
            })
        case .leastActiveYears:
            musicians = musicians.sorted(by: {
                return getActiveYears(for: $0) < getActiveYears(for: $1)
            })
        }
        presenter?.reloadSections(IndexSet(integer: 0))
        UserDefaults.appSuite.set(option.rawValue, forKey: UserDefaults.sortOptionKey)
    }
    
    func getActiveYears(for musician: Musician) -> Int {
        // This works because active years is saved in the format (startYear-endYear)
        let startYear = LocalMusician.getStartYear(from: musician)
        let endYear = LocalMusician.getEndYear(from: musician)
        guard let startYear = startYear,
              let endYear = endYear else { return 0 }
        return endYear - startYear
    }
    
    func scroll(to indexPath: IndexPath) {
        DispatchQueue.main.async { [weak self] in
            self?.presenter?.scroll(to: indexPath)
        }
    }
    
    /// Called after adding or updating a musician to place the it on appropriate index based on the current sort option
    func sortAndScroll(to musician: Musician) {
        DispatchQueue.main.async { [weak self] in
            self?.execute(sortingWith: UserDefaults.sortOption)
            guard let index = self?.musicians.firstIndex(of: musician) else { return }
            let indexPath = IndexPath(row: index, section: 0)
            self?.scroll(to: indexPath)
        }
    }
    
    func prepareDeleteAlert(with title: String, message: String, action: @escaping () -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Constants.deleteAlertCancelTitle, style: .default)
        let deleteAction = UIAlertAction(title: Constants.deleteAlertDeleteTitle, style: .destructive) {_ in
            action()
        }
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        presenter?.present(alertController)
    }
    
}

// MARK: - AddEditMusicianListener Methods
extension MusiciansViewModel: AddEditMusicianListener {
    
    func addNewMusician(_ musician: LocalMusician) {
        let context = persistentContainer.viewContext
        let newMusician = Musician(context: context)
        let musicianId = Int16(musicians.count + 1)
        newMusician.musicianid = musicianId
        setMusician(newMusician, with: musician)
        execute(operation: .add(musician: newMusician))
    }
    
    func updateMusician(_ musician: Musician, with editedMusician: LocalMusician) {
        setMusician(musician, with: editedMusician)
        execute(operation: .edit(musician: musician))
    }
    
    func doesMusicianExist(_ musician: LocalMusician) -> Bool {
        return musicians.contains(where: { musician.isEqual(to: $0) })
    }
    
}

// MARK: - MusiciansViewModel.SortOption Helpers
private extension MusiciansViewModel.SortOption {
    
    var title: String {
        switch self {
        case .alphabetically:
            return Constants.alphabeticallyOption
        case .youngest:
            return Constants.youngestOption
        case .oldest:
            return Constants.oldestOption
        case .mostActiveYears:
            return Constants.mostActiveYearsOption
        case .leastActiveYears:
            return Constants.leastActiveYearsOption
        }
    }
    
}
