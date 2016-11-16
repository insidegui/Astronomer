//
//  UsersTableViewController.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 16/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import RxSwift

protocol UsersTableViewControllerDelegate: class {
    func didSelect(user: User)
}

class UsersTableViewController: UITableViewController {
    
    weak var provider: DataProvider!
    private weak var delegate: UsersTableViewControllerDelegate?
    
    init(provider: DataProvider, delegate: UsersTableViewControllerDelegate? = nil) {
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
    
    /// Set this to update the table view
    var userViewModels = [UserViewModel]() {
        didSet {
            tableView.reload(oldData: oldValue, newData: userViewModels)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
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
