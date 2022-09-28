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
        setupTextFieldDefault(textField: usernameField, backgroung: usernameBG)
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
        
        if emailField.text ?? "" == "" || passwordField.text ?? "" == "" || usernameField.text ?? "" == "" {
            let alert = UIAlertController(title: "Campos vazios", message: "Preencha todos os campos e tente novamente", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                //nothing to do
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            
            service.verifyIsExist(username: usernameField.text ?? "", completionHandler: { (existUsername) -> Void in
                
                if existUsername {
                    let alert = UIAlertController(title: "Usuário já existe", message: "O nome de usuário informado já está sendo utilizado, escolha outro e tente novamente", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        //nothing to do
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    self.createAccount(
                        username: self.usernameField.text ?? "",
                        email: self.emailField.text ?? "",
                        password: self.passwordField.text ?? "",
                        completionHandler: { (valueReturn) -> Void in
                            
                        })
                }
            })
        }
    }
    
    func createAccount(username: String, email: String, password: String, completionHandler: @escaping (String) -> Void) {

        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            
            if error == nil {
                self.db.collection("users").document(self.firebaseAuth.currentUser?.uid ?? "").setData(
                    [
                        "username": self.usernameField.text!,
                        "email": self.emailField.text!,
                        "fcmToken": "000"
                    ]
                    , merge: true
                )
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    UserDefaults.standard.set(self.usernameField.text, forKey: "username")
                    self.performSegue(withIdentifier: "goToFeed", sender: nil)
                })
            } else {
                switch error!._code {
                    case 17007:
                        let alert = UIAlertController(title: "E-mail já em uso", message: "Já existe uma conta vinculada a este e-mail", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                            //nothing to do
                        }))
                        self.present(alert, animated: true, completion: nil)
                        print("Email já existe")
                    default:
                        print("Outro erro \(error!._code)")
                }
            }
        }
        completionHandler("account created")
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
