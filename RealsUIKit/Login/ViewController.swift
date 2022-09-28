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
import AuthenticationServices
import CryptoKit

class ViewController: UIViewController {
    
    let firebaseAuth = Auth.auth()
    var service = ServiceFirebase()
    var serviceSocial = ServiceSocial()

    @IBOutlet weak var termsOfUseButton: UILabel!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailBG: UIView!
    @IBOutlet weak var PasswordBG: UIView!
    
    @IBOutlet weak var appleButtonInterface: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createAccountButton: UIButton!
    
    @IBAction func loginButton(_ sender: Any) {
        
        doLogin(email: emailField.text ?? "", password: passwordField.text ?? "", completionHandler: { (completionReturn) -> Void in
            print(self.firebaseAuth.currentUser?.email)
            print(completionReturn)
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestPermissionToNotifications()
        
        setTermsOfUseInteraction()
        
        setupTextFieldEmail(textField: emailField, backgroung: emailBG)
        setupTextFieldPassword(textField: passwordField, backgroung: PasswordBG)
        setupLoginButton(button: loginButton)
        setupAppleButton(button: appleButtonInterface)
        setupCreateAccountButton(button: createAccountButton)
        
    }
    
    func setupTextFieldEmail(textField: UITextField, backgroung: UIView) {
        textField.text = ""
        textField.layer.borderWidth = 0.0
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "black")!])
        textField.delegate = self
        
        backgroung.layer.borderWidth = 0.0
        backgroung.layer.cornerRadius = 16
        backgroung.layer.backgroundColor = UIColor(named: "textfieldColor")?.cgColor
    }
    
    func setupTextFieldPassword(textField: UITextField, backgroung: UIView) {
        textField.text = ""
        textField.layer.borderWidth = 0.0
        textField.isSecureTextEntry = true
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor : UIColor(named: "black")!])
        textField.delegate = self
        
        backgroung.layer.borderWidth = 0.0
        backgroung.layer.cornerRadius = 16
        backgroung.layer.backgroundColor = UIColor(named: "textfieldColor")?.cgColor
    }
    
    func setupLoginButton(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height/2
        button.backgroundColor = UIColor(named: "primary")
    }
    
    func setupCreateAccountButton(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height/2
    }
    
    func setupAppleButton(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height/2
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(.black).cgColor
        button.backgroundColor = .white
        
        button.setTitleColor(UIColor(named: "primary"), for: .normal)
    }
    
    @IBAction func appleButtonAction(_ sender: Any) {
        startSignInWithAppleFlow()
    }
        
    // Unhashed nonce.
    fileprivate var currentNonce: String?
    
     @available(iOS 13, *)
    @objc func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    
    //MARK: - FUNCTIONS
    
    func doLogin(email: String, password: String, completionHandler: @escaping (String) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
            if authResult != nil {
                self?.saveOnUserDefaults()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    AppCoordinator.shared.changeToRootViewController(atStoryboard: "Feed")
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
}

//MARK: - Terms of use button
extension ViewController {
    
    func setTermsOfUseInteraction() {
        
        let tapTermsOfUseButton = UITapGestureRecognizer(target: self, action: #selector(self.termsOfUseButtonFunction))
        termsOfUseButton.addGestureRecognizer(tapTermsOfUseButton)
        termsOfUseButton.isUserInteractionEnabled = true
    }

    @objc func termsOfUseButtonFunction(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.performSegue(withIdentifier: "showTermsOfUseLogin", sender: nil)
        }
    }
    
}


//MARK: - login with apple

extension ViewController {
    // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      let charset: Array<Character> =
          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
      var result = ""
      var remainingLength = length

      while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
          var random: UInt8 = 0
          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
          if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
          }
          return random
        }

        randoms.forEach { random in
          if remainingLength == 0 {
            return
          }

          if random < charset.count {
            result.append(charset[Int(random)])
            remainingLength -= 1
          }
        }
      }

      return result
    }
}

@available(iOS 13.0, *)
extension ViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: nonce)
            Auth.auth().signIn(with: credential) { [self] (authResult, error) in
                if (error != nil) {
                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                    // you're sending the SHA256-hashed nonce as a hex string with
                    // your request to Apple.
                    print(error?.localizedDescription ?? "")
                    return
                }
                guard let user = authResult?.user else { return }
                let email = user.email ?? ""
                let displayName = user.displayName ?? ""
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                let db = Firestore.firestore()
                db.collection("users").document(uid).setData([
                    "email": email,
                    "uid": uid
                ], merge: true) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("the user has sign up or is logged in")
                    }
                }
                serviceSocial.verifyIfHaveUsername(uid: self.firebaseAuth.currentUser?.uid ?? "", completionHandler: { (response) in
                    if response {
                        AppCoordinator.shared.changeToRootViewController(atStoryboard: "Feed")
                    } else {
                        AppCoordinator.shared.changeToRootViewController(atStoryboard: "SetUsername")
                    }
                })
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        print("Sign in with Apple errored: \(error)")
    }
}

extension ViewController : ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

//MARK: - keyboard controller
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
