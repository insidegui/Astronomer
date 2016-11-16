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

protocol SearchUsersViewControllerDelegate: class {
    func didSelect(user: User)
}

class SearchUsersViewController: UITableViewController {

    private weak var provider: DataProvider!
    private weak var delegate: SearchUsersViewControllerDelegate?
    
    init(provider: DataProvider, delegate: SearchUsersViewControllerDelegate? = nil) {
        self.provider = provider
        self.delegate = delegate
        
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        title = NSLocalizedString("Users", comment: "Users - title of users search view controller")
        
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
    
    // MARK: - Table view selection
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelect(user: userViewModels[indexPath.row].user)
    }

}
