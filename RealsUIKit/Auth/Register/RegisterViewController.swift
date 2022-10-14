//
//  RegisterViewController.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 10/09/22.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    var registerViewModel = RegisterViewModel()

    let firebaseAuth = Auth.auth()
    let db = Firestore.firestore()
    var service = ServiceFirebase()
    
    var allUsernames: [String] = [""]

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var termsOfUseButton: UILabel!
    @IBOutlet weak var usernameBG: UIView!
    @IBOutlet weak var emailBG: UIView!
    @IBOutlet weak var passwordBG: UIView!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var backToLoginButton: UIButton!
    
    
    override func viewDidLoad() {
        
        setupOutlineButton(button: backToLoginButton)
        setupCreateAccountButton(button: createAccountButton)
        
        
        setupTextFieldEmail(textField: emailField, backgroung: emailBG)
        setupTextFieldDefault(placeholder: "Username", textField: usernameField, backgroung: usernameBG)
        setupTextFieldSecure(textField: passwordField, backgroung: passwordBG)
    }
    
    func setupCreateAccountButton(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height/2
    }
    
    func setupOutlineButton(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height/2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(.black).cgColor
        button.backgroundColor = .white
    }
    
    
    //MARK: - FUNCTIONS
    
    @IBAction func backToLoginButton(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func createAccountButton(_ sender: Any) {
        
        registerViewModel.createAccount(email: emailField.text ?? "", password: passwordField.text ?? "", username: usernameField.text ?? "", completionHandler: { (response) in
                let alert = UIAlertController(title: response.alertTitle, message: response.alertDescription, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                    //nothing to do
                }))
                self.present(alert, animated: true, completion: nil)
            
        })
    }
        
    func setTermsOfUseInteraction() {
        
        let tapTermsOfUseButton = UITapGestureRecognizer(target: self, action: #selector(self.termsOfUseButtonFunction))
        termsOfUseButton.addGestureRecognizer(tapTermsOfUseButton)
        termsOfUseButton.isUserInteractionEnabled = true
    }

    @objc func termsOfUseButtonFunction(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.performSegue(withIdentifier: "showTermsOfUse", sender: nil)
        }
    }
}
