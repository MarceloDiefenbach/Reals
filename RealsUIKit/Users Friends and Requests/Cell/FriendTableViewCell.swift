//
//  FriendTableViewCell.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 13/09/22.
//

import UIKit

class FriendTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    var delegate: DelegateUserRequests!
    var control: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func unfollowButton(_ sender: Any) {
        if control {
            delegate.unfollowSomeone(usernameToUnfollow: nameLabel.text ?? "")
            self.control = false
        }
    }

}
