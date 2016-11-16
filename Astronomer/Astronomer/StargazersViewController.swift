//
//  StargazersViewController.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 16/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import RxSwift

class StargazersViewController: UsersTableViewController {

    private var disposeBag = DisposeBag()
    
    var repository: Repository {
        didSet {
            guard oldValue != repository else { return }
            
            update(with: repository)
        }
    }
    
    init(provider: DataProvider, delegate: UsersTableViewControllerDelegate?, repository: Repository) {
        self.repository = repository
        
        super.init(provider: provider, delegate: delegate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        update(with: repository)
    }
    
    private func update(with repository: Repository) {
        self.disposeBag = DisposeBag()
        
        title = repository.fullName
        
        provider.stargazers(for: repository)
            .observeOn(MainScheduler.instance)
            .subscribe { event in
                switch event {
                case .next(let users):
                    self.userViewModels = users.map({ UserViewModel(user: $0, dataProvider: self.provider) })
                default: break
                }
            }.addDisposableTo(self.disposeBag)
    }

}
