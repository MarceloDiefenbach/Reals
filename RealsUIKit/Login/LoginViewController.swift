//
//  LoginViewController.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 10/09/22.
//

import Foundation
import UIKit

class ViewController: UIViewController {
    
    var loginViewModel = LoginViewModel()


    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!

    
    @IBAction func loginButton(_ sender: Any) {
        
        loginViewModel.doLogin(email: emailField.text ?? "", password: passwordField.text ?? "", completionHandler: { (completionReturn) -> Void in
            print(completionReturn)
        })
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}
