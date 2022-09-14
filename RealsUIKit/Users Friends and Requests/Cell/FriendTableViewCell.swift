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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func addFriendButton(_ sender: Any) {
        delegate.removeFriend(usernameToRemove: nameLabel.text ?? "")
    }

}
