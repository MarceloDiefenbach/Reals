//
//  ServiceFirebase.swift
//  reals
//
//  Created by Marcelo Diefenbach on 04/09/22.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import AVFoundation

struct Post {
    let ownerId: String
    let ownerUsername: String
    let photo: String
    let title: String
    let postUid: String
}

struct FriendRequest {
    let ownerIdSender: String
    let ownerUsernameSender: String
    let ownerIdReceiver: String
    let ownerUsernameReceiver: String
    let requestId: String
}

struct User {
    let username: String
    let email: String
    let userId: String
}

struct ServiceFirebase {
    
    let db = Firestore.firestore()
    let firebaseAuth = Auth.auth()
    
    func getAllUsers(completionHandler: @escaping ([User]) -> Void) {
        
        var allUsers: [User] = []
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if let snapshotDocumentos = querySnapshot?.documents {
                    for doc in snapshotDocumentos {
                        
                        let data = doc.data()
                        
                        if let username = data["username"] as? String,
                           let email = data["email"] as? String {
                            
                            let user = User(username: username, email: email, userId: doc.documentID)
                            
                            allUsers.append(user)
                            print(allUsers)
                        }
                    }
                    completionHandler(allUsers)
                }
            }
        }
    }
    
    //MARK: - getAllFriends: get only username of friends
    func getAllFriends(completionHandler: @escaping ([User]) -> Void) {
        
        var allFriends: [User] = []
        
        db.collection("users").document(firebaseAuth.currentUser!.uid).getDocument() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if let data = querySnapshot?.data() {
                    let friends = data["friends"] as? [String] ?? []
                    
                    for friend in friends {
                        let user = User(username: friend, email: "", userId: "")
                        allFriends.append(user)
                        print(user)
                    }
                    completionHandler(allFriends)
                }
            }
        }
    }
    
    func getAllUsersWithoutFriends(completionHandler: @escaping ([User]) -> Void) {
            
        getAllFriends(completionHandler: { (response) in
            
            var allUsersWithoutFriends: [User] = []
            
            db.collection("users").getDocuments() { (querySnapshot, err) in
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
    
    func getAllPost(completionHandler: @escaping ([Post]) -> Void) {
        
        var posts: [Post] = []
        
        db.collection("posts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if let snapshotDocumentos = querySnapshot?.documents {
                    for doc in snapshotDocumentos {
                        
                        let data = doc.data()
                        
                        if let title = data["title"] as? String, let ownerId = data["ownerId"] as? String, let photo = data["photo"] as? String, let ownerUsername = data["ownerUsername"] as? String {
                            
                            let post = Post(ownerId: ownerId, ownerUsername: ownerUsername, photo: photo, title: title, postUid: doc.documentID)
                            
                            posts.append(post)
                            print(post)
                        }
                    }
                    completionHandler(posts)
                }
            }
        }
    }
    
    func getFriendsReals(completionHandler: @escaping ([Post]) -> Void) {
        
        var posts: [Post] = []
        
        let friendsUsername = ["PohMarcelo", "Brenda"]
        
        db.collection("posts").whereField("ownerUsername", in: friendsUsername).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if let snapshotDocumentos = querySnapshot?.documents {
                    for doc in snapshotDocumentos {
                        
                        let data = doc.data()
                        
                        if let title = data["title"] as? String, let ownerId = data["ownerId"] as? String, let photo = data["photo"] as? String, let ownerUsername = data["ownerUsername"] as? String {
                            
                            let post = Post(ownerId: ownerId, ownerUsername: ownerUsername, photo: photo, title: title, postUid: doc.documentID)
                            
                            posts.append(post)
                            print(post)
                        }
                    }
                    completionHandler(posts)
                }
            }
        }
    }
    
    func verifyIsExist(username: String, completionHandler: @escaping (Bool) -> Void) {
        
        var exist: Bool = false
        
        print(username)

        db.collection("users").whereField("username", isEqualTo: username)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        if document.data()["username"] as! String == username {
                            exist = true
                        } else {
                            exist = false
                        }
                        
                    }
                }
                completionHandler(exist)
        }

    }
    
    func createReals(urlVideo: String, username: String){
        
        db.collection("posts").document().setData(
            [
                "ownerId": firebaseAuth.currentUser?.uid,
                "ownerUsername": username,
                "photo": urlVideo,
                "title": "Teste Upload",
                "date": Date.now,
            ]
        )
    }
    
    func uploadVideo(urlVideo: URL, completionHandler: @escaping (Bool) -> Void) {
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = format.string(from: date)
        print(formattedDate)

        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        let storageRef = Storage.storage().reference()
        
        // Create a reference to the file you want to upload
        let riversRef = storageRef.child("videoReals/\(year)/\(month)/\(day)/\(String(describing: firebaseAuth.currentUser!.uid))-\(hour)-\(minute)-\(seconds).mp4")
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        
        
        // Upload the file to the path "images/rivers.jpg"
        let uploadTask = riversRef.putFile(from: urlVideo, metadata: metadata) { metadata, error in
            print(error)
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            print(size)
            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                print(url?.description)
                createReals(urlVideo: url?.description ?? "", username: "PohMarcelo")
            }
        }
        
        // Listen for state changes, errors, and completion of the upload.
        uploadTask.observe(.resume) { snapshot in
            // Upload resumed, also fires when the upload starts
        }
        
        uploadTask.observe(.pause) { snapshot in
            // Upload paused
        }
        
        uploadTask.observe(.progress) { snapshot in
            // Upload reported progress
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
            / Double(snapshot.progress!.totalUnitCount)
        }
        
        uploadTask.observe(.success) { snapshot in
            // Upload completed successfully
            print("finalizou")
            completionHandler(true)
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as? NSError {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    // File doesn't exist
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    break
                case .cancelled:
                    // User canceled the upload
                    break
                    
                    /* ... */
                    
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    break
                }
            }
        }
    }
    
    func addFriend(usernameToAdd: String) {
        
        if usernameToAdd != "" {
            db.collection("users").document(firebaseAuth.currentUser!.uid).updateData([
                "friends": FieldValue.arrayUnion([usernameToAdd ?? ""])
            ])
            
            getIdByUser(username: usernameToAdd, completionHandler: { (ownerID) -> Void in
                print()
                db.collection("users").document(ownerID).updateData([
                    "friends": FieldValue.arrayUnion([UserDefaults.standard.string(forKey: "username") ?? "k"])
                ])
            })
        }
    }
    
    func removeFriend(usernameToAdd: String) {
        
        if usernameToAdd != "" {
            db.collection("users").document(firebaseAuth.currentUser!.uid).updateData([
                "friends": FieldValue.arrayRemove([usernameToAdd ?? ""])
            ])
            
            getIdByUser(username: usernameToAdd, completionHandler: { (ownerID) -> Void in
                print()
                db.collection("users").document(ownerID).updateData([
                    "friends": FieldValue.arrayRemove([UserDefaults.standard.string(forKey: "username") ?? "k"])
                ])
            })
        }
    }
    
    func getAllRequestFriend(completionHandler: @escaping ([FriendRequest]) -> Void) {
        
        var exist: Bool = false
        
        var allFriendsRequests: [FriendRequest] = []

        db.collection("users").document(firebaseAuth.currentUser!.uid).collection("friendsRequest")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        
                        let data = document.data()
                        
                        if let ownerIdSender = data["ownerIdSender"] as? String,
                           let ownerUsernameSender = data["ownerUsernameSender"] as? String,
                           let ownerIdReceiver = data["ownerIdReceiver"] as? String,
                           let ownerUsernameReceiver = data["ownerUsernameReceiver"] as? String,
                           let requestId = document.documentID as?String {
                            
                            let friendRequest = FriendRequest(
                                ownerIdSender: ownerIdSender,
                                ownerUsernameSender: ownerUsernameSender,
                                ownerIdReceiver: ownerIdReceiver,
                                ownerUsernameReceiver: ownerUsernameReceiver,
                                requestId: requestId
                            )
                            
                            allFriendsRequests.append(friendRequest)
                            print(allFriendsRequests)
                    }
                }
                completionHandler(allFriendsRequests)
            }
        }
    }
    
    func doRequestFriend(
        ownerUsernameReceiver: String,
        completionHandler: @escaping (Bool) -> Void) {
        
        getIdByUser(username: ownerUsernameReceiver, completionHandler: { (usernameReturn) -> Void in
            
            db.collection("users").document(usernameReturn).collection("friendsRequest").document()
                .setData(
                    [
                        "ownerIdSender": firebaseAuth.currentUser?.uid,
                        "ownerUsernameSender": UserDefaults.standard.string(forKey: "username"),
                        "ownerIdReceiver": usernameReturn,
                        "ownerUsernameReceiver": ownerUsernameReceiver
                    ]
                )
            completionHandler(true)
        })
    }
    
    func deleteFriendRequest(requestId: String, completionHandler: @escaping (Bool) -> Void) {
        
        db.collection("users").document(firebaseAuth.currentUser!.uid).collection("friendsRequest").document(requestId).delete(){ err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
            completionHandler(true)
        }
    }
    
    func getIdByUser(username: String, completionHandler: @escaping (String) -> Void) {
        
        var ownerIDReceiver: String = ""

        db.collection("users").whereField("username", isEqualTo: username)
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        print("\(document.documentID) => \(document.data())")
                        
                        print(document.documentID)
                        ownerIDReceiver = document.documentID
                        
                    }
                }
                completionHandler(ownerIDReceiver)
        }

    }

    func acceptFriendRequest(
        ownerUsernameReceiver: String,
        requestId: String,
        completionHandler: @escaping (String) -> Void) {

            addFriend(usernameToAdd: ownerUsernameReceiver)

            deleteFriendRequest(requestId: requestId, completionHandler: { (deleteResponse) in

            })

    }
    
    func rejectFriendRequest(requestId: String) {
        deleteFriendRequest(requestId: requestId, completionHandler: { (deleteResponse) in

        })
    }
    
}
