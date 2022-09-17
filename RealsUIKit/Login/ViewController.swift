//
//  LoginViewController.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 10/09/22.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import UserNotifications

class ViewController: UIViewController {
    
    let firebaseAuth = Auth.auth()
    var service = ServiceFirebase()
    var serviceSocial = ServiceSocial()
    var serviceUpload = ServiceUploadPanda()

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func loginButton(_ sender: Any) {
        
        doLogin(email: emailField.text ?? "", password: passwordField.text ?? "", completionHandler: { (completionReturn) -> Void in
            print(self.firebaseAuth.currentUser?.email)
            print(completionReturn)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if firebaseAuth.currentUser?.email != nil {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
//        serviceUpload.uploadPandaVideo()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.text = "lelod15@gmail.com"
        passwordField.text = "lelo318318"
        passwordField.isSecureTextEntry = true
        requestPermissionToNotifications()
        
    }
    
    
    //MARK: - FUNCTIONS
    
    func doLogin(email: String, password: String, completionHandler: @escaping (String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if authResult != nil {
                self?.saveOnUserDefaults()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    self?.performSegue(withIdentifier: "goToFeed", sender: nil)
                })
            }
        }
        completionHandler("teste")
    }
    
    func saveOnUserDefaults() {
        
        service.getUserByEmail(email: emailField.text ?? "", completionHandler: { (response) in
            print(response)
            UserDefaults.standard.set(response, forKey: "username")
            UserDefaults.standard.set(self.emailField.text, forKey: "email" ?? "")
        })
        
    }
}

extension ViewController {
    
    func requestPermissionToNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func setNotification() {
        
        let content = UNMutableNotificationContent()
        content.title = "Ei, ta na hora!"
        content.subtitle = "Vem gravar um Real"
        content.sound = UNNotificationSound.default

        // show this notification five seconds from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        // choose a random identifier
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        // add our notification request
        UNUserNotificationCenter.current().add(request)
    }
}


