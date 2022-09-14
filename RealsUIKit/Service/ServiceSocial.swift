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

    func followSomeone(usernameToFollow: String, completionHandler: @escaping (Bool) -> Void) {
        
        db.collection("users").document(firebaseAuth.currentUser!.uid).updateData([
            "friends": FieldValue.arrayUnion([usernameToFollow])
        ])
        
    }
    
    func unfollowSomeone(usernameToUnfollow: String, completionHandler: @escaping (Bool) -> Void) {
        
        db.collection("users").document(firebaseAuth.currentUser!.uid).updateData([
            "friends": FieldValue.arrayRemove([usernameToUnfollow])
        ])
        
    }
    
    func getUsersFollowing(completionHandler: @escaping ([User]) -> Void ) {
        
        var allFollowing: [User] = []
        
        db.collection("users").document(firebaseAuth.currentUser!.uid).getDocument() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if let data = querySnapshot?.data() {
                    let friends = data["friends"] as? [String] ?? []
                    
                    for friend in friends {
                        let user = User(username: friend, email: "", userId: "")
                        if user.username != UserDefaults.standard.string(forKey: "username") {
                            allFollowing.append(user)
                        }
                    }
                    completionHandler(allFollowing)
                }
            }
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
    
    
}
