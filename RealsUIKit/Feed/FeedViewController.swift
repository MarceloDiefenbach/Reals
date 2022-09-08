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

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var tableView: UITableView!

//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        tableView.dataSource = self
//
//        service.getAllPost { (posts) in
//            self.posts = posts
//
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
    var visibleIP : IndexPath?
    var aboutToBecomeInvisibleCell = -1
    var avPlayerLayer: AVPlayerLayer!
    var videoURLs = Array<URL>()
    var firstLoad = true


    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
   //Your model to hold the videos in the video URL
        for i in 0..<2{
            let url = Bundle.main.url(forResource:"\(i+1)", withExtension: "mp4")
            videoURLs.append(URL(string: "https://firebasestorage.googleapis.com/v0/b/reals-27ba6.appspot.com/o/57044945-1e7b-4edb-b6c1-b4916d03fd6c.MP4?alt=media&token=147e578f-a04a-4177-9223-005c59f920f0")!)
        }
    // initialized to first indexpath
        visibleIP = IndexPath.init(row: 0, section: 0)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "videoCell") as! VideoCellTableViewCell
        cell.videoPlayerItem = AVPlayerItem.init(url: videoURLs[indexPath.row % 2])
        playVideoOnTheCell(cell: cell, indexPath: indexPath)
        return cell
    }


    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.width*1.6
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

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        print("end = \(indexPath)")
        if let videoCell = cell as? VideoCellTableViewCell {
            videoCell.stopPlayback()
        }
    }
}


//extension FeedViewController: UITableViewDataSource, UITableViewDelegate {
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return posts.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "post", for: indexPath) as? PostTableViewCell else {
//            return UITableViewCell()
//        }
//
//        //MARK: - cell data
//        cell.userNameLabel?.text = "Marcelo \(indexPath.row)"
//        cell.imageURL? = "https://img.freepik.com/fotos-gratis/tiro-medio-homem-tirando-fotos_23-2148503539.jpg"
//
//        return cell
//    }
//
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        //nothing to do now
//    }
//
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        //nothing to do now
//    }
//}
