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
    
    private lazy var nameLabel: UILabel = {
        let l = UILabel(frame: .zero)
        
        l.font = UIFont.systemFont(ofSize: 24, weight: UIFontWeightMedium)
        l.textColor = UIColor.black
        
        return l
    }()
    
    private lazy var companyLabel: UILabel = {
        let l = UILabel(frame: .zero)
        
        l.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        l.textColor = UIColor.black
        
        return l
    }()
    
    private lazy var avatarView: RemoteImageView = {
        let v = RemoteImageView(frame: .zero)
        
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 155).isActive = true
        
        return v
    }()
    
    private lazy var bioLabel: UILabel = {
        let l = UILabel(frame: .zero)
        
        l.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        l.textColor = Appearance.lightTextColor
        
        return l
    }()
    
    private lazy var statsLabel: UILabel = {
        let l = UILabel(frame: .zero)
        
        l.numberOfLines = 0
        
        return l
    }()
    
    private lazy var stackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [
            self.nameLabel,
            self.companyLabel,
            self.avatarView,
            self.bioLabel,
            self.statsLabel
            ])
        
        v.axis = .vertical
        v.spacing = 18
        v.alignment = .center
        v.translatesAutoresizingMaskIntoConstraints = false
        
        return v
    }()
    
    private func update(with user: User) {
        let viewModel = UserViewModel(user: user)
        
        title = viewModel.nameForTitle
        
        view.addSubview(stackView)
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        stackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 30).isActive = true
        stackView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -30).isActive = true
        
        nameLabel.text = viewModel.nameForProfile
        
        if let company = user.company {
            companyLabel.text = company
            companyLabel.isHidden = false
        } else {
            companyLabel.isHidden = true
        }
        
        avatarView.imageURL = user.avatar
        
        if let bio = user.bio {
            bioLabel.text = bio
            bioLabel.isHidden = false
        } else {
            bioLabel.isHidden = true
        }
        
        if viewModel.shouldShowStats {
            statsLabel.attributedText = viewModel.stats
            statsLabel.isHidden = false
        } else {
            statsLabel.isHidden = true
        }
    }
}
