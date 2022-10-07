//
//  CaptionReactionObserver.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 04/10/22.
//

import Foundation

protocol CaptionReactionObserverDelegate: AnyObject {
    func didFinishUploadingReaction()
}

class CaptionReactionObserver {
    
    weak var delegate: CaptionReactionObserverDelegate?
    
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveDidFinishUploadingReaction), name: CaptureReactionNotificationType.didFinishUploadingReaction.name, object: nil)
    }
    
    @objc func didReceiveDidFinishUploadingReaction() {
        delegate?.didFinishUploadingReaction()
    }

}
