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
    let service = ServiceFirebase()
    let serviceUpload = ServiceUpload()
    
    //MARK: - outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var adminButton: UIButton!
    
    
    //MARK: - actions
    @IBAction func deleteAccount(_ sender: Any) {
        deleteUser()
    }
    
    @IBAction func logOut(_ sender: Any) {
        logOut()
    }
    
    @IBAction func adminEntry(_ sender: Any) {
        AppCoordinator.shared.changeToRootViewController(atStoryboard: "Admin")
    }
    
    //MARK: - ViewDidLoad
    
    override func viewDidLoad() {
        setUsersData()
        setupLogoutButton(button: logOutButton)
        setupPrimaryButton(button: adminButton)
        
        if UserDefaults.standard.string(forKey: "username") != "PohMarcelo" {
            adminButton.isHidden = true
        }
    }
    
    //MARK: - layout
    func setupLogoutButton(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height/2
        button.backgroundColor = UIColor(named: "primary")
    }
    
}

//MARK: - functions

extension ProfileViewController {
    
    func logOut() {
        do {
            try firebaseAuth.signOut()
            
            AppCoordinator.shared.changeToRootViewController(atStoryboard: "Main")
            
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func deleteUser() {
        let alert = UIAlertController(title: "Apagar conta", message: "Essa ação não poderá ser desfeita", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Apagar conta", style: .destructive, handler:  { action in
            
            self.firebaseAuth.currentUser?.delete()
            self.db.collection("users").document(self.firebaseAuth.currentUser?.uid ?? "").delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    
                    do {
                        try self.firebaseAuth.signOut()
                        
                        AppCoordinator.shared.changeToRootViewController(atStoryboard: "Main")
                        
                    } catch let signOutError as NSError {
                        print("Error signing out: %@", signOutError)
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "Não apagar", style: .default, handler: { action in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}

//MARK: - set de UI

extension ProfileViewController {
    
    func setUsersData() {
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        
        username.text = UserDefaults.standard.string(forKey: "username")
    }
    
}
