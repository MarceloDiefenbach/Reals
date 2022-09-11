import UIKit
import AVFoundation

protocol MyCustomCellDelegator: AnyObject {
    func callSegueFromCell(ownerUsername: String, postUid: String, ownerId: String, photo: String)
}

class VideoCellTableViewCell: UITableViewCell {

    // I have put the avplayer layer on this view
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    var delegate: MyCustomCellDelegator!
    
    var post: Post?

    //MARK: - outlets
    
    @IBOutlet weak var videoPlayerSuperView: UIView!
    @IBOutlet weak var blackMaskImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    //MARK: - actions
    
    @IBAction func reportButton(_ sender: Any) {
        if(self.delegate != nil){ //Just to be safe.
            self.delegate.callSegueFromCell(ownerUsername: post?.ownerUsername ?? "", postUid: post?.postUid ?? "", ownerId: post?.ownerId ?? "", photo: post?.photo ?? "")
        }
    }
    
    //MARK: - functions
    
    //This will be called everytime a new value is set on the videoplayer item
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            /*
             If needed, configure player item here before associating it with a player.
             (example: adding outputs, setting text style rules, selecting media options)
             */
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        //Setup you avplayer while the cell is created
        self.setupMoviePlayer()
        
        blackMaskImage.layer.cornerRadius = 16
    }

    func setupMoviePlayer(){
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        avPlayerLayer?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width*0.9, height: UIScreen.main.bounds.width*1.6)
        
        avPlayer?.isMuted = true
        avPlayer?.actionAtItemEnd = .none

        self.backgroundColor = .clear
        self.videoPlayerSuperView.layer.insertSublayer(avPlayerLayer!, at: 0)
        self.videoPlayerSuperView.layer.cornerRadius = 16

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
