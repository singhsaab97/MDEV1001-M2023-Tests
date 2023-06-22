//
//  MusiciansViewController.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import UIKit

final class MusiciansViewController: UIViewController,
                                     ViewLoadable {
    
    static var name = Constants.storyboardName
    static var identifier = Constants.musiciansViewControllerIdentifier
    
    @IBOutlet private weak var tableView: UITableView!
    
    var viewModel: MusiciansViewModelable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.presenter = self
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.screenWillAppear()
    }
    
}

// MARK: - Private Helpers
private extension MusiciansViewController {
    
    func setup() {
        addActionItems()
        MusicianTableViewCell.register(for: tableView)
        viewModel?.screenLoaded()
    }
    
    func addActionItems() {
        // Sort button
        let sortButton = UIBarButtonItem(
            image: viewModel?.sortButtonImage,
            style: .plain,
            target: self,
            action: nil
        )
        sortButton.menu = viewModel?.sortContextMenu
        navigationItem.leftBarButtonItem = sortButton
        // Add button
        let addButton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addButtonTapped)
        )
        // Delete all button
        let deleteAllButton = UIBarButtonItem(
            barButtonSystemItem: .trash,
            target: self,
            action: #selector(deleteAllButtonTapped)
        )
        navigationItem.rightBarButtonItems = [addButton, deleteAllButton]
        // Search controller
        let searchController = UISearchController()
        searchController.delegate = self
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
    }
    
    @objc
    func addButtonTapped() {
        viewModel?.addButtonTapped()
    }
    
    @objc
    func deleteAllButtonTapped() {
        viewModel?.deleteAllButtonTapped()
    }

}

// MARK: - UITableViewDelegate Methods
extension MusiciansViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        viewModel?.didSelectMusician(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let action = viewModel?.leadingSwipedMusician(at: indexPath) else { return nil }
        action.backgroundColor = .systemBlue
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return viewModel?.trailingSwipedMusician(at: indexPath)
    }
    
}

// MARK: - UITableViewDataSource Methods
extension MusiciansViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.numberOfMusicians ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel?.getCellViewModel(at: indexPath) else { return UITableViewCell() }
        let musicianCell = MusicianTableViewCell.dequeReusableCell(from: tableView, at: indexPath)
        musicianCell.configure(with: viewModel)
        return musicianCell
    }
    
}

// MARK: - UISearchControllerDelegate Methods
extension MusiciansViewController: UISearchControllerDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel?.cancelSearchButtonTapped()
    }
    
}

// MARK: - UISearchBarDelegate Methods
extension MusiciansViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel?.didTypeSearchText(searchText)
    }
    
}

// MARK: - MusiciansPresenter Methods
extension MusiciansViewController: MusiciansPresenter {
    
    func setNavigationTitle(_ title: String) {
        navigationItem.title = title
    }
    
    func reloadSections(_ indexSet: IndexSet) {
        tableView.reloadSections(IndexSet(integer: 0), with: .fade)
    }
    
    func reloadRows(at indexPaths: [IndexPath]) {
        tableView.reloadRows(at: indexPaths, with: .fade)
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .left)
        tableView.endUpdates()
    }
    
    func deleteRows(at indexPaths: [IndexPath]) {
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPaths, with: .right)
        tableView.endUpdates()
    }
    
    func scroll(to indexPath: IndexPath) {
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    func present(_ viewController: UIViewController) {
        navigationController?.present(viewController, animated: true)
    }
    
    func push(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
}
