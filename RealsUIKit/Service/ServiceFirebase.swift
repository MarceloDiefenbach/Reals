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
import CoreData

struct FriendRequest {
    let username: String
    let requestId: String
}

struct ServiceFirebase {
    
    var serviceSocial = ServiceSocial()
    
    let db = Firestore.firestore()
    let firebaseAuth = Auth.auth()
    
    func getFriendsReals(completionHandler: @escaping ([Post]) -> Void) {
        
        var posts: [Post] = []
        var reactions: [Reaction] = []
        
        var friendsUsername: [String] = []
        
        serviceSocial.getUsers(usersType: GetUsersType.following, completionHandler: { (friends) in
            
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
                            
                            db.collection("posts").document(doc.documentID).collection("reactions").getDocuments() { (querySnapshot, err) in
                                if let err = err {
                                    print("Error getting documents: \(err)")
                                } else {
                                    if let snapshotDocumentos = querySnapshot?.documents {
                                        for doc in snapshotDocumentos {
                                            let dataReaction = doc.data()
                                            if let username = dataReaction["username"] as? String,
                                               let image = dataReaction["video"] as? String,
                                               let userId = dataReaction["userID"] as? String {
                                                
                                                reactions.append(Reaction(username: username, reactionUrl: image, userId: userId))
                                            }
                                        }
                                    }
                                }
                                if let title = data["title"] as? String,
                                   let ownerId = data["ownerId"] as? String,
                                   let photo = data["photo"] as? String,
                                   let ownerUsername = data["ownerUsername"] as? String,
                                   let videoPath = data["videoPath"] as? String,
                                   let date = data["date"] as? Int {
                                    
                                    let post = Post(ownerId: ownerId, ownerUsername: ownerUsername, photo: photo, title: title, postUid: doc.documentID, videoPath: videoPath, date: date, reactions: reactions)
                                    
                                    if friendsUsername.contains(where: {$0 == ownerUsername}) {
                                        posts.append(post)
                                    }
                                    
                                    if ownerUsername == UserDefaults.standard.string(forKey: "username") {
                                        UserDefaults.standard.set(true, forKey: "alreadyPost")
                                    }
                                }
                                reactions = []
                                completionHandler(posts)
                            }
                        }
                    }
                }
            }
        })
    }
    
    func uploadReactions(post: Post, urlVideo: URL, completionHandler: @escaping (Bool) -> Void) {
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = format.string(from: date)
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        let storageRef = Storage.storage().reference()
        
        let riversRef = storageRef.child("reactions/\(year)-\(month)-\(day)/\(post.postUid)/\(String(describing: firebaseAuth.currentUser!.uid))/\(year)/\(month)/\(day)/\(hour)-\(minute)-\(seconds).mp4")
        
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
                saveReactionsOnPost(postId: post.postUid, urlVideo: url?.description ?? "", videoPath: "reactions/\(post.postUid)/\(String(describing: firebaseAuth.currentUser!.uid))/\(year)/\(month)/\(day)/\(hour)-\(minute)-\(seconds).mp4")
            }
        }
    
        uploadTask.observe(.resume) { snapshot in
        }
        
        uploadTask.observe(.pause) { snapshot in
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
            / Double(snapshot.progress!.totalUnitCount)
        }
        
        uploadTask.observe(.success) { snapshot in
            //return true to continue flow
            completionHandler(true)
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as? NSError {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    completionHandler(false)
                    break
                case .unauthorized:
                    completionHandler(false)
                    break
                case .cancelled:
                    completionHandler(false)
                    break
                case .unknown:
                    completionHandler(false)
                    break
                default:
                    completionHandler(false)
                    break
                }
            }
        }
    }
    
    func saveReactionsOnPost(postId: String, urlVideo: String, videoPath: String){
        
        let username = UserDefaults.standard.string(forKey: "username")
        
        db.collection("posts").document(postId).collection("reactions").document(username ?? "").setData(
            [
                "userID": firebaseAuth.currentUser?.uid ?? "",
                "username": UserDefaults.standard.string(forKey: "username") ?? "",
                "video": urlVideo,
                "videoPath": videoPath
            ], merge: true) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with")
                }
        }
    }
    
    
