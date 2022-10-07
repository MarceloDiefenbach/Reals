//
//  ReactionsTableViewCell.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 01/10/22.
//

import UIKit
import AVFoundation

class ReactionsTableViewCell: UITableViewCell {
    
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    @IBOutlet weak var videoPlayerSuperView: UIView!
    @IBOutlet weak var reactionsBG: UIView!
    
    let corner = 5.0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setupMoviePlayer()
        reactionsBG.layer.cornerRadius = reactionsBG.bounds.height/corner
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2))
    }
    
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            /*
             If needed, configure player item here before associating it with a player.
             (example: adding outputs, setting text style rules, selecting media options)
             */
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }
    
    func setupMoviePlayer(){
        
        videoPlayerSuperView.layer.cornerRadius = videoPlayerSuperView.bounds.height/corner
        
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avPlayerLayer?.masksToBounds = true
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
           } catch {
                print(error)
           }
        
        avPlayerLayer?.frame = CGRect(x: 0, y: 0, width: videoPlayerSuperView.bounds.width, height: videoPlayerSuperView.bounds.height)
        
        avPlayer?.isMuted = true
        avPlayer?.actionAtItemEnd = .none

        self.backgroundColor = .clear
        self.videoPlayerSuperView.layer.insertSublayer(avPlayerLayer!, at: 0)
        self.videoPlayerSuperView.layer.cornerRadius = self.videoPlayerSuperView.bounds.height/corner

        // This notification is fired when the video ends, you can handle it in the method.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer?.currentItem)
    }

    func stopPlayback(){
        self.avPlayer?.pause()
    }

    func startPlayback(){
        self.avPlayer?.play()
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        if let playerItem = notification.object as? AVPlayerItem {
            playerItem.seek(to: CMTime.zero, completionHandler: nil)
        }
    }
}
