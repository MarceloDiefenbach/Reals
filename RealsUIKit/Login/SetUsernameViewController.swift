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
        
        if usernameField.text ?? "" == "" {
            let alert = UIAlertController(title: "Campo vazio", message: "Você precisa preencher seu username", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                //nothing to do
            }))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            service.verifyIsExist(username: usernameField.text ?? "", completionHandler: { (existUsername) -> Void in
                
                print(existUsername)
                if existUsername {
                    let alert = UIAlertController(title: "Usuário já existe", message: "O nome de usuário informado já está sendo utilizado, escolha outro e tente novamente", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        //nothing to do
                    }))
                    self.present(alert, animated: true, completion: nil)
                    
                } else {
                    let db = Firestore.firestore()
                    db.collection("users").document(self.firebaseAuth.currentUser?.uid ?? "").setData([
                        "email": self.firebaseAuth.currentUser?.email ?? "",
                        "uid": self.firebaseAuth.currentUser?.uid ?? "",
                        "username": self.usernameField.text ?? ""
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("the user has sign up or is logged in")
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        self.performSegue(withIdentifier: "finishUsernameSet", sender: nil)
                    })
                }
            })
        }
    }
}