//    func deleteVideosOfCoreData() {
//        do {
//            let videos = try persistentContainer.viewContext.fetch(RealsVideoClass.fetchRequest())
//            let formatted = videos.map {"\t\($0)"}.joined(separator: "\n")
//            
//            for video in videos {
//                persistentContainer.viewContext.delete(video)
//            }
//            getVideos()
//        } catch {
//            fatalError("erro ao pegar os videos")
//        }
//    }
//    
//    func getVideos() {
//        do {
//            let videos = try persistentContainer.viewContext.fetch(RealsVideoClass.fetchRequest())
//            let formatted = videos.map {"\t\($0)"}.joined(separator: "\n")
//            
//        } catch {
//            fatalError("erro ao pegar os videos")
//        }
//    }
    
    func verifyIsExist(username: String, completionHandler: @escaping (Bool) -> Void) {
        
        var exist: Bool = false
        
        db.collection("users").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {

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
    
    func createReals(subtitle: String, urlVideo: String, videoPath: String){
        
        var refUser: DocumentReference? = nil
        refUser = db.collection("users").document(firebaseAuth.currentUser?.uid ?? "").collection("posts").addDocument(data:
            [
                "ownerId": firebaseAuth.currentUser?.uid ?? "",
                "ownerUsername": UserDefaults.standard.string(forKey: "username") ?? "",
                "photo": urlVideo,
                "title": subtitle,
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
                "title": subtitle,
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
    
    func uploadVideo(subtitle: String, urlVideo: URL, completionHandler: @escaping (Bool) -> Void) {
        
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedDate = format.string(from: date)
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        let hour = calendar.component(.hour, from: date)
        let minute = calendar.component(.minute, from: date)
        let seconds = calendar.component(.second, from: date)
        
        let storageRef = Storage.storage().reference()
        
        let riversRef = storageRef.child("videoReals/\(year)/\(month)/\(day)/\(String(describing: firebaseAuth.currentUser!.uid))-\(hour)-\(minute)-\(seconds).mp4")
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"
        
        
        let uploadTask = riversRef.putFile(from: urlVideo, metadata: metadata) { metadata, error in
            guard let metadata = metadata else {
                return
            }
            let size = metadata.size
            riversRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                createReals(subtitle: subtitle, urlVideo: url?.description ?? "", videoPath: "videoReals/\(year)/\(month)/\(day)/\(String(describing: firebaseAuth.currentUser!.uid))-\(hour)-\(minute)-\(seconds).mp4")
            }
        }
        
        uploadTask.observe(.resume) { snapshot in
        }
        
        uploadTask.observe(.pause) { snapshot in
        }
        
        uploadTask.observe(.progress) { snapshot in
            let percentComplete = 100.0 * Double(snapshot.progress!.completedUnitCount)
            / Double(snapshot.progress!.totalUnitCount)
            
        }
        
        uploadTask.observe(.success) { snapshot in
            UserDefaults.standard.set(Date.now, forKey: "dateFromLastPosts")
            completionHandler(true)
            
        }
        
        uploadTask.observe(.failure) { snapshot in
            if let error = snapshot.error as? NSError {
                switch (StorageErrorCode(rawValue: error.code)!) {
                case .objectNotFound:
                    completionHandler(false)
                    break
                case .unauthorized:
                    completionHandler(false)
                    break
                case .cancelled:
                    completionHandler(false)
                    break
                case .unknown:
                    completionHandler(false)
                    break
                default:
                    completionHandler(false)
                    break
                }
            }
        }
    }
    
    func deleteVideo(videoPath: String, documentId: String, completionHandler: @escaping (Bool) -> Void ) {
        let storageRef = Storage.storage().reference()
        
        let desertRef = storageRef.child(videoPath)
        

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
                    if document.data()["email"] as? String == email {
                        ownerUsernameReceiver = document.data()["username"] as! String
                    }
                    
                }
            }
            completionHandler(ownerUsernameReceiver)
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
                                deleteYesterdayReals()
                                UserDefaults.standard.set(dateChange, forKey: "dateChange")
                                UserDefaults.standard.set(false, forKey: "alreadyPost")
                            } else {
                                
                            }
                        }
                    }
                }
            }
        }
    
    func deleteYesterdayReals() {
        
        guard let folderURL = URL.createFolder(folderName: "StoredVideos") else {
            print("Can't create url")
            return
        }
        
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: folderURL)
        } catch {
            print("Could not clear temp folder: \(error)")
        }
        
    }
    
    func uploadPhotoIMGBB() {
        
        let key = "b8e89775998ecfc7a202366d8e29c36c"
        let urlString = "https://api.imgbb.com/1/upload?key=\(key)"
        let url = NSURL(string: urlString)!
        
        let image = UIImage(named: "splash")!
        let imageData: Data = image.pngData()!

        let strBase64 = imageData.base64EncodedString(options: .lineLength64Characters)
        let paramString: [String : Any] = [
            "image" : strBase64
        ]
        
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: paramString)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
            do {
                if let jsonData = data {
                    if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
                        NSLog("Received data:\n\(jsonDataDict))")
                    }
                }
            } catch let err as NSError {
                print(err.debugDescription)
            }
        }
        task.resume()
        
    }
    
}
