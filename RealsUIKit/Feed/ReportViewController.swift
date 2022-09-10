//
//  ReportViewController.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 10/09/22.
//

import Foundation
import UIKit

class ReportViewController: UIViewController, UITextFieldDelegate {

    
    override func viewDidLoad() {


    }
    
    //close keyboard on return button
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}
