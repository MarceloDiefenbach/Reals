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
                let dataDescription = document.data()
                if dataDescription?["username"] == nil || dataDescription?["username"] as! String == "" {
                    completionHandler(false)
                } else {
                    completionHandler(true)
                }
            } else {
                print("Document does not exist")
                completionHandler(false)
            }
        }
    }
    
    
    func followSomeone(userToFollow: User, completionHandler: @escaping (Bool) -> Void) {
        db.collection("users")
            .document(firebaseAuth.currentUser!.uid)
            .collection("following")
            .document(userToFollow.userId).setData(
                [
                    "username" : userToFollow.username,
                    "email" : userToFollow.email,
                    "userId" : userToFollow.userId,
                    "fcmToken" : userToFollow.fcmToken,
                ]
            )
        db.collection("users")
            .document(userToFollow.userId)
            .collection("followers")
            .document(firebaseAuth.currentUser!.uid).setData(
                [
                    "username" : UserDefaults.standard.string(forKey: "username") ?? "",
                    "email" : firebaseAuth.currentUser!.email ?? "",
                    "userId" : firebaseAuth.currentUser!.uid,
                    "fcmToken" : UserDefaults.standard.string(forKey: "fcmTokenNow") ?? "",
                ],
                merge: true)
        //        sender.sendFollowNotification(user: userToFollow)
        completionHandler(true)
        
    }
    
    func unfollowSomeone(usernameToUnfollow: User, completionHandler: @escaping (Bool) -> Void) {
        db.collection("users").document(firebaseAuth.currentUser!.uid).collection("following").whereField("username", isEqualTo: usernameToUnfollow.username).getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!)
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
        db.collection("users").document(usernameToUnfollow.userId).collection("followers").whereField("username", isEqualTo: UserDefaults.standard.string(forKey: "username") ?? "").getDocuments { (querySnapshot, error) in
            if error != nil {
                print(error!)
            } else {
                for document in querySnapshot!.documents {
                    document.reference.delete()
                }
            }
        }
    }
    
    func getUsersFollowing(completionHandler: @escaping ([User]) -> Void ) {
        
        var allFollowing: [User] = []
        print(firebaseAuth.currentUser!.uid)
        db.collection("users").document(firebaseAuth.currentUser!.uid).collection("following").getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    if let username = document.data()["username"] as? String,
                       let email = document.data()["email"] as? String,
                       let userId = document.data()["userId"] as? String,
                       let fcmToken = document.data()["fcmToken"] as? String {
                        allFollowing.append(
                            User(
                                username: username,
                                email: email,
                                userId: userId,
                                fcmToken: fcmToken
                            )
                        )
                    }
                }
            }
            completionHandler(allFollowing)
        }
    }
    
    func getFollowers(completionHandler: @escaping ([User]) -> Void ) {
        
        var allFollowing: [User] = []
        print(firebaseAuth.currentUser!.uid)
        db.collection("users").document(firebaseAuth.currentUser!.uid).collection("followers").getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    
                    if let username = document.data()["username"] as? String,
                       let email = document.data()["email"] as? String,
                       let userId = document.data()["userId"] as? String,
                       let fcmToken = document.data()["fcmToken"] as? String {
                        allFollowing.append(
                            User(
                                username: username,
                                email: email,
                                userId: userId,
                                fcmToken: fcmToken
                            )
                        )
                    }
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
                                
                                if let fcmToken = data["fcmToken"] as? String {
                                    if username != UserDefaults.standard.string(forKey: "username") {
                                        if !response.contains(where: { $0.username == username }) {
                                            allUsersWithoutFriends.append(User(username: username, email: email, userId: userId, fcmToken: fcmToken))
                                        }
                                    }
                                } else {
                                    if username != UserDefaults.standard.string(forKey: "username") {
                                        if !response.contains(where: { $0.username == username }) {
                                            allUsersWithoutFriends.append(User(username: username, email: email, userId: userId, fcmToken: ""))
                                        }
                                    }
                                }
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
    
    func getFcmTokenOfFollowers(completionHandler: @escaping ([String]) -> Void) {
        
        var fcmTokens: [String] = []

        getFollowers(completionHandler: {(users) in
            
            self.db.collection("users").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    completionHandler(fcmTokens)
                } else {
                    
                    if let snapshotDocumentos = querySnapshot?.documents {
                        for doc in snapshotDocumentos {
                            
                            let data = doc.data()
                            
                            if let username = data["username"] as? String,
                               let email = data["email"] as? String,
                               let userId = doc.documentID as? String,
                               let fcmToken = data["fcmToken"] as? String {
                                
                                if username != UserDefaults.standard.string(forKey: "username") {
                                    if users.contains(where: { $0.username == username }) {
                                        fcmTokens.append(fcmToken)
                                    }
                                }
                            }
                        }
                        completionHandler(fcmTokens)
                    }
                }
            }
        })
    }

    func getAllFcmToken(completionHandler: @escaping ([String]) -> Void) {
        
        var fcmTokens: [String] = []
        self.db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completionHandler(fcmTokens)
            } else {
                if let snapshotDocumentos = querySnapshot?.documents {
                    for doc in snapshotDocumentos {
                        
                        let data = doc.data()
                        
                        if let fcmToken = data["fcmToken"] as? String {
                            fcmTokens.append(fcmToken)
                        }
                    }
                    completionHandler(fcmTokens)
                }
            }
        }
    }
    
    func changeDateOnFirebaseToSwitchDayPosts(token: String) {
        UserDefaults.standard.set(token, forKey: "fcmToken")
        db.collection("dateChange").document(firebaseAuth.currentUser?.uid ?? "").setData([
            "fcmToken": token
        ], merge: true) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("the user has sign up or is logged in")
            }
        }
    }
    
    func getDateChange() {
        
        let date = String(format: "%.0f", Date.now.timeIntervalSince1970.rounded())
        
        db.collection("dateChange")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        print(document.documentID)
                        self.db.collection("dateChange").document(document.documentID).setData([
                            "dateChangee": date
                        ], merge: true) { err in
                            if let err = err {
                                print("Error writing document: \(err)")
                            } else {
                                print("the user has sign up or is logged in")
                            }
                        }
                    }
                }
            }
        }
}
