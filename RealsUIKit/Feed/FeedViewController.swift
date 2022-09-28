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

class FeedViewController: UIViewController {
    
    var serviceSocial = ServiceSocial()
    var ownerId: String = ""
    var ownerUsername: String = ""
    var photo: String = ""
    var postUid: String = ""
    var service = ServiceFirebase()
    var posts: [Post] = []
    var controlQuantityPost: Int = 0
    let firebaseAuth = Auth.auth()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var createButton: UIBarButtonItem!
    
    var visibleIP : IndexPath?
    var aboutToBecomeInvisibleCell = -1
    var avPlayerLayer: AVPlayerLayer!
    var videoURLs = Array<URL>()
    var firstLoad = true
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        serviceSocial.verifyIfFcmTokenChange()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        service.getFriendsReals { (posts) in
            self.posts = posts
            self.controlQuantityPost = posts.count
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "goToReport"){
            let displayVC = segue.destination as! ReportViewController
            
            displayVC.ownerIdVar = self.ownerId
            displayVC.ownerUsernameVar = self.ownerUsername
            displayVC.postUidVar = self.postUid
            
        }
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
            print(URL(string: posts[indexPath.row].photo))
            if let theProfileImageUrl = URL(string: posts[indexPath.row].photo) {
                do {
                    let videoData = try Data(contentsOf: theProfileImageUrl as URL)
                    print(videoData)
                } catch {
                    print("Unable to load data: \(error)")
                }
            }
            cell.videoPlayerItem = AVPlayerItem.init(url: URL(string: posts[indexPath.row].photo)!)
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
    func createReals() {
        performSegue(withIdentifier: "goToCapture", sender: nil)
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
            
            let viewController = UIApplication.shared.windows.filter { $0.isKeyWindow }.first!.rootViewController
            viewController?.dismiss(animated: true, completion: nil)
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
