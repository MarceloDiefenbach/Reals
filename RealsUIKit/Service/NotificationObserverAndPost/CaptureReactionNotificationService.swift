//
//  CaptureReactionNotificationService.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 04/10/22.
//

import Foundation

enum CaptureReactionNotificationType: String {
    case didFinishUploadingReaction
    
    var name: NSNotification.Name {
        return NSNotification.Name(rawValue)
    }
}

struct CaptureReactionNotificationService {
    
    private let notificationService = NotificationService()
    
    func postNotification(_ notificationType: CaptureReactionNotificationType, object: Any? = nil) {
        notificationService.postNotification(withName: notificationType.name, andObject: object)
    }
    
}
