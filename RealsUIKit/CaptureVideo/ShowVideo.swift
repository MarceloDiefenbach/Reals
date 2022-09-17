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
    var videoURL: URL!
    var videoSize: Double?
    var videoData: Data?
    var serviceUpload = ServiceUploadPanda()
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
//        serviceUpload.uploadPandaVideo(videoData: videoData ?? Data.init(), videoSize: (videoSize != nil), urlVideo: videoURL) { (response) in
//            let viewController = UIApplication.shared.windows.filter { $0.isKeyWindow }.first!.rootViewController
//            viewController?.dismiss(animated: true, completion: nil)
//        }
        service.uploadVideo(urlVideo: videoURL, completionHandler: { (uploadFinish) in
            // esse codigo pega a ultima rootViewController do contexto e fecha tudo que ta aberto por cima
            let viewController = UIApplication.shared.windows.filter { $0.isKeyWindow }.first!.rootViewController
            viewController?.dismiss(animated: true, completion: nil)
            self.loadingBackground.isHidden = true
            self.loadingBackground.isHidden = true
        })
    }
}
