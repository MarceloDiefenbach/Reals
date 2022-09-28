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
    
    @IBAction func publishRealButton(_ sender: Any) {
        upload()
    }
    
    @IBAction func retakeReal(_ sender: Any) {
        self.dismiss(animated: true, completion: {})
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(videoURL)
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
        loadingBackground.isHidden = true
        loadingBackground.layer.opacity = 0.8
        
    }
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero)
        }
    }
    
    func upload(){
        loadingBackground.isHidden = false
        loadingBackground.isHidden = false

        service.uploadVideo(urlVideo: videoURL, completionHandler: { (uploadFinish) in
            AppCoordinator.shared.changeToCurrentRoot()
            self.loadingBackground.isHidden = true
            self.loadingBackground.isHidden = true
            self.sender.sendNotificationPost()
        })
    }
}
