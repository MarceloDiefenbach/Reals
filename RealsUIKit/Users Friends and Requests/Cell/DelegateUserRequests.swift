//
//  DelegateUserRequests.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 14/09/22.
//

import Foundation

protocol DelegateUserRequests: AnyObject {
    func unfollowSomeone(usernameToUnfollow: User)
    
    func followSomeone(usernameToFollow: User)
}
