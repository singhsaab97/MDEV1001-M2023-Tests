//
//  ToastView.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import UIKit

final class ToastView: UIView,
                       ViewLoadable {
    
    static var name = Constants.toastViewName
    static var identifier = Constants.toastViewIdentifier
    
    @IBOutlet private weak var messageLabel: UILabel!

}

// MARK: - Exposed Helpers
extension ToastView {
    
    func setMessage(_ message: String) {
        messageLabel.text = message
    }
   
}
