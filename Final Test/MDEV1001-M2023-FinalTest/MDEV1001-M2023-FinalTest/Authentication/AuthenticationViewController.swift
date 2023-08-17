//
//  AuthenticationViewController.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import UIKit

final class AuthenticationViewController: UIViewController,
                                          ViewLoadable {
    
    static let name = Constants.storyboardName
    static let identifier = Constants.authenticationViewController
    
    @IBOutlet private weak var headingStackView: UIStackView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var confirmEmailTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var confirmPasswordTextField: UITextField!
    @IBOutlet private weak var primaryButton: UIButton!
    @IBOutlet private weak var spinnerView: UIActivityIndicatorView!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var messageButton: UIButton!
    @IBOutlet private weak var messageStackViewBottomConstraint: NSLayoutConstraint!
    
    var viewModel: AuthenticationViewModelable?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.screenDidAppear()
    }
    
}

// MARK: - Private Helpers
private extension AuthenticationViewController {
    
    func setup() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupTitleLabel()
        setupSubtitleLabel()
        setupDetailTextFields()
        setupPrimaryButton()
        setupSpinnerView()
        setupMessageLabel()
        setupMessageButton()
        addKeyboardObservers()
        viewModel?.screenDidLoad()
    }
    
    func setupTitleLabel() {
        titleLabel.text = viewModel?.flow.titleLabelText
    }

    func setupSubtitleLabel() {
        subtitleLabel.text = viewModel?.flow.subtitleLabelText
    }

    func setupDetailTextFields() {
        viewModel?.flow.fields.forEach { field in
            let textField = getTextField(for: field)
            textField.tag = field.rawValue
            textField.attributedPlaceholder = NSAttributedString(
                string: field.placeholder,
                attributes: [
                    .foregroundColor: UIColor.secondaryLabel,
                    .font: Constants.placeholderFont
                ]
            )
            textField.layer.cornerRadius = 12
            textField.keyboardType = field.keyboardType
            textField.isSecureTextEntry = field.isPasswordProtected
            // Horizontal views
            let textFieldViewWidth: CGFloat = 15
            let fieldViewFrame = CGRect(
                x: 0,
                y: 0,
                width: textFieldViewWidth,
                height: textField.bounds.height
            )
            let leftView = UIView(frame: fieldViewFrame)
            textField.leftView = leftView
            textField.leftViewMode = .always
            let rightView = UIView(frame: fieldViewFrame)
            textField.rightView = rightView
            textField.rightViewMode = .always
            if field.isPasswordProtected {
                // Add eye button
                let eyeButtonImageSize = CGSize(width: 27, height: 18.667)
                rightView.frame.size = CGSize(
                    width: 2 * fieldViewFrame.width + eyeButtonImageSize.width,
                    height: fieldViewFrame.height
                )
                let eyeButton = UIButton(type: .system)
                eyeButton.tag = field.rawValue
                eyeButton.tintColor = UIColor.tertiaryLabel
                let eyeButtonFrame = CGRect(
                    x: rightView.frame.midX - eyeButtonImageSize.width / 2,
                    y: rightView.frame.midY - eyeButtonImageSize.height / 2,
                    width: eyeButtonImageSize.width,
                    height: eyeButtonImageSize.height
                )
                eyeButton.frame = eyeButtonFrame
                eyeButton.addTarget(
                    self,
                    action: #selector(eyeButtonTapped(_:)),
                    for: .touchUpInside
                )
                rightView.addSubview(eyeButton)
            }
        }
        viewModel?.flow.hiddenFields.forEach { field in
            let textField = getTextField(for: field)
            textField.isHidden = true
        }
    }

    func setupPrimaryButton() {
        primaryButton.setTitle(viewModel?.flow.primaryButtonTitle, for: .normal)
        primaryButton.layer.cornerRadius = 12
    }
    
    func setupSpinnerView() {
        spinnerView.isHidden = true
    }

    func setupMessageLabel() {
        messageLabel.text = viewModel?.flow.messageLabelText
    }

    func setupMessageButton() {
        messageButton.setTitle(viewModel?.flow.messageButtonTitle, for: .normal)
    }
    
    func addKeyboardObservers() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            self?.keyboardWillShow(notification)
        }
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            self?.keyboardWillHide()
        }
    }

    /// Returns a text field for the specified `field` type
    func getTextField(for field: AuthenticationViewModel.Field) -> UITextField {
        switch field {
        case .name:
            return nameTextField
        case .username:
            return usernameTextField
        case .email:
            return emailTextField
        case .confirmEmail:
            return confirmEmailTextField
        case .password:
            return passwordTextField
        case .confirmPassword:
            return confirmPasswordTextField
        }
    }
    
    func keyboardWillShow(_ notification: Notification) {
        guard let frame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        viewModel?.keyboardWillShow(with: frame)
    }
    
    func keyboardWillHide() {
        viewModel?.keyboardWillHide()
    }

    @objc
    func eyeButtonTapped(_ sender: UIButton) {
        viewModel?.eyeButtonTapped(with: sender.tag)
    }
    
    @IBAction func primaryButtonTapped() {
        viewModel?.primaryButtonTapped()
    }
    
    @IBAction func messageButtonTapped() {
        viewModel?.messageButtonTapped()
    }
    
}

