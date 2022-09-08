//
//  PostTableViewCell.swift
//  reals
//
//  Created by Marcelo Diefenbach on 04/09/22.
//

import UIKit
import AVFoundation

class PostTableViewCell: UITableViewCell {
    
    var imageURL: String?

    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet var containerView: PlayerView!
    var imageView2: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        postImage.loadFrom(URLAddress: imageURL ?? "https://img.freepik.com/fotos-gratis/tiro-medio-homem-tirando-fotos_23-2148503539.jpg")
        
        postImage.layer.cornerRadius = 8

    }
}

extension UIImageView {
    func loadFrom(URLAddress: String) {
        guard let url = URL(string: URLAddress) else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            if let imageData = try? Data(contentsOf: url) {
                if let loadedImage = UIImage(data: imageData) {
                        self?.image = loadedImage
                }
            }
        }
    }
}

