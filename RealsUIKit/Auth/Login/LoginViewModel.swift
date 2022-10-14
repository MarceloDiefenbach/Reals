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

struct LoginViewModel {
    
    var service = ServiceFirebase()
    
    func doLogin(email: String, password: String, completionHandler: @escaping (AlertCases) -> Void) {
        
        if email == "" || password == "" {
            completionHandler(.emptyFields)
            
        } else if !email.contains("@") || !email.contains("."){
            completionHandler(.invalidEmail)
            
        } else {
            Auth.auth().signIn(withEmail: email, password: password) { [self] authResult, error in
                if authResult != nil {
                    saveOnUserDefaults(email: email)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
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
    }
    
    func saveOnUserDefaults(email: String) {
        
        service.getUserByEmail(email: email, completionHandler: { (response) in
            UserDefaults.standard.set(response, forKey: "username")
            UserDefaults.standard.set(email, forKey: "email")
        })
        
    }
    
    func requestPermissionToNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
}
