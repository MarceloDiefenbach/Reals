import UIKit
import AVFoundation

protocol MyCustomCellDelegator: AnyObject {
    func callSegueFromCell(ownerUsername: String, postUid: String, ownerId: String, photo: String)
    
    func createReals()
}

class VideoCellTableViewCell: UITableViewCell {

    // I have put the avplayer layer on this view
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    var delegate: MyCustomCellDelegator!
    @IBOutlet weak var opacityLayer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var post: Post?

    //MARK: - outlets
    
    @IBOutlet weak var videoPlayerSuperView: UIView!
    @IBOutlet weak var blackMaskImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var createRealsButton: UIButton!
    @IBOutlet weak var stackAlreadyDontPostToday: UIStackView!
    
    //MARK: - actions
    
    @IBAction func createReals(_ sender: Any) {
        self.delegate.createReals()
    }
    
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
        activityIndicator.startAnimating()
        
        verifyIfAlreadyPostToday()
        
    }
    
    
    func verifyIfAlreadyPostToday() {
        
        let date = Date.now
        let format = DateFormatter()
        format.dateFormat = "yyyy-MM-dd HH:mm:ss"
        _ = format.string(from: date)
        _ = Calendar.current
        let day = Calendar.current.component(.day, from: date)
        
        var lastPost: Date
        
        if let lastPostTest: Date = UserDefaults.standard.object(forKey: "dateFromLastPostss") as? Date {
            lastPost = lastPostTest
        } else {
            lastPost = Date.now-172800
        }
        
        let dayDefaults = Calendar.current.component(.day, from: lastPost)
        
        if dayDefaults == day {
            opacityLayer.layer.opacity = 0
            stackAlreadyDontPostToday.isHidden = true
        } else {
            opacityLayer.layer.opacity = 0.9
            stackAlreadyDontPostToday.isHidden = false
        }
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
