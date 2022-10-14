//
//  SetUsernameViewController.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 19/09/22.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class SetUsernameViewController: UIViewController {
    
    var setUsernameViewModel = SetUsernameViewModel()
    
    var service = ServiceFirebase()
    let firebaseAuth = Auth.auth()
    var email: String?
    var uid: String?
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var usernameBG: UIView!
    @IBOutlet weak var setUsernameButton: UIButton!
    
    override func viewDidLoad() {
        setupTextFieldDefault(placeholder: "Username", textField: usernameField, backgroung: usernameBG)
        
    }
    
    @IBAction func finishButtonAction(_ sender: Any) {
        
        setUsernameViewModel.setUsername(username: usernameField.text ?? "", completionHandler: { (response) in
            let alert = UIAlertController(title: response.alertTitle, message: response.alertDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                //nothing to do
            }))
            self.present(alert, animated: true, completion: nil)
        })
    }
}
