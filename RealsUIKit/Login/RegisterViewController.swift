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

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    
    @IBAction func loginButton(_ sender: Any) {
        
        createAccount(email: emailField.text ?? "", password: passwordField.text ?? "", completionHandler: { (completionReturn) -> Void in
            print(self.firebaseAuth.currentUser?.email)
            print(completionReturn)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        if firebaseAuth.currentUser?.email != nil {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.text = "lelode15@gmail.com"
        passwordField.text = "lelo318318"
        
    }
    
    //MARK: - FUNCTIONS
    
    func createAccount(email: String, password: String, completionHandler: @escaping (String) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            print(authResult)
            print(error)
        }
        completionHandler("teste")
    }
    
}
