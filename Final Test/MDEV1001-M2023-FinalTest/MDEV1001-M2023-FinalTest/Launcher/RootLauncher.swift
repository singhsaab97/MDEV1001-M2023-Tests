//
//  RootLauncher.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import Foundation
import FirebaseCore

final class RootLauncher {
    
    private let window: UIWindow?
    
    init(window: UIWindow?) {
        self.window = window
        setup()
    }
    
}

// MARK: - Exposed Helpers
extension RootLauncher {
    
    func launch() {
        let viewController = PeopleViewController.loadFromStoryboard()
        let viewModel = PeopleViewModel(listener: nil)
        viewController.viewModel = viewModel
        viewModel.presenter = viewController
        let navigationController = viewController.embeddedInNavigationController
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.isTranslucent = true
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
}

// MARK: - Private Helpers
private extension RootLauncher {
    
    func setup() {
        FirebaseApp.configure()
        setTintColors()
        setUserInterfaceStyle(with: UserDefaults.userInterfaceStyle)
    }
    
    func setTintColors() {
        UINavigationBar.appearance().tintColor = .systemPink
    }
    
    func setUserInterfaceStyle(with style: UIUserInterfaceStyle) {
        window?.overrideUserInterfaceStyle = style
    }
    
}

// MARK: - AuthenticationListener Methods
//extension RootLauncher: AuthenticationListener {
//
//    func changeTheme(to style: UIUserInterfaceStyle) {
//        guard let view = window else { return }
//        UIView.transition(with: view, duration: Constants.animationDuration) { [weak self] in
//            self?.setUserInterfaceStyle(with: style)
//        }
//    }
//
//}
