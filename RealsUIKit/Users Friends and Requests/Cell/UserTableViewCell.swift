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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func addFriendButton(_ sender: Any) {
        if control {
            delegate.followSomeone(usernameToFollow: nameLabel.text ?? "")
            control = false
        }
    }
    
}
