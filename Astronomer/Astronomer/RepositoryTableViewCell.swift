//
//  RepositoryTableViewCell.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 16/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit

class RepositoryTableViewCell: UITableViewCell {

    var viewModel: RepositoryViewModel? = nil {
        didSet {
            guard oldValue?.repository != viewModel?.repository else { return }
            
            updateUI()
        }
    }
    
    private lazy var nameLabel: UILabel = {
        let l = UILabel(frame: .zero)
        
        l.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
        l.textColor = UIColor.black
        
        return l
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let l = UILabel(frame: .zero)
        
        l.font = UIFont.systemFont(ofSize: 15, weight: UIFontWeightRegular)
        l.textColor = Appearance.lightTextColor
        l.numberOfLines = 2
        
        return l
    }()
    
    private lazy var starsLabel: UILabel = {
        let l = UILabel(frame: .zero)
        
        l.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightRegular)
        l.textColor = Appearance.lightTextColor
        
        return l
    }()
    
    private lazy var verticalStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.horizontalStackView, self.descriptionLabel])
        
        v.translatesAutoresizingMaskIntoConstraints = false
        v.distribution = .fill
        v.spacing = 5
        v.alignment = .leading
        v.axis = .vertical
        
        return v
    }()
    
    private lazy var horizontalStackView: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.nameLabel, self.starsLabel])
        
        v.axis = .horizontal
        v.alignment = .fill
        v.distribution = .fill
        v.spacing = 10
        
        return v
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(verticalStackView)
        verticalStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12).isActive = true
        verticalStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12).isActive = true
        verticalStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateUI() {
        guard let viewModel = viewModel else { return }
        
        nameLabel.text = viewModel.repository.name
        descriptionLabel.text = viewModel.repository.description
        starsLabel.text = viewModel.stars
    }


}
