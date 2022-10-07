//
//  Admin.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 04/10/22.
//

import Foundation
import UIKit

class AdminViewController: UIViewController {
    
    var notificationService = PushNotificationSender()
    
    @IBOutlet weak var sendNotificationOutlet: UIButton!
    
    override func viewDidLoad() {
        setupPrimaryButton(button: sendNotificationOutlet)
    }
    
    @IBAction func sendNotificationAction(_ sender: Any) {
        let alert = UIAlertController(title: "Enviar notificação para todos", message: "Tem certeza que está na hora de enviar a notificação?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Enviar para todos", style: .destructive, handler: { action in
            self.notificationService.sendItsTimeNotificaion()
            AppCoordinator.shared.changeToRootViewController(atStoryboard: "Feed")
        }))
        alert.addAction(UIAlertAction(title: "Não enviar", style: .default, handler: { action in
            AppCoordinator.shared.changeToCurrentRoot(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func backToFeed(_ sender: Any) {
        AppCoordinator.shared.changeToRootViewController(atStoryboard: "Feed")
    }
}
