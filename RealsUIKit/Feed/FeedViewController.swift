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

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var service = ServiceFirebase()
    
    var posts: [Post] = []
    
    @IBOutlet weak var tableView: UITableView!

    var visibleIP : IndexPath?
    var aboutToBecomeInvisibleCell = -1
    var avPlayerLayer: AVPlayerLayer!
    var videoURLs = Array<URL>()
    var firstLoad = true
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//          if (segue.identifier == "captureVideo"){
//            let displayVC = segue.destination as! CaptureVideo
//
//          }
      }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // get all posts of firebase
        service.getFriendsReals { (posts) in
            self.posts = posts

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        visibleIP = IndexPath.init(row: 0, section: 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoCellTableViewCell
        cell.videoPlayerItem = AVPlayerItem.init(url: URL(string: posts[indexPath.row].photo)!)
        cell.titleLabel.text = posts[indexPath.row].ownerUsername
        cell.subtitleLabel.text = posts[indexPath.row].title
        cell.selectionStyle = .none
        
        playVideoOnTheCell(cell: cell, indexPath: indexPath)
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func playVideoOnTheCell(cell : VideoCellTableViewCell, indexPath : IndexPath){
        cell.startPlayback()
    }

    func stopPlayBack(cell : VideoCellTableViewCell, indexPath : IndexPath){
        cell.stopPlayback()
    }

//    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        print("end = \(indexPath)")
//        if let videoCell = cell as? VideoCellTableViewCell {
//        }
//    }
}
