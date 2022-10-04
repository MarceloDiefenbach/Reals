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
    
    var serviceSocial = ServiceSocial()
    var ownerId: String = ""
    var ownerUsername: String = ""
    var photo: String = ""
    var postUid: String = ""
    var service = ServiceFirebase()
    var posts: [Post] = [] {
        didSet {
            print("Tem loop")
            posts.sort(by: { $0.date > $1.date })
        }
    }
    var controlQuantityPost: Int = 0
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
    
    let persistentContainer: NSPersistentContainer = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        
        return appDelegate.persistentContainer
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceSocial.verifyIfFcmTokenChange()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        service.getFriendsReals { (posts) in
            self.posts = posts
            self.controlQuantityPost = posts.count
            print(posts)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        visibleIP = IndexPath.init(row: 0, section: 0)
        
        setupRefreshControl()
        
        service.getUserByEmail(email: firebaseAuth.currentUser?.email ?? "", completionHandler: { (response) in
            UserDefaults.standard.set(response, forKey: "username")
        })
        let username = UserDefaults.standard.string(forKey: "username")
        if username == "juusdy" || username == "Chumiga™" || username == "rafaelruwer" || username == "PohMarcelo" || username == "Nico" || username == "Prolene" {
            createButton.isEnabled = true
        } else {
            createButton.isEnabled = false
            createButton.tintColor = .clear
        }
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
            if self.controlQuantityPost != posts.count {
                self.posts = posts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
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
            if let videoData: Data = getVideoOfCell(videoURL: posts[indexPath.row].photo) as? Data {
                let videoAsset: AVAsset = videoData.getAVAsset()
                cell.videoPlayerItem = AVPlayerItem.init(asset: videoAsset)
            } else {
                cell.videoPlayerItem = AVPlayerItem.init(url: URL(string: posts[indexPath.row].photo)!)
                
                coreDataQueue.async {
                    do {
                        let realsVideoClassFetchRequest = RealsVideoClass.fetchRequest()
                        let predicate = NSPredicate(format: "videoUrl == '\(self.posts[indexPath.row].photo)'")
                        realsVideoClassFetchRequest.predicate = predicate
                        
                        let videos = try self.persistentContainer.viewContext.fetch(realsVideoClassFetchRequest)
                        let formatted = videos.map {"\($0)"}.joined(separator: "\n")
                        print(formatted)
                        if formatted == "" {
                            let data = try? Data.init(contentsOf: URL(string: self.posts[indexPath.row].photo)!)
                            let videoURL = self.posts[indexPath.row].photo
                            if let data = data, !self.savedVideosURL.contains(videoURL) {
                                self.savedVideosURL.append(videoURL)
                                self.saveDataCoreData(videoData: data, videoURL: videoURL)
                            }
                        }
                    } catch {
                        fatalError()
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
    
    func saveDataCoreData(videoData: Data, videoURL: String) {
        let reals = RealsVideoClass(context: persistentContainer.viewContext)
        
        reals.videoData = videoData
        reals.videoUrl = videoURL
        reals.date = Date.now
        
        do {
            try persistentContainer.viewContext.save()
        } catch {
            fatalError("deu erro")
        }
    }
    
    func reload(tableView: UITableView) {

        let contentOffset = tableView.contentOffset
        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableView.setContentOffset(contentOffset, animated: false)

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
                if response {
                    UserDefaults.standard.set(Date.now-172800, forKey: "dateFromLastPosts")
                } else {
                    //                    alerta de erro
                }
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
        let fileName = "\(NSUUID().uuidString).mov"
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
            let realsVideoClassFetchRequest = RealsVideoClass.fetchRequest()
            let predicate = NSPredicate(format: "videoUrl == '\(videoURL)'")
            realsVideoClassFetchRequest.predicate = predicate
            
            let videos = try persistentContainer.viewContext.fetch(realsVideoClassFetchRequest)
            let formatted = videos.map {"\($0)"}.joined(separator: "\n")
            
            if let video = videos.first?.videoData {
                return video
            } else {
                return ""
            }
        } catch {
            fatalError("Error when get video of CoreData \(#function)")
        }
    }
}
