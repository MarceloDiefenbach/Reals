//
//  ShowVideo.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 08/09/22.
//

import UIKit
import AVFoundation

class VideoPlayback: UIViewController {

    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var service = ServiceFirebase()
    var serviceSocial = ServiceSocial()
    var videoURL: URL!
    var videoSize: Double?
    var videoData: Data?
    let sender = PushNotificationSender()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadingBackground: UIView!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var subtitleTextField: UITextField!
    @IBOutlet weak var subtitleBG: UIView!
    @IBOutlet weak var publishButton: UIButton!
    @IBOutlet weak var constraintBottom: NSLayoutConstraint!
    @IBOutlet weak var retakeRealButton: UIButton!
    
    @IBAction func publishRealButton(_ sender: Any) {
        upload()
    }
    
    @IBAction func retakeReal(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoView.layer.insertSublayer(avPlayerLayer, at: 0)
    
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
    
        avPlayer.play()
        avPlayer.actionAtItemEnd = .none

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
        
        activityIndicator.startAnimating()
        loadingBackground.isHidden = true
        loadingBackground.layer.opacity = 0.8
        
        setupTextFieldDefault(placeholder: "Reals subtitle", textField: subtitleTextField, backgroung: subtitleBG)
        setupPrimaryButton(button: publishButton)
        subtitleTextField.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        
        retakeRealButton.layer.cornerRadius = retakeRealButton.bounds.height/2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }

    @objc func keyboardWillAppear() {
        constraintBottom.constant = UIScreen.main.bounds.height*0.4
    }

    @objc func keyboardWillDisappear() {
        constraintBottom.constant = 20
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero)
        }
    }
    
    func upload(){
        loadingBackground.isHidden = false

        service.uploadVideo(subtitle: subtitleTextField.text ?? "", urlVideo: videoURL, completionHandler: { (uploadFinish) in
            
            if uploadFinish {
                
                AppCoordinator.shared.changeToCurrentRoot()
                self.loadingBackground.isHidden = true
                self.sender.sendNotificationPost()
                
            } else {
                
                let alert = UIAlertController(title: "Reals não publicado", message: "Tivemos um erro na hora de publicar o seu Reals, tenta mais tarde.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { action in
                    AppCoordinator.shared.changeToCurrentRoot()
                }))
                self.present(alert, animated: true, completion: nil)
                
            }
        })
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= 40
    }
}
