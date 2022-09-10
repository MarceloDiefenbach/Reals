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

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    
    @IBAction func backToLoginButton(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)

    }
    
    @IBAction func createAccountButton(_ sender: Any) {
        
        createAccount(username: "", email: emailField.text ?? "", password: passwordField.text ?? "", completionHandler: { (completionReturn) -> Void in
            print(self.firebaseAuth.currentUser?.email)
            print(completionReturn)
            self.performSegue(withIdentifier: "goToFeed", sender: nil)
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.text = "lelode15@gmail.com"
        passwordField.text = "lelo318318"
        
    }
    
    //MARK: - FUNCTIONS
    
    func createAccount(username: String, email: String, password: String, completionHandler: @escaping (String) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            self.db.collection("users").document(self.firebaseAuth.currentUser?.uid ?? "").setData(
                [
                    "username": username,
                ]
                , merge: true
            )
        }
        completionHandler("account created")
    }
    
}
