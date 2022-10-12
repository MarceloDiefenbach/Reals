//
//  FeedViewController.swift
//  reals
//
//  Created by Marcelo Diefenbach on 04/09/22.
//

import Foundation
import UIKit
import AVKit
import AVFoundation
import FirebaseAuth
import CoreData

class FeedViewController: UIViewController {
    
    var ownerId: String = ""
    var ownerUsername: String = ""
    var photo: String = ""
    var postUid: String = ""
    var videos: [String: Data] = ["nil": Data.init()]

    var serviceSocial = ServiceSocial()
    var service = ServiceFirebase()
    var coreDataService = CoreDataService()
    var posts: [Post] = [] {
        didSet {
            posts.sort(by: { $0.date > $1.date })
        }
    }
    let firebaseAuth = Auth.auth()
    let coreDataQueue = DispatchQueue(label: "CoreDataQueue", qos: .utility, attributes: [.concurrent], autoreleaseFrequency: .workItem)
    
    var savedVideosURL: [String] = []
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    var visibleIP : IndexPath?
    var aboutToBecomeInvisibleCell = -1
    var avPlayerLayer: AVPlayerLayer!
    var videoURLs = Array<URL>()
    var firstLoad = true
    let refreshControl = UIRefreshControl()
    var index: Int = 0
    
    let captionReactionObserver = CaptionReactionObserver()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceSocial.verifyIfFcmTokenChange()
        setupRefreshControl()
        
        captionReactionObserver.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        visibleIP = IndexPath.init(row: 0, section: 0)
        
        service.getFriendsReals { (posts) in
            self.posts = posts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        service.getUserByEmail(email: firebaseAuth.currentUser?.email ?? "", completionHandler: { (response) in
            UserDefaults.standard.set(response, forKey: "username")
        })
    }
    
    func playVideoOnTheCell(cell : VideoCellTableViewCell, indexPath : IndexPath){
        cell.startPlayback()
    }
    
    func stopPlayBack(cell : VideoCellTableViewCell, indexPath : IndexPath){
        cell.stopPlayback()
    }
    
    @IBAction func friendsButton(_ sender: Any) {
        performSegue(withIdentifier: "goToFriends", sender: nil)
    }
    
    func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    @objc func refresh(_ sender: AnyObject) {
        
        service.getFriendsReals { (posts) in
            self.posts = posts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            self.refreshControl.endRefreshing()
        }
    }
}

extension FeedViewController:  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if posts.count == 0 {
            return 1
        } else {
            return posts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if posts.count == 0 {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "emptyCell") as! EmptyCellTableViewCell
            return cell
        } else {
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoCellTableViewCell
            cell.index = indexPath.row
            
            if let video = videos[self.posts[indexPath.row].photo] {
                print("já ta salvo")
                let videoAsset: AVAsset = video.getAVAsset()
                cell.videoPlayerItem = AVPlayerItem.init(asset: videoAsset)
                
            } else {
                if let videoData: Data = self.getVideoOfCell(videoURL: self.posts[indexPath.row].photo) as? Data {
                    coreDataQueue.async {
                        let videoAsset: AVAsset = videoData.getAVAsset()
                        cell.videoPlayerItem = AVPlayerItem.init(asset: videoAsset)
                        self.videos["\(self.posts[indexPath.row].photo)"] = videoData
                        print(self.videos)
                    }
                } else {
                    coreDataQueue.async {
                        do {
                            self.coreDataService.saveDataCoreData(videoUrl: self.posts[indexPath.row].photo)
                            let videoData = try Data(contentsOf: URL(string: self.posts[indexPath.row].photo)!)
                            let videoAsset: AVAsset = videoData.getAVAsset()
                            cell.videoPlayerItem = AVPlayerItem.init(asset: videoAsset)
                            
                        } catch {
                            fatalError("error playing video directly of firebase: \(#function)")
                        }
                    }
                }
                
            }
            
            cell.titleLabel.text = posts[indexPath.row].ownerUsername
            cell.subtitleLabel.text = posts[indexPath.row].title
            cell.selectionStyle = .none
            cell.post = posts[indexPath.row]
            cell.delegate = self
            cell.setupReportDeleteButton(post: posts[indexPath.row])
            playVideoOnTheCell(cell: cell, indexPath: indexPath)
            return cell
        }
    }
}

extension FeedViewController: MyCustomCellDelegator {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCaptureReactions"{
            let destination = segue.destination as? CaptureReactions
            
            destination?.post = posts[index]
        }
        if (segue.identifier == "goToReport"){
            let displayVC = segue.destination as! ReportViewController
            
            displayVC.ownerIdVar = self.ownerId
            displayVC.ownerUsernameVar = self.ownerUsername
            displayVC.postUidVar = self.postUid
            
        }
    }
    
    func createReals() {
        self.performSegue(withIdentifier: "goToCapture", sender: nil)
    }
    
    func captureReactions(index: Int) {
        self.index = index
        self.performSegue(withIdentifier: "goToCaptureReactions", sender: nil)
    }
    
    func callSegueFromCell(ownerUsername: String, postUid: String, ownerId: String, photo: String) {
        self.ownerId = ownerId
        self.ownerUsername = ownerUsername
        self.photo = photo
        self.postUid = postUid
        performSegue(withIdentifier: "goToReport", sender: nil)
    }
    
    func deletePost(videoPath: String, documentId: String) {
        let alert = UIAlertController(title: "Apagar Real", message: "Essa ação não poderá ser desfeita!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Apagar", style: .destructive, handler: { action in
            self.service.deleteVideo(videoPath: videoPath, documentId: documentId, completionHandler: { (response) in
                self.didFinishUploadingReaction()
                AppCoordinator.shared.changeToCurrentRoot(animated: true)
            })
        }))
        alert.addAction(UIAlertAction(title: "Não apagar", style: .cancel, handler: { action in
            
            AppCoordinator.shared.changeToCurrentRoot(animated: true)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

extension Data {
    func getAVAsset() -> AVAsset {
        let directory = NSTemporaryDirectory()
        let fileName = "\(NSUUID().uuidString).mp4"
        let fullURL = NSURL.fileURL(withPathComponents: [directory, fileName])
        try! self.write(to: fullURL!)
        let asset = AVAsset(url: fullURL!)
        return asset
    }
}

//MARK: - get video of CoreData
extension FeedViewController {
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

extension FeedViewController: CaptionReactionObserverDelegate {
    
    func didFinishUploadingReaction() {
        let contentOffset = tableView.contentOffset
        service.getFriendsReals { (posts) in
            self.posts = posts
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                self.tableView.reloadData()
                self.tableView.layoutIfNeeded()
                self.tableView.setContentOffset(contentOffset, animated: false)
            }
        }
    }
    
}
