//
//  UsersViewController.swift
//  RealsUIKit
//
//  Created by Marcelo Diefenbach on 11/09/22.
//

import Foundation
import UIKit

class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var service = ServiceFirebase()
    var contentShowInList: [User] = []
    var users: [User] = []
    var userRequests: [User] = []
    var friends: [User] = []
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
        
        segmentedControl.setTitle("Usuários", forSegmentAt: 0)
        segmentedControl.setTitle("Amigos", forSegmentAt: 1)
        segmentedControl.setTitle("Solicitações", forSegmentAt: 2)
    }
    
    @IBAction func actionBlockedToggle(_ sender: UISegmentedControl) {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            
            self.contentShowInList = self.users
            
        } else if segmentedControl.selectedSegmentIndex == 1 {
            
            self.contentShowInList = self.friends
            
        } else {
            
            self.contentShowInList = self.userRequests
            
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contentShowInList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellUser") as! UserTableViewCell
            
            cell.nameLabel.text = contentShowInList[indexPath.row].username
            
            return cell
        } else if segmentedControl.selectedSegmentIndex == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellFriend") as! FriendTableViewCell
            
            cell.nameLabel.text = contentShowInList[indexPath.row].username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellRequest") as! RequestTableViewCell
            
            cell.nameLabel.text = contentShowInList[indexPath.row].username
            
            return cell
        }
    }
    
    func updateTableViewData() {
        service.getAllUsersWithoutFriends(completionHandler: { (users) in
            self.users = users
            self.contentShowInList = users
        })
        
        service.getAllRequestFriend(completionHandler: { (userRequest) in
            self.userRequests = userRequest
        })
        
        service.getAllFriends(completionHandler: { (friends) in
            self.friends = friends
        })
        
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
      
      tableView.reloadData()
    }
}
