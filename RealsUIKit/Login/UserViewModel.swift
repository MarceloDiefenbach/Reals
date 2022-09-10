//
//  LoginViewModel.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 10/09/22.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

struct UserViewModel {
    
    func doLogin(email: String, password: String, completionHandler: @escaping (String) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            guard let strongSelf = authResult?.user else { return }
        }
        completionHandler("teste")
    }
    
    func createAccount(email: String, password: String, completionHandler: @escaping (String) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            print(authResult)
            print(error)
        }
        completionHandler("teste")
    }
}
