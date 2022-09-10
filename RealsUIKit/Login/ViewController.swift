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
    
    let firebaseAuth = Auth.auth()

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginButton(_ sender: Any) {
        
        doLogin(email: emailField.text ?? "", password: passwordField.text ?? "", completionHandler: { (completionReturn) -> Void in
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
    
    func doLogin(email: String, password: String, completionHandler: @escaping (String) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard let strongSelf = authResult?.user else { return }
            print(strongSelf)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                self.performSegue(withIdentifier: "goToFeed", sender: nil)
            })


        }
        completionHandler("teste")
    }
}


