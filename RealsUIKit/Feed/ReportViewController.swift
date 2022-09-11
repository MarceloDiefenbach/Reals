//
//  ReportViewController.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 10/09/22.
//

import Foundation
import UIKit

class ReportViewController: UIViewController, UITextFieldDelegate {

    var ownerUsernameVar: String?
    var ownerIdVar: String?
    var postUidVar: String?
    
    @IBOutlet weak var ownerUsername: UILabel!
    @IBOutlet weak var postUid: UILabel!
    
    override func viewDidLoad() {
        
        ownerUsername.text = ownerUsernameVar
        postUid.text = postUidVar
        
    }
    
    //close keyboard on return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
