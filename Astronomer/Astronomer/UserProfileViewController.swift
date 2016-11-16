//
//  UserProfileViewController.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 16/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import RxSwift
import SiestaUI

class UserProfileViewController: UIViewController {

    private weak var provider: DataProvider!
    
    var user: User {
        didSet {
            guard user != oldValue else { return }
            
            update(with: user)
        }
    }
    
    init(provider: DataProvider, user: User) {
        self.provider = provider
        self.user = user
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white
        view.isOpaque = true
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        update(with: user)
    }
    
    private func update(with user: User) {
        title = UserViewModel(user: user).nameForTitle
    }
}
