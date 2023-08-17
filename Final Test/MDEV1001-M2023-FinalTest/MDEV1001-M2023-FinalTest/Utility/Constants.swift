//
//  Constants.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import UIKit

struct Constants {
    
    static let pre1850Period: Int = 1850
    static let pre1870Period: Int = 1870
    static let pre1900Period: Int = 1900
    static let minimumDate = Date(timeIntervalSince1970: -17987378950)
    static let headerViewHeight: CGFloat = 250
    static let placeholderFont = UIFont(name: "Helvetica Neue", size: 16)!
    static let animationDuration: TimeInterval = 0.3
    static let toastDisplayDuration: TimeInterval = 3
    
    static let suiteName = Bundle.main.infoDictionary!["CFBundleName"] as! String
    static let usersCollectionName = "Users"
    static let userEmailIdCodingKey = "email_id"
    static let peopleCollectionName = "People"
    static let storyboardName = "Main"
//    static let authenticationViewController = String(describing: AuthenticationViewController.self)
    static let peopleViewController = String(describing: PeopleViewController.self)
    static let personCell = String(describing: PersonTableViewCell.self)
    static let addEditPersonController = String(describing: AddEditPersonViewController.self)
    static let addEditPersonCell = String(describing: AddEditPersonTableViewCell.self)
    static let imagesListCell = String(describing: ImagesListTableViewCell.self)
    static let imageCell = String(describing: ImageCollectionViewCell.self)
    static let toastView = String(describing: ToastView.self)
    
    static let signUpTitle = "Create account"
    static let signUpSubtitle = "Please fill your details in the form below"
    static let signUpMessage = "Already have an account?"
    static let signUp = "Sign Up"
    static let signInTitle = "Welcome back"
    static let signInSubtitle = "Please log in with your details below"
    static let signInMessage = "Don't have an account?"
    static let signIn = "Sign In"
    static let nameFieldPlaceholder = "Full name"
    static let usernameFieldPlaceholder = "Username"
    static let emailFieldPlaceholder = "Email address"
    static let confirmEmailFieldPlaceholder = "Confirm email address"
    static let passwordFieldPlaceholder = "Password"
    static let confirmPasswordFieldPlaceholder = "Confirm password"
    static let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    static let registrationFailedMessage = "Registration failed"
    static let authenticationFailedMessage = "Authentication failed"
    
    static let peopleViewControllerTitle = "Favourite People"
    static let na = "N/A"
    static let edit = "Edit"
    static let delete = "Delete"
    static let editPerson = "Edit Person"
    static let addPerson = "Add Person"
    static let personNameFieldPlaceholder = "Name"
    static let personOccupationFieldPlaceholder = "Occupation"
    static let personNationalityFieldPlaceholder = "Nationality"
    static let personBirthDateFieldPlaceholder = "Birth Date"
    static let personBirthPlaceFieldPlaceholder = "Birth Place"
    static let personAchievementsFieldPlaceholder = "Achievements"
    static let personBioFieldPlaceholder = "Bio"
    static let fieldErrorMessageSubtext = "is required"
    static let personExistsErrorMessage = "This person already exists in the database"
    static let deleteAlertMessage = "This action will delete it from the database permanently."
    static let deleteAlertDeleteTitle = "Delete"
    static let logoutAlertMessage = "You will have to sign in again once you log out."
    static let logoutAlertTitle = "Logout?"
    static let logoutAlertLogoutTitle = "Logout"
    static let alertCancelTitle = "Cancel"
    
}
