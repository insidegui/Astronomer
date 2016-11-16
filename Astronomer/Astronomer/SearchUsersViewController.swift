//
//  SearchUsersViewController.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 10/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchUsersViewController: UITableViewController {

    private lazy var client: GithubClient = GithubClient()
    private lazy var storage: StorageController = StorageController()
    
    private lazy var provider: DataProvider = {
        return DataProvider(client: self.client, storage: self.storage)
    }()
    
    private let disposeBag = DisposeBag()
    
    private struct Constants {
        static let cellIdentifier = "cell"
    }
    
    private lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        
        s.searchBar.barTintColor = Appearance.searchBarTintColor
        
        s.dimsBackgroundDuringPresentation = false
        
        return s
    }()
    
    private var userViewModels = [UserViewModel]() {
        didSet {
            tableView.reload(oldData: oldValue, newData: userViewModels)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        definesPresentationContext = true
        
        // configure table view
        
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.tableHeaderView = searchController.searchBar
        tableView.rowHeight = 66
        
        // map search text to a sequence of users
        let searchObservable = searchController.searchBar.rx.text.throttle(0.5, scheduler: MainScheduler.instance).flatMap { (text: String?) -> Observable<[User]> in
            if let query = text, query.characters.count > 2 {
                return self.provider.searchUsers(with: query)
            } else {
                return Observable<[User]>.just([])
            }
        }
        
        // subscribe to the search results and update the userItems property when they change
        searchObservable.observeOn(MainScheduler.instance).subscribe { event in
            switch event {
            case .next(let users):
                self.userViewModels = users.map({ UserViewModel(user: $0, dataProvider: self.provider) })
            default: break
            }
        }.addDisposableTo(self.disposeBag)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userViewModels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! UserTableViewCell

        cell.viewModel = userViewModels[indexPath.row]

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
