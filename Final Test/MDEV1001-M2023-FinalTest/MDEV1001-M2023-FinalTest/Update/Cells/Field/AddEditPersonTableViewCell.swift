//
//  AddEditPersonTableViewCell.swift
//  MDEV1001-M2023-FinalTest
//
//  Created by Abhijit Singh on 16/08/23.
//

import UIKit

final class AddEditPersonTableViewCell: UITableViewCell,
                                        ViewLoadable {
    
    static var name = Constants.addEditPersonCell
    static var identifier = Constants.addEditPersonCell

    @IBOutlet private weak var textField: UITextField!
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    private lazy var datePickerToolbar: UIToolbar = {
        let toolbar = UIToolbar()
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneButtonTapped)
        )
        toolbar.items = [flexSpace, doneButton]
        toolbar.sizeToFit()
        return toolbar
    }()
    
    private var viewModel: AddEditPersonCellViewModelable?
    
}

// MARK: - Exposed Helpers
extension AddEditPersonTableViewCell {
    
    func configure(with viewModel: AddEditPersonCellViewModelable) {
        self.viewModel = viewModel
        textField.attributedPlaceholder = NSAttributedString(
            string: viewModel.field.placeholder,
            attributes: [
                .foregroundColor: UIColor.secondaryLabel,
                .font: Constants.placeholderFont
            ]
        )
        textField.keyboardType = viewModel.field.keyboardType
        textField.text = viewModel.fieldText
        // Assign date picker
        addDatePicker(with: viewModel)
    }
    
}

// MARK: - Private Helpers
private extension AddEditPersonTableViewCell {
    
    func addDatePicker(with viewModel: AddEditPersonCellViewModelable) {
        guard viewModel.field.isDateField else { return }
        datePicker.minimumDate = viewModel.minimumAllowedDate
        datePicker.maximumDate = Date()
        if let date = viewModel.birthDate {
            datePicker.setDate(date, animated: true)
        }
        textField.inputView = datePicker
        textField.inputAccessoryView = datePickerToolbar
    }
    
    @objc
    func datePickerValueChanged(_ sender: UIDatePicker) {
        viewModel?.didChangeDate(to: sender.date)
    }
    
    @objc
    func doneButtonTapped() {
        viewModel?.doneButtonTapped()
    }
    
}

// MARK: - UITextFieldDelegate Methods
extension AddEditPersonTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return viewModel?.didTypeText(textField.text, newText: string) ?? false
    }
    
}

// MARK: - AddEditPersonCellPresenter Methods
extension AddEditPersonTableViewCell: AddEditPersonCellPresenter {
    
    func updateBirthDateField(with birthDate: String) {
        textField.text = birthDate
    }
    
    func dismissDatePicker() {
        textField.resignFirstResponder()
    }
    
}
