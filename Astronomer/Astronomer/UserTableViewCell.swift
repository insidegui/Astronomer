//
//  UserTableViewCell.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 15/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import SiestaUI

final class UserTableViewCell: UITableViewCell {

    var viewModel: UserViewModel? = nil {
        didSet {
            updateUI()
        }
    }
    
    private lazy var nameLabel: UILabel = {
        let l = UILabel(frame: .zero)
        
        l.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
        l.textColor = UIColor.black
        
        return l
    }()
    
    private lazy var loginLabel: UILabel = {
        let l = UILabel(frame: .zero)
        
        l.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        l.textColor = Appearance.lightTextColor
        
        return l
    }()
    
    private lazy var avatarView: RemoteImageView = {
        let v = RemoteImageView(frame: .zero)
        
        v.contentMode = .scaleAspectFit
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        let circleMask = CAShapeLayer()
        circleMask.frame = CGRect(x: 0, y: 5, width: 45, height: 45)
        circleMask.path = UIBezierPath(ovalIn: circleMask.frame).cgPath
        circleMask.fillColor = UIColor.white.cgColor
        
        v.layer.mask = circleMask
        
        return v
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.nameLabel, self.loginLabel])
        
        v.axis = .vertical
        
        return v
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.avatarView, self.verticalStackView])
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.axis = .horizontal
        v.spacing = 10
        
        return v
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(horizontalStackView)
        horizontalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
        horizontalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        horizontalStackView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        horizontalStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        viewModel.loadUserDetailsIfNeeded()
        
        avatarView.imageURL = viewModel.user.avatar
        
        nameLabel.text = viewModel.user.name ?? ""
        nameLabel.isHidden = viewModel.user.name == nil
        
        loginLabel.text = viewModel.user.login
    }

}
