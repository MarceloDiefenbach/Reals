//
//  RegisterViewModel.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 14/10/22.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct RegisterViewModel {
    
    var service = ServiceFirebase()
    
    let firebaseAuth = Auth.auth()
    let db = Firestore.firestore()
    
    func createAccount(email: String, password: String, username: String, completionHandler: @escaping (AlertCases) -> Void) {
        if email == "" || password == "" || username == "" {
            completionHandler(.emptyFields)
            
        } else if !email.contains("@") || !email.contains(".") {
            completionHandler(.invalidEmail)
            
        } else {
            
            service.verifyIsExist(username: username, completionHandler: { (existUsername) -> Void in
                
                if existUsername {
                    completionHandler(.usernameAlreadyExist)
                
                } else {
                    Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                        
                        if error == nil {
                            self.db.collection("users").document(self.firebaseAuth.currentUser?.uid ?? "").setData(
                                [
                                    "username": username,
                                    "email": email,
                                    "fcmToken": "000"
                                ]
                                , merge: true
                            )
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                                UserDefaults.standard.set(username, forKey: "username")
                                AppCoordinator.shared.changeToRootViewController(atStoryboard: "Feed")
                            })
                        } else {
                            switch error!._code {
                                case 17007:
                                completionHandler(.emailAlreadyExist)
                                default:
                                completionHandler(.defaultError)
                            }
                        }
                    }
                }
            })
        }
    }
    
}
