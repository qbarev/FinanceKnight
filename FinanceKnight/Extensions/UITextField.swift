//
//  UITextField.swift
//  FinanceKnight
//
//  Created by Kirill Kubarev on 26.05.2020.
//  Copyright © 2020 Kirill Kubarev. All rights reserved.
//

import UIKit

extension UITextField {
    
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
    
    @IBInspectable var doneAccessory : Bool {
        get {
            inputAccessoryView != nil
        }
        set(setAccessory) {
            if setAccessory {
                addDoneButton()
            } else {
                removeDoneButton()
            }
        }
    }
    
    var number: NSNumber? {
        NumberFormatter().number(from: text ?? "0")
    }
    
    func availableAdding(string: String) -> Bool {
        switch string {
        case "":
            return self.text != ""
        case "0"..."9":
            return self.text != "0"
        case ".", ",":
            return self.text!.count > 0 && self.text!.range(of: ".") == nil && self.text!.range(of: ",") == nil
        default:
            return false
        }
    }
    
    func clear() {
        self.text = ""
    }
    
    private func addDoneButton() {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        self.inputAccessoryView = keyboardToolbar
    }
    
    private func removeDoneButton() {
        if inputAccessoryView != nil {
            inputAccessoryView = nil
        }
    }
    
    @objc private func dismissKeyboard() {
        self.resignFirstResponder()
    }
}
