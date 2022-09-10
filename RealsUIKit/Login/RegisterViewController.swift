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
    
    var allUsernames: [String] = []

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    @IBAction func backToLoginButton(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func createAccountButton(_ sender: Any) {
        
        createAccount(username: "", email: emailField.text ?? "", password: passwordField.text ?? "", completionHandler: { (completionReturn) -> Void in
            
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.text = "lelode15@gmail.com"
        passwordField.text = "lelo318318"
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        service.getAllUsernames(completionHandler: { (completionReturn) -> Void in
            
            self.allUsernames = completionReturn
            print(self.allUsernames.first)
        })
        
    }
    
    //MARK: - FUNCTIONS
    
    func createAccount(username: String, email: String, password: String, completionHandler: @escaping (String) -> Void) {
        
        

        
        if self.allUsernames.contains(username) {
            print("ja existe")
        } else {
            print("nao existe")
//            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//                self.db.collection("users").document(self.firebaseAuth.currentUser?.uid ?? "").setData(
//                    [
//                        "username": self.usernameField.text!,
//                        "email": self.passwordField.text!,
//                        "friends": ["PohMarcelo", "Brenda"]
//                    ]
//                    , merge: true
//                )
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
//                    UserDefaults.standard.set(self.usernameField.text, forKey: "username")
//                    self.performSegue(withIdentifier: "goToFeed", sender: nil)
//                })
//            }
//            completionHandler("account created")
        }
    }
    
}
