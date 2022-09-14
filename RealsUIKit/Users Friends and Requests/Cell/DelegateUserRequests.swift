//
//  DelegateUserRequests.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 14/09/22.
//

import Foundation

protocol DelegateUserRequests: AnyObject {
    func removeFriend(usernameToRemove: String)
    
    func addFriend(usernameToAdd: String)
    
    func acceptFriendRequest()
}
