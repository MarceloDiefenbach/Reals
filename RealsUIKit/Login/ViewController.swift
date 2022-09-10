//
//  LoginViewController.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 10/09/22.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class ViewController: UIViewController {
    
    var UserViewModel = UserViewModel()
    let firebaseAuth = Auth.auth()

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    
    @IBAction func loginButton(_ sender: Any) {
        
        UserViewModel.doLogin(email: emailField.text ?? "", password: passwordField.text ?? "", completionHandler: { (completionReturn) -> Void in
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
}
