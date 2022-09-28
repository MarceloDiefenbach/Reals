//
//  setLayout+Extension.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 28/09/22.
//

import Foundation
import UIKit

extension UIViewController: UITextFieldDelegate {
    
    func setupTextFieldDefault(textField: UITextField, backgroung: UIView) {
        textField.text = ""
        textField.layer.borderWidth = 0.0
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "black")!])
        textField.delegate = self
        
        backgroung.layer.borderWidth = 0.0
        backgroung.layer.cornerRadius = 16
        backgroung.layer.backgroundColor = UIColor(named: "textfieldColor")?.cgColor
    }
    
    func setupTextFieldEmail(textField: UITextField, backgroung: UIView) {
        textField.text = ""
        textField.layer.borderWidth = 0.0
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "black")!])
        textField.textContentType = .emailAddress
        textField.delegate = self
        
        backgroung.layer.borderWidth = 0.0
        backgroung.layer.cornerRadius = 16
        backgroung.layer.backgroundColor = UIColor(named: "textfieldColor")?.cgColor
    }
    
    func setupTextFieldSecure(textField: UITextField, backgroung: UIView) {
        textField.text = ""
        textField.layer.borderWidth = 0.0
        textField.isSecureTextEntry = true
        textField.textContentType = .password
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "black")!])
        textField.delegate = self
        
        backgroung.layer.borderWidth = 0.0
        backgroung.layer.cornerRadius = 16
        backgroung.layer.backgroundColor = UIColor(named: "textfieldColor")?.cgColor
    }
    
    func setupPrimaryButton(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height/2
        button.backgroundColor = UIColor(named: "primary")
        button.titleLabel?.tintColor = UIColor.black
    }
    
    //MARK: - control of keyboard
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
