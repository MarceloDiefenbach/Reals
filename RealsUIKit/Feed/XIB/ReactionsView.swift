//
//  ReactionsView.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 01/10/22.
//

import UIKit

class ReactionsView: UIView {
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var recordButton: UIButton!
    var delegate: MyCustomCellDelegator?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("ReactionsView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        setupPrimaryButton(button: recordButton)
    }
    
    @IBAction func createReals(_ sender: Any) {
        //TODO: - here we need to go to capture video as modal
        AppCoordinator.shared.changeToRootViewController(atStoryboard: "CaptureVideo")
    }
    
    func setupPrimaryButton(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height/2
        button.backgroundColor = UIColor(named: "primary")
        button.titleLabel?.tintColor = UIColor.black
    }

}
