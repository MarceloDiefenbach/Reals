//
//  SetUsernameViewModel.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 14/10/22.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class SetUsernameViewModel {
    
    var service = ServiceFirebase()
    let firebaseAuth = Auth.auth()
    
    func setUsername(username: String, completionHandler: @escaping (AlertCases) -> Void) {
        if username == "" {
            completionHandler(.emptyFields)
            
        } else {
            service.verifyIsExist(username: username, completionHandler: { (existUsername) -> Void in
                if existUsername {
                    completionHandler(.usernameAlreadyExist)
                    
                } else {
                    let db = Firestore.firestore()
                    db.collection("users").document(self.firebaseAuth.currentUser?.uid ?? "").setData([
                        "email": self.firebaseAuth.currentUser?.email ?? "",
                        "uid": self.firebaseAuth.currentUser?.uid ?? "",
                        "username": username
                    ]) { err in
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            print("the user has sign up or is logged in")
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                        AppCoordinator.shared.changeToRootViewController(atStoryboard: "Feed")
                    })
                }
            })
        }
    }
}
