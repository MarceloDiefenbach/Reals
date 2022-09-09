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

struct Post {
    let title: String
    let owner: String
    let photo: String
}

struct ServiceFirebase {
    
    func getAllPost(completionHandler: @escaping ([Post]) -> Void) {

        var posts: [Post] = []

        let db = Firestore.firestore()

        db.collection("posts").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {

                if let snapshotDocumentos = querySnapshot?.documents {
                    for doc in snapshotDocumentos {

                        let data = doc.data()
                        
                        if let title = data["title"] as? String, let owner = data["ownerId"] as? String, let photo = data["photo"] as? String {

                            let post = Post(title: title, owner: owner, photo: photo)

                            posts.append(post)
                            print(post)
                        }
                    }
                    completionHandler(posts)
                }
            }
        }
    }
    
    func getImageFromString (urlString: String, completionHandler: @escaping (UIImage) -> Void) {
        guard let url = URL(string: urlString) else {return}

        DispatchQueue.global(qos: .background).async {
            guard let image = try? Data(contentsOf: url) else { return }
            DispatchQueue.main.async {
                completionHandler(UIImage(data: image)!)
            }
        }

    }
    
    func uploadVideo(urlVideo: URL) {
        
        let storageRef = Storage.storage().reference()
        
        // Local file you want to upload
        let localFile = urlVideo

        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "video/mp4"

        // Upload file and metadata to the object 'images/mountains.jpg'
        let uploadTask = storageRef.putFile(from: localFile, metadata: metadata)

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
}
