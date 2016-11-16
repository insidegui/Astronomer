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

class SearchUsersViewController: UsersTableViewController {

    private let disposeBag = DisposeBag()
    
    private lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        
        s.searchBar.barTintColor = Appearance.searchBarTintColor
        
        s.dimsBackgroundDuringPresentation = false
        
        return s
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Users", comment: "Users - title of users search view controller")
        
        definesPresentationContext = true
        
        // configure table view

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

}
