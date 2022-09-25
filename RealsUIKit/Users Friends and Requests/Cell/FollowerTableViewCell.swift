//
//  RequestTableViewCell.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 13/09/22.
//

import UIKit

class FollowerTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    var delegate: DelegateUserRequests!
    var user: User?

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUser(user: User) {
        self.user = user
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
