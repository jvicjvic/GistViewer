//
//  UIViewController+Extensions.swift
//  GistsApp
//
//  Created by jvic on 30/08/24.
//

import Foundation
import UIKit

public extension UIViewController {
    func showAlertMessage(title: String, message: String) {
        let alertMessagePopUpBox = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alertMessagePopUpBox.addAction(okButton)
        present(alertMessagePopUpBox, animated: true)
    }
}
