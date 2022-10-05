//
//  NotificationServer.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 04/10/22.
//

import Foundation

struct NotificationService {
    
    private let notificationCenter = NotificationCenter.default
    
    func postNotification(withName name: Notification.Name, andObject object: Any? = nil) {
        notificationCenter.post(name: name, object: object)
    }
    
}