// MARK: - AuthenticationPresenter Methods
extension AuthenticationViewController: AuthenticationPresenter {
    
    var userFullName: String? {
        return nameTextField.text
    }
    
    var username: String? {
        return usernameTextField.text
    }

    var userEmail: String? {
        return emailTextField.text
    }
    
    var userConfirmedEmail: String? {
        return confirmEmailTextField.text
    }
    
    var userPassword: String? {
        return passwordTextField.text
    }

    var userConfirmedPassword: String? {
        return confirmPasswordTextField.text
    }
    
    var viewControllersCount: Int {
        return navigationController?.viewControllers.count ?? 0
    }
    
    func startLoading() {
        primaryButton.setTitle(nil, for: .normal)
        spinnerView.isHidden = false
        spinnerView.startAnimating()
    }
    
    func stopLoading() {
        spinnerView.stopAnimating()
        spinnerView.isHidden = true
        primaryButton.setTitle(viewModel?.flow.primaryButtonTitle, for: .normal)
    }

    func updateHeadingStackView(isHidden: Bool) {
        headingStackView.isHidden = isHidden
    }
    
    func showKeyboard(with height: CGFloat, duration: TimeInterval) {
        let safeAreaBottonInset = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        let additionalHeight = CGFloat(safeAreaBottonInset.isZero ? 20 : 0)
        messageStackViewBottomConstraint.constant = height + additionalHeight
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view?.layoutIfNeeded()
        }
    }
    
    func hideKeyboard(with duration: TimeInterval) {
        messageStackViewBottomConstraint.constant = 20
        UIView.animate(withDuration: duration) { [weak self] in
            self?.view?.layoutIfNeeded()
        }
    }

    func updatePasswordField(_ field: AuthenticationViewModel.Field, isTextHidden: Bool) {
        let textField = getTextField(for: field)
        textField.isSecureTextEntry = isTextHidden
    }

    func updateEyeButtonImage(for field: AuthenticationViewModel.Field, with image: UIImage?) {
        let textField = getTextField(for: field)
        guard let button = textField.rightView?.subviews
            .first(where: { $0 is UIButton }) as? UIButton else { return }
        button.setImage(image, for: .normal)
    }
    
    func clearDetailFields() {
        viewModel?.flow.fields.forEach { field in
            let textField = getTextField(for: field)
            textField.text = nil
        }
    }
    
    func activateTextField(_ field: AuthenticationViewModel.Field) {
        let textField = getTextField(for: field)
        textField.becomeFirstResponder()
    }

    func push(_ viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }

    func pop() {
        navigationController?.popViewController(animated: true)
    }

    func present(_ viewController: UIViewController) {
        navigationController?.present(viewController, animated: true)
    }
    
}

// MARK: - AuthenticationViewModel.Field Helpers
private extension AuthenticationViewModel.Field {

    var keyboardType: UIKeyboardType {
        switch self {
        case .name:
            return .alphabet
        case .email, .confirmEmail:
            return .emailAddress
        case .username, .password, .confirmPassword:
            return .default
        }
    }

}
