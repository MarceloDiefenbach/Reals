//
//  AppCoordinator.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 27/09/22.
//

import UIKit

struct AppCoordinator {
    
    static var shared: AppCoordinator = AppCoordinator()
    
    private init() {}
    
    func changeToCurrentRoot(animated isAnimated: Bool = true) {
        let currentWindow = UIApplication.shared.currentWindow
        currentWindow?.rootViewController?.dismiss(animated: isAnimated)
    }
    
    func changeToRootViewController(atStoryboard storyboardName: String, animated isAnimated: Bool = true) {
        guard let currentWindow = UIApplication.shared.currentWindow else { fatalError("CurrentWindow is nil at \(#function)") }
        
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        let viewController = storyboard.instantiateInitialViewController()
        
        // Set the new rootViewController of the window.
        // Calling "UIView.transition" below will animate the swap.
        currentWindow.rootViewController = viewController
        
        if isAnimated {
            // A mask of options indicating how you want to perform the animations.
            let options: UIView.AnimationOptions = .transitionCrossDissolve
            
            // The duration of the transition animation, measured in seconds.
            let duration: TimeInterval = 0.3
            
            // Creates a transition animation.
            // Though `animations` is optional, the documentation tells us that it must not be nil. ¯\_(ツ)_/¯
            UIView.transition(with: currentWindow, duration: duration, options: options, animations: {}, completion:
                                { completed in
                // maybe do something on completion here
            })
        }
    }
    
}
