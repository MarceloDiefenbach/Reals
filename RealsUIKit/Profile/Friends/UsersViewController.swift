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
    var users: [User] = []
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
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellUser") as! UserTableViewCell

        cell.nameLabel.text = users[indexPath.row].username
        
        return cell
    }
    
    func updateTableViewData() {
        service.getAllUsersWithoutFriends(completionHandler: { (users) in
            self.users = users

            print(users)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
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
