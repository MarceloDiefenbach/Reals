//
//  UserTableViewCell.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 11/09/22.
//

import UIKit

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    var delegate: DelegateUserRequests!
    var control: Bool = true
    var user: User?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUser(user: User) {
        self.user = user
    }
    
    @IBAction func addFriendButton(_ sender: Any) {
        if control {
            delegate.followSomeone(usernameToFollow: user!)
            control = false
        }
    }
    
}
