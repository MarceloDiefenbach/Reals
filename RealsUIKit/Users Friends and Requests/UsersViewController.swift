//
//  UsersViewController.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 11/09/22.
//

import Foundation
import UIKit
import GoogleMobileAds

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, GADBannerViewDelegate {
    
    var bannerView: GADBannerView!
    
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.backgroundColor = .black
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
        
    }
    
    var serviceSocial = ServiceSocial()
    var service = ServiceFirebase()
    var sender = PushNotificationSender()
    
    var contentShowInList: [User] = []
    var users: [User] = []
    var following: [User] = []
    var followers: [User] = []
    let searchController = UISearchController(searchResultsController: nil)
    var filteredUsers: [User] = []
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Candies"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        updateTableViewData()
        
        segmentedControl.setTitle("Users", forSegmentAt: 0)
        segmentedControl.setTitle("Following", forSegmentAt: 1)
        segmentedControl.setTitle("Followers", forSegmentAt: 2)
        
        //MARK: - admob
        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        addBannerViewToView(bannerView)
        bannerView.adUnitID = "ca-app-pub-5038687707625733/4269905853"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self

    }
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("bannerViewDidReceiveAd")
    }

    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
      print("bannerView:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }

    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
      print("bannerViewDidRecordImpression")
    }

    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillPresentScreen")
    }

    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewWillDIsmissScreen")
    }

    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("bannerViewDidDismissScreen")
    }
    
    @IBAction func actionBlockedToggle(_ sender: UISegmentedControl) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            self.getAllUsersWithoutFriends()
        } else if segmentedControl.selectedSegmentIndex == 1 {
            self.getAllFollowing()
        } else {
            self.getAllFollowers()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentShowInList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUser") as! UserTableViewCell
            
            cell.nameLabel.text = contentShowInList[indexPath.row].username
            cell.delegate = self
            cell.setUser(user: contentShowInList[indexPath.row])
            return cell
            
        } else if segmentedControl.selectedSegmentIndex == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFriend") as! FriendTableViewCell
            
            cell.nameLabel.text = contentShowInList[indexPath.row].username
            cell.setUser(user: contentShowInList[indexPath.row])
            cell.delegate = self
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFollower") as! FollowerTableViewCell
            
            cell.nameLabel.text = contentShowInList[indexPath.row].username
            cell.setUser(user: contentShowInList[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
    
    func updateTableViewData() {
        getAllUsersWithoutFriends()
        getAllFollowing()
        getAllFollowers()
        updateTableView()
    }
    
    func updateTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
}

extension UsersViewController: UISearchResultsUpdating {
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
    
    func filterContentForSearchText(_ searchText: String) {
        filteredUsers = users.filter { (user: User) -> Bool in
            return user.username.lowercased().contains(searchText.lowercased())
        }
        updateTableView()
    }
}

//MARK: - functions
extension UsersViewController {
    func getAllUsersWithoutFriends() {
        serviceSocial.getAllUsersWithoutFriends(completionHandler: { (users) in
            self.users = users
            self.contentShowInList = users
            self.updateTableView()
        })
    }
    
    func getAllFollowing() {
        serviceSocial.getUsers(usersType: GetUsersType.following, completionHandler: { (following) in
            self.following = following
            self.contentShowInList = following
            self.updateTableView()
        })
    }
    func getAllFollowers() {
        serviceSocial.getUsers(usersType: GetUsersType.followers, completionHandler: { (followers) in
            self.followers = followers
            self.contentShowInList = followers
            self.updateTableView()
        })
    }
}

//MARK: - delegat of cells
extension UsersViewController: DelegateUserRequests {
    
    func followSomeone(userToFollow: User) {
        serviceSocial.followSomeone(userToFollow: userToFollow, completionHandler: { (response) in
            if response {
                self.sender.sendFollowNotification(user: userToFollow)
            }
        })
        self.getAllUsersWithoutFriends()
    }
    
    func unfollowSomeone(usernameToUnfollow: User) {
        serviceSocial.unfollowSomeone(usernameToUnfollow: usernameToUnfollow, completionHandler: { (repsonse) in
        })
        self.getAllFollowing()
    }
}
