//
//  UIApplication+Extension.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 27/09/22.
//

import UIKit

extension UIApplication {
    var currentWindow: UIWindow? {
        connectedScenes
        .map({$0 as? UIWindowScene})
        .compactMap({$0})
        .first?.windows
        .filter({$0.isKeyWindow}).first
    }
}
