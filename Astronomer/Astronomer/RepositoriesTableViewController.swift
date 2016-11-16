//
//  RepositoriesTableViewController.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 16/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import RxSwift

protocol RepositoriesTableViewControllerDelegate: class {
    func repositoriesTableViewController(_ controller: RepositoriesTableViewController, didSelect repository: Repository)
}

class RepositoriesTableViewController: UITableViewController {

    private struct Constants {
        static let cellIdentifier = "repositoryCell"
    }
    
    private weak var provider: DataProvider!
    
    private let disposeBag = DisposeBag()
    
    private var user: User {
        didSet {
            update(with: user)
        }
    }
    
    private var repositoryViewModels: [RepositoryViewModel] = [] {
        didSet {
            tableView.reload(oldData: oldValue, newData: repositoryViewModels)
        }
    }
    
    private weak var delegate: RepositoriesTableViewControllerDelegate?
    
    init(provider: DataProvider, user: User, delegate: RepositoriesTableViewControllerDelegate? = nil) {
        self.user = user
        self.provider = provider
        self.delegate = delegate
        
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        update(with: user)
        
        tableView.register(RepositoryTableViewCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        tableView.rowHeight = 74
    }
    
    private func update(with user: User) {
        title = UserViewModel(user: user).repositoriesTitle
        
        provider.repositories(by: user)
            .observeOn(MainScheduler.instance)
            .subscribe { event in
            switch event {
            case .next(let repositories):
                self.repositoryViewModels = repositories.map(RepositoryViewModel.init)
            default: break
            }
        }.addDisposableTo(self.disposeBag)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositoryViewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as! RepositoryTableViewCell

        cell.viewModel = repositoryViewModels[indexPath.row]

        return cell
    }
    
    // MARK: - Selection
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.repositoriesTableViewController(self, didSelect: repositoryViewModels[indexPath.row].repository)
    }

}
