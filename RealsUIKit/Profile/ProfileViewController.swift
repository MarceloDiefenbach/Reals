//
//  ProfileViewController.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 10/09/22.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

class ProfileViewController: UIViewController {
    
    let firebaseAuth = Auth.auth()
    let db = Firestore.firestore()
    
    //MARK: - outlets
    
    
    
    //MARK: - actions
    
    @IBAction func deleteAccount(_ sender: Any) {
        
        let alert = UIAlertController(title: "Apagar conta", message: "Essa ação não poderá ser desfeita", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Apagar conta", style: .destructive, handler:  { action in
            
            self.firebaseAuth.currentUser?.delete()
            self.db.collection("users").document(self.firebaseAuth.currentUser?.uid ?? "").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            
            do {
                try self.firebaseAuth.signOut()
                
                self.presentingViewController?.dismiss(animated: true, completion: nil)
                
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
            
            //TODO: - voltar para o login
            
        }))
        alert.addAction(UIAlertAction(title: "Não apagar", style: .default, handler: { action in
            
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func logOut(_ sender: Any) {
        
        do {
            try firebaseAuth.signOut()
            
            self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)
            
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        //TODO: - voltar para o login
        
        
    }
    
    override func viewDidLoad() {
        
    }
    
    
    
}
