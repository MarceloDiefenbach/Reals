//
//  ServiceSocial.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 14/09/22.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class ServiceSocial {
    
    let db = Firestore.firestore()
    let firebaseAuth = Auth.auth()
    
    func verifyIfHaveUsername(uid: String, completionHandler: @escaping (Bool) -> Void) {

        db.collection("users").document(uid).getDocument { (document, error) in
            if let document = document, document.exists {
                let dataDescription = document.data() as? [String: Any]
                if dataDescription?["username"] != nil && dataDescription?["username"] as! String != "" {
                    completionHandler(true)
                } else {
                    completionHandler(false)
                }
            } else {
                print("Document does not exist")
                completionHandler(false)
            }
        }
    }
    

    func followSomeone(usernameToFollow: String, completionHandler: @escaping (Bool) -> Void) {
        
        db.collection("users").document(firebaseAuth.currentUser!.uid).collection("friends").addDocument(data: ["username" : usernameToFollow])
        completionHandler(true)
    }
    
    func unfollowSomeone(usernameToUnfollow: String, completionHandler: @escaping (Bool) -> Void) {
        
        db.collection("users").document(firebaseAuth.currentUser!.uid).collection("friends").whereField("username", isEqualTo: usernameToUnfollow).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error)
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
    }
    
    func getUsersFollowing(completionHandler: @escaping ([User]) -> Void ) {
        
        var allFollowing: [User] = []
        
        db.collection("users").document(firebaseAuth.currentUser!.uid).collection("friends").getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    allFollowing.append(
                        User(
                            username: document.data()["username"] as! String,
                            email: "",
                            userId: ""
                        )
                    )
                }
            }
            completionHandler(allFollowing)
        }
    }
    
    func getAllUsersWithoutFriends(completionHandler: @escaping ([User]) -> Void) {
            
        getUsersFollowing(completionHandler: { (response) in
            
            var allUsersWithoutFriends: [User] = []
            
            self.db.collection("users").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    if let snapshotDocumentos = querySnapshot?.documents {
                        for doc in snapshotDocumentos {
                            
                            let data = doc.data()
                            
                            if let username = data["username"] as? String,
                               let email = data["email"] as? String,
                               let userId = doc.documentID as? String {
                                
                                if username != UserDefaults.standard.string(forKey: "username") {
                                    if !response.contains(where: { $0.username == username }) {
                                        allUsersWithoutFriends.append(User(username: username, email: email, userId: userId))
                                    }
                                }
                                print(allUsersWithoutFriends)
                            }
                        }
                        completionHandler(allUsersWithoutFriends)
                    }
                }
            }
        })
    }
    
    func verifyIfFcmTokenChange() {
        
        if UserDefaults.standard.string(forKey: "alreadySave") != nil {
            
            if let fcmTokenNow = UserDefaults.standard.string(forKey: "fcmTokenNow") {
             
                if let fcmToken = UserDefaults.standard.string(forKey: "fcmToken"){

                    if fcmToken != fcmTokenNow{
                        saveToken(token: fcmTokenNow)
                    }
                } else {
                    saveToken(token: fcmTokenNow)
                }
            }
        } else {
            
            if let fcmTokenNow = UserDefaults.standard.string(forKey: "fcmTokenNow") {
                saveToken(token: fcmTokenNow)
            }
        }
    }
    
    func saveToken(token: String) {
        UserDefaults.standard.set(token, forKey: "fcmToken")
        db.collection("users").document(firebaseAuth.currentUser?.uid ?? "").setData([
            "fcmToken": token
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("the user has sign up or is logged in")
            }
        }
    }
    
}
