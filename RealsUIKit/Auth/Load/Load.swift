//
//  Load.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 27/09/22.
//

import Foundation
import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import UXCam
import CoreData

class Load: UIViewController {
    
    let firebaseAuth = Auth.auth()
    var service = ServiceFirebase()
    var serviceSocial = ServiceSocial()
    let configuration = UXCamConfiguration(appKey: "p4qehcg4jthkb5g")
    
    let captionReactionObserver = CaptionReactionObserver()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        verifyIfAlreadyDeleteCoreData()
        
        UXCam.optIntoSchematicRecordings()
        UXCam.start(with: configuration)
        
        if firebaseAuth.currentUser?.email != nil {
            
            serviceSocial.verifyIfHaveUsername(uid: firebaseAuth.currentUser?.uid ?? "", completionHandler: { (response) in
                if response {
                    AppCoordinator.shared.changeToRootViewController(atStoryboard: "Feed")
                } else {
                    AppCoordinator.shared.changeToRootViewController(atStoryboard: "SetUsername")
                }
            })
        } else {
            AppCoordinator.shared.changeToRootViewController(atStoryboard: "Main")
        }
        service.getDateChange()
    }
    
}

//delete on CoreData
extension Load {
    
    func deleteCoreData() {
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
    
    
    func verifyIfAlreadyDeleteCoreData() {
        
        let date = Date()
        let calendar = Calendar.current
        let day = calendar.component(.day, from: date)
        
        if !UserDefaults.standard.bool(forKey: "alreadyPost") {
            if day != UserDefaults.standard.integer(forKey: "CoreDataDateDelete") {
                UserDefaults.standard.set(day, forKey: "CoreDataDateDelete")
                deleteCoreData()
                print("delete")
            } else {
                UserDefaults.standard.set(day, forKey: "CoreDataDateDelete")
            }
                
        }
    }
}
