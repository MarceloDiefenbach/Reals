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

class Load: UIViewController {
    
    let firebaseAuth = Auth.auth()
    var service = ServiceFirebase()
    var serviceSocial = ServiceSocial()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
