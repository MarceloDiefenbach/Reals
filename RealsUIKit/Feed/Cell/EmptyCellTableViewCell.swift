//
//  EmptyCellTableViewCell.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 17/09/22.
//

import UIKit

class EmptyCellTableViewCell: UITableViewCell {

    @IBOutlet weak var captureVideoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupLoginButton(button: captureVideoButton)
    }
    
    func setupLoginButton(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height/2
        button.backgroundColor = UIColor(named: "primary")
    }
}
