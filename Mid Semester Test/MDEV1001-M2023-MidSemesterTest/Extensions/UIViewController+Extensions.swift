//
//  UIViewController+Extensions.swift
//  MDEV1001-M2023-MidSemesterTest
//
//  Created by Abhijit Singh on 21/06/23.
//  Copyright © 2023 Abhijit Singh. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func popViewController(completion: (() -> Void)?) {
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            completion?()
        }
        navigationController?.popViewController(animated: true)
        CATransaction.commit()
    }
    
}
