//
//  ReportViewController.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 10/09/22.
//

import Foundation
import UIKit

class ReportViewController: UIViewController {

    var ownerUsernameVar: String?
    var ownerIdVar: String?
    var postUidVar: String?
    
    @IBOutlet weak var ownerUsername: UILabel!
    @IBOutlet weak var postUid: UILabel!
    
    @IBAction func onlyReport(_ sender: Any) {
        
        let alert = UIAlertController(title: "Denuncia recebida", message: "Vamos analisar em até 24 horas e se necessário interviremos na publicação", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
        
            let viewController = UIApplication.shared.windows.filter { $0.isKeyWindow }.first!.rootViewController
            viewController?.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func reportAndBlock(_ sender: Any) {
        let alert = UIAlertController(title: "Denuncia recebida", message: "Vamos analisar em até 24 horas e se necessário interviremos na publicação", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
        
            let viewController = UIApplication.shared.windows.filter { $0.isKeyWindow }.first!.rootViewController
            viewController?.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        
        ownerUsername.text = ownerUsernameVar
        postUid.text = postUidVar
        
    }
    
}
