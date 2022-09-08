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
    
}
