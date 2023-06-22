//
//  AddEditMusicianTableViewCell.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import UIKit

final class AddEditMusicianTableViewCell: UITableViewCell,
                                          ViewLoadable {
    
    static var name = Constants.addEditMusicianCellName
    static var identifier = Constants.addEditMusicianCellIdentifier
    
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
    
    private var viewModel: AddEditMusicianCellViewModelable?

}

// MARK: - Exposed Helpers
extension AddEditMusicianTableViewCell {
    
    func configure(with viewModel: AddEditMusicianCellViewModelable) {
        self.viewModel = viewModel
        self.viewModel?.presenter = self
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
private extension AddEditMusicianTableViewCell {
    
    func addDatePicker(with viewModel: AddEditMusicianCellViewModelable) {
        guard viewModel.field.isDateField else { return }
        datePicker.minimumDate = viewModel.minimumAllowedDate
        datePicker.maximumDate = viewModel.maximumAllowedDate
        datePicker.setDate(viewModel.birthDate, animated: true)
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
extension AddEditMusicianTableViewCell: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return viewModel?.didTypeText(textField.text, newText: string) ?? false
    }
    
}

// MARK: - AddEditMusicianCellPresenter Methods
extension AddEditMusicianTableViewCell: AddEditMusicianCellPresenter {
    
    func updateDobField(with dob: String) {
        textField.text = dob
    }
    
    func dismissDatePicker() {
        textField.resignFirstResponder()
    }
    
}
