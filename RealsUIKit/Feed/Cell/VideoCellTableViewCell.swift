import UIKit
import AVFoundation
import CoreData

protocol MyCustomCellDelegator: AnyObject {
    func callSegueFromCell(ownerUsername: String, postUid: String, ownerId: String, photo: String)
    
    func createReals()
    
    func deletePost(videoPath: String, documentId: String)
    
    func captureReactions(index: Int)
}

class VideoCellTableViewCell: UITableViewCell {
    
    let coreDataQueue = DispatchQueue(label: "CoreDataQueue", qos: .utility, attributes: [.concurrent], autoreleaseFrequency: .workItem)

    var avPlayer: AVPlayer?
    var avPlayerLayer: AVPlayerLayer?
    var paused: Bool = false
    var delegate: MyCustomCellDelegator!
    @IBOutlet weak var opacityLayer: ReactionsView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var service = ServiceFirebase()
    @IBOutlet weak var reactionsTableView: UITableView!
    var savedVideosURL: [String] = []
    var index: Int?
    var coreDataService = CoreDataService()
    var videos: [String: Data] = ["nil": Data.init()]
    
    
    //MARK: - Reactions
    var post: Post! {
        didSet {
            reactionsTableView.reloadData()
        }
    }

    //MARK: - outlets
    @IBOutlet weak var videoPlayerSuperView: UIView!
    @IBOutlet weak var blackMaskImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var reportDeleteIcon: UIImageView!
    @IBOutlet weak var captureReactionButton: UIImageView!
    
    var videoPlayerItem: AVPlayerItem? = nil {
        didSet {
            avPlayer?.replaceCurrentItem(with: self.videoPlayerItem)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        //Setup you avplayer while the cell is created
        self.setupMoviePlayer()

        blackMaskImage.layer.cornerRadius = 0
        activityIndicator.startAnimating()
        
        verifyIfAlreadyPostToday()
        opacityLayer.delegate = delegate
        
        reactionsTableView.delegate = self
        reactionsTableView.dataSource = self
        reactionsTableView.backgroundView = nil
        reactionsTableView.backgroundColor = UIColor.clear
        
        setCaptureReaction()
    }
    
    func setupLoginButton(button: UIButton) {
        button.layer.cornerRadius = button.bounds.height/2
        button.backgroundColor = UIColor(named: "primary")
    }
    
    func setupReportDeleteButton(post: Post) {
        self.post = post
        
        if post.ownerUsername == UserDefaults.standard.string(forKey: "username") {
            let imageIcon = UIImage(systemName: "trash.fill")
            reportDeleteIcon.image = imageIcon
//            captureReactionButton.isHidden = true
        } else {
            let imageIcon = UIImage(systemName: "exclamationmark.triangle.fill")
            reportDeleteIcon.image = imageIcon
        }
        setReportDeleteButton()
    }
    
    func setCaptureReaction() {
        let tapCaptureReaction = UITapGestureRecognizer(target: self, action: #selector(self.captureReactionButtonAction))
        captureReactionButton.isUserInteractionEnabled = true
        captureReactionButton.addGestureRecognizer(tapCaptureReaction)
    }

    @objc func captureReactionButtonAction(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            self.delegate.captureReactions(index: self.index ?? 0)
        }
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
        } else {
            opacityLayer.layer.opacity = 0.95
        }
    }

    func setupMoviePlayer(){
        self.avPlayer = AVPlayer.init(playerItem: self.videoPlayerItem)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
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
        self.videoPlayerSuperView.layer.cornerRadius = 0

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

extension VideoCellTableViewCell:  UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return post.reactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.reactionsTableView.dequeueReusableCell(withIdentifier: "reactionsCell") as! ReactionsTableViewCell
        cell.backgroundColor = UIColor.clear
            
        if let video = videos[self.post.reactions[indexPath.row].reactionUrl] {
            print("j?? ta salvo")
            let videoAsset: AVAsset = video.getAVAsset()
            cell.videoPlayerItem = AVPlayerItem.init(asset: videoAsset)
            
        } else {
            if let videoData: Data = self.getVideoOfCell(videoURL: self.post.reactions[indexPath.row].reactionUrl) as? Data {
                coreDataQueue.async {
                    let videoAsset: AVAsset = videoData.getAVAsset()
                    cell.videoPlayerItem = AVPlayerItem.init(asset: videoAsset)
                    self.videos["\(self.post.reactions[indexPath.row].reactionUrl)"] = videoData
                    print(self.videos)
                }
            } else {
                coreDataQueue.async {
                    do {
                        self.coreDataService.saveDataCoreData(videoUrl: self.post.reactions[indexPath.row].reactionUrl)
                        let videoData = try Data(contentsOf: URL(string: self.post.reactions[indexPath.row].reactionUrl)!)
                        let videoAsset: AVAsset = videoData.getAVAsset()
                        cell.videoPlayerItem = AVPlayerItem.init(asset: videoAsset)
                        
                    } catch {
                        fatalError("error playing video directly of firebase: \(#function)")
                    }
                }
                
            }
            
        }
        playVideoOnTheCell(cell: cell, indexPath: indexPath)
        return cell
    }
    
    func playVideoOnTheCell(cell : ReactionsTableViewCell, indexPath : IndexPath){
        cell.startPlayback()
    }
    
    func stopPlayBack(cell : ReactionsTableViewCell, indexPath : IndexPath){
        cell.stopPlayback()
    }
    
}

//MARK: - get video of CoreData
extension VideoCellTableViewCell {
    func getVideoOfCell(videoURL: String) -> Any {
        do {
            let folderURL = URL.createFolder(folderName: "StoredVideos")
            
            var invalidCharacters = CharacterSet(charactersIn: ":/")
            invalidCharacters.formUnion(.newlines)
            invalidCharacters.formUnion(.illegalCharacters)
            invalidCharacters.formUnion(.controlCharacters)

            let newFilename = videoURL
                .components(separatedBy: invalidCharacters)
                .joined(separator: "")
            
            let permanentFileURL = folderURL?.appendingPathComponent(newFilename).appendingPathExtension("mp4")
            let videoData = try Data(contentsOf: permanentFileURL!)
            return videoData
        } catch {
            return ""
        }
    }
}
