import UIKit
import AVFoundation

protocol MyCustomCellDelegator: AnyObject {
    func callSegueFromCell(ownerUsername: String, postUid: String, ownerId: String, photo: String)
    
    func createReals()
    
    func deletePost(videoPath: String, documentId: String)
}

class VideoCellTableViewCell: UITableViewCell {

    // I have put the avplayer layer on this view
    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    var delegate: MyCustomCellDelegator!
    @IBOutlet weak var opacityLayer: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var service = ServiceFirebase()
    
    var post: Post!

    //MARK: - outlets
    
    @IBOutlet weak var videoPlayerSuperView: UIView!
    @IBOutlet weak var blackMaskImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var createRealsButton: UIButton!
    @IBOutlet weak var stackAlreadyDontPostToday: UIStackView!
    @IBOutlet weak var reportDeleteIcon: UIImageView!
    
    //MARK: - actions
    
    @IBAction func createReals(_ sender: Any) {
        self.delegate.createReals()
    }
    
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
    
        //padrão pra organizar a célula
    func configureDiefenbach() {
        // Data Source
        
        // Layout
    }
    
    func setupReportDeleteButton(post: Post) {
        self.post = post
        
        if post.ownerUsername == UserDefaults.standard.string(forKey: "username") {
            let imageIcon = UIImage(systemName: "trash")
            reportDeleteIcon.image = imageIcon
        } else {
            let imageIcon = UIImage(systemName: "exclamationmark.triangle")
            reportDeleteIcon.image = imageIcon
        }
        setReportDeleteButton()
    }
    
    func setReportDeleteButton() {
        
        let tapStartButton = UITapGestureRecognizer(target: self, action: #selector(self.reportDeleteButton))
            reportDeleteIcon.addGestureRecognizer(tapStartButton)
            reportDeleteIcon.isUserInteractionEnabled = true
    }

    @objc func reportDeleteButton(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if post?.ownerUsername == UserDefaults.standard.string(forKey: "username") {
                self.delegate.deletePost(videoPath: post.videoPath, documentId: post.postUid)
            } else {
                if(self.delegate != nil){ //Just to be safe.
                    self.delegate.callSegueFromCell(ownerUsername: post?.ownerUsername ?? "", postUid: post?.postUid ?? "", ownerId: post?.ownerId ?? "", photo: post?.photo ?? "")
                }
            }
        }
    }
    
    func verifyIfAlreadyPostToday() {

        if UserDefaults.standard.bool(forKey: "alreadyPost") {
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
