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
    
    var service = ServiceFirebase()
    
    func doLogin(email: String, password: String, completionHandler: @escaping (String) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { [self] authResult, error in
            if authResult != nil {
                saveOnUserDefaults(email: email)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    AppCoordinator.shared.changeToRootViewController(atStoryboard: "Feed")
                })
            } else {
                //TODO: - show alerts
            }
        }
    }
    
    func createAccount(email: String, password: String, completionHandler: @escaping (String) -> Void) {
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            print(authResult)
            print(error)
        }
        completionHandler("teste")
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
