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

struct FriendRequest {
    let username: String
    let requestId: String
}

struct ServiceFirebase {
    
    var serviceSocial = ServiceSocial()
    
#warning("se precisar de ajuda, falar com a gabi")
    // separar os serviços por tipo em arquivos diferentes
    // tem que ter um singleton que ai o serviço vai ser criado só uma vez
    
    let db = Firestore.firestore()
    let firebaseAuth = Auth.auth()
    
    func getAllPost(completionHandler: @escaping ([Post]) -> Void) {
        
        var posts: [Post] = []
        
        db.collection("posts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                if let snapshotDocumentos = querySnapshot?.documents {
                    for doc in snapshotDocumentos {
                        
                        let data = doc.data()
                        
                        if let title = data["title"] as? String,
                           let ownerId = data["ownerId"] as? String,
                           let photo = data["photo"] as? String,
                           let ownerUsername = data["ownerUsername"] as? String,
                           let videoPath = data["videoPath"] as? String,
                           let date = data["date"] as? Int {
                            
                            let post = Post(ownerId: ownerId, ownerUsername: ownerUsername, photo: photo, title: title, postUid: doc.documentID, videoPath: videoPath, date: date)
                            
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
        
        var friendsUsername: [String] = []
        
        serviceSocial.getUsersFollowing(completionHandler: { (friends) in
            
            friendsUsername = friends.map( { $0.username } )
            friendsUsername.append(UserDefaults.standard.string(forKey: "username") ?? "")
            
            db.collection("posts").whereField("date", isGreaterThan: UserDefaults.standard.integer(forKey: "dateChange")).order(by: "date", descending: true).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    
                    if let snapshotDocumentos = querySnapshot?.documents {
                        UserDefaults.standard.set(false, forKey: "alreadyPost")
                        for doc in snapshotDocumentos {
                            
                            let data = doc.data()
                            
                            if let title = data["title"] as? String,
                               let ownerId = data["ownerId"] as? String,
                               let photo = data["photo"] as? String,
                               let ownerUsername = data["ownerUsername"] as? String,
                               let videoPath = data["videoPath"] as? String,
                               let date = data["date"] as? Int {
                                
                                print(date)
                                
                                let post = Post(ownerId: ownerId, ownerUsername: ownerUsername, photo: photo, title: title, postUid: doc.documentID, videoPath: videoPath, date: date)
                                
                                //                                if post.date > UserDefaults.standard.integer(forKey: "dateChange") {
                                if friendsUsername.contains(where: {$0 == ownerUsername}) {
                                    posts.append(post)
                                    print(post)
                                }
                                
                                if ownerUsername == UserDefaults.standard.string(forKey: "username") {
                                    UserDefaults.standard.set(true, forKey: "alreadyPost")
                                }
                                //                                }
                                
                            }
                        }
                        completionHandler(posts)
                    }
                }
            }
            
        })
    }
    
    func verifyIsExist(username: String, completionHandler: @escaping (Bool) -> Void) {
        
        var exist: Bool = false
        
        print(username)
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    //                        print("\(document.documentID) => \(document.data())")
                    let usernameData = document.data()["username"] as? String
                    
                    if usernameData?.lowercased() == username.lowercased() {
                        exist = true
                        break
                    } else {
                        exist = false
                    }
                    
                }
            }
            completionHandler(exist)
        }
    }
    
    func createReals(urlVideo: String, videoPath: String){
        
        var refUser: DocumentReference? = nil
        refUser = db.collection("users").document(firebaseAuth.currentUser?.uid ?? "").collection("posts").addDocument(data:
            [
                "ownerId": firebaseAuth.currentUser?.uid ?? "",
                "ownerUsername": UserDefaults.standard.string(forKey: "username") ?? "",
                "photo": urlVideo,
                "title": "",
                "date": Int(Date.now.timeIntervalSince1970),
                "videoPath": videoPath
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(refUser!.documentID)")
                }
        }
        
        var ref: DocumentReference? = nil
        ref = db.collection("posts").addDocument(data:
            [
                "ownerId": firebaseAuth.currentUser?.uid ?? "",
                "ownerUsername": UserDefaults.standard.string(forKey: "username") ?? "",
                "photo": urlVideo,
                "title": "",
                "date": Int(Date.now.timeIntervalSince1970),
                "videoPath": videoPath,
                "documentIdOnUsersPosts": refUser!.documentID,
                "fcmToken": UserDefaults.standard.string(forKey: "fcmTokenNow") ?? ""
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                }
        }
        UserDefaults.standard.set(true, forKey: "alreadyPost")
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
            guard let metadata = metadata else {
                // Uh-oh, an error occurred!
                return
            }
            // Metadata contains file metadata such as size, content-type.
            let size = metadata.size
            // You can also access to download URL after upload.
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                createReals(urlVideo: url?.description ?? "", videoPath: "videoReals/\(year)/\(month)/\(day)/\(String(describing: firebaseAuth.currentUser!.uid))-\(hour)-\(minute)-\(seconds).mp4")
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
            UserDefaults.standard.set(Date.now, forKey: "dateFromLastPosts")
            completionHandler(true)
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as? NSError {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    // File doesn't exist
                    completionHandler(false)
                    break
                case .unauthorized:
                    // User doesn't have permission to access file
                    completionHandler(false)
                    break
                case .cancelled:
                    // User canceled the upload
                    completionHandler(false)
                    break
                    
                    /* ... */
                    
                case .unknown:
                    // Unknown error occurred, inspect the server response
                    completionHandler(false)
                    break
                default:
                    // A separate error occurred. This is a good place to retry the upload.
                    completionHandler(false)
                    break
                }
            }
        }
    }
    
    func deleteVideo(videoPath: String, documentId: String, completionHandler: @escaping (Bool) -> Void ) {
        let storageRef = Storage.storage().reference()
        
        let desertRef = storageRef.child(videoPath)
        
        // Delete the file
        desertRef.delete { error in
            if let error = error {
                UserDefaults.standard.set(false, forKey: "alreadyPost")
                completionHandler(false)
            } else {
                // File deleted successfully
            }
        }
        db.collection("posts").document(documentId).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
                completionHandler(false)
            } else {
                print("Document successfully removed!")
            }
        }
        completionHandler(true)
    }
    
    func getAllRequestFriend(completionHandler: @escaping ([FriendRequest]) -> Void) {
        
        var allFriendsRequests: [FriendRequest] = []
        
        db.collection("users").document(firebaseAuth.currentUser!.uid).collection("friendsRequest")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        
                        let data = document.data()
                        
                        if let username = data["username"] as? String {
                            
                            let friendRequest = FriendRequest(username: username, requestId: document.documentID)
                            
                            allFriendsRequests.append(friendRequest)
                            print(allFriendsRequests)
                        }
                    }
                    completionHandler(allFriendsRequests)
                }
            }
    }
    
    func getIdByUser(username: String, completionHandler: @escaping (String) -> Void) {
        
        var ownerIDReceiver: String = ""
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    print(document.documentID)
                    if document.data()["username"] as? String == username {
                        ownerIDReceiver = document.documentID
                    }
                }
            }
            completionHandler(ownerIDReceiver)
        }
    }
    
    func getUserByEmail(email: String, completionHandler: @escaping (String) -> Void) {
        
        var ownerUsernameReceiver: String = ""
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    print(document.data()["username"] ?? "")
                    if document.data()["email"] as? String == email {
                        ownerUsernameReceiver = document.data()["username"] as! String
                    }
                    
                }
            }
            completionHandler(ownerUsernameReceiver)
        }
    }
    
    func uploadToDrive() {
        URLSession.shared.dataTask(with: URL(string: "https://www.googleapis.com/upload/drive/v3/files?uploadType=media")!) { data, response, error in
            guard let data = data else {
                print("nao foi possivel decodificar os dados")
                
                return
            }
            print("dentro do metodo de upload ")
            print(data)
        }
    }
    
    func getDateChange() {
        
        db.collection("dateChange")
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let data = document.data()
                        
                        if let dateChange = data["dateChange"] as? Int {
                            if dateChange != UserDefaults.standard.integer(forKey: "dateChange") {
                                UserDefaults.standard.set(dateChange, forKey: "dateChange")
                                UserDefaults.standard.set(false, forKey: "alreadyPost")
                            } else {
                                
                            }
                        }
                    }
                }
                
                
            }
        
    }
    
}
