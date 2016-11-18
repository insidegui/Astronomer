//
//  UserViewModel.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 15/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import IGListDiff

final class UserViewModel: NSObject {
    
    let user: User
    private weak var dataProvider: DataProvider?
    
    var nameForTitle: String {
        if let name = self.user.name {
            return name.components(separatedBy: " ").first ?? name
        } else {
            return self.user.login
        }
    }
    
    var nameForProfile: String {
        if let name = self.user.name {
            return name
        } else {
            return self.user.login
        }
    }
    
    var repositoriesTitle: String {
        guard let repositoryCount = user.repos, repositoryCount > 0 else { return nameForTitle }
        
        if repositoryCount > 1 {
            return nameForTitle + "'s Repositories"
        } else {
            return nameForTitle + "'s Repository"
        }
    }
    
    lazy var stats: NSAttributedString = {
        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = .center
        
        let attrs = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 15),
            NSForegroundColorAttributeName: Appearance.lightTextColor,
            NSParagraphStyleAttributeName: pStyle
        ]
        
        let boldAttrs = [
            NSFontAttributeName: UIFont.systemFont(ofSize: 15, weight: UIFontWeightBold),
            NSForegroundColorAttributeName: Appearance.lightTextColor,
            NSParagraphStyleAttributeName: pStyle
        ]
        
        let str = NSMutableAttributedString()
        
        if let followerCount = self.user.followers, followerCount > 0 {
            let followersText = followerCount > 1 ? NSLocalizedString("Followers", comment: "Followers (plural)") : NSLocalizedString("Follower", comment: "Follower (singular)")
            
            str.append(NSAttributedString(string: "\(followerCount) ", attributes: boldAttrs))
            str.append(NSAttributedString(string: followersText + "\n", attributes: attrs))
        }

        if let followingCount = self.user.following, followingCount > 0 {
            let followingText = followingCount > 1 ? NSLocalizedString("Following", comment: "Following (plural)") : NSLocalizedString("Following", comment: "Following (singular)")
            
            str.append(NSAttributedString(string: "\(followingCount) ", attributes: boldAttrs))
            str.append(NSAttributedString(string: followingText + "\n", attributes: attrs))
        }
        
        if let reposCount = self.user.repos, reposCount > 0 {
            let reposText = reposCount > 1 ? NSLocalizedString("Public Repositories", comment: "Public Repositories (plural)") : NSLocalizedString("Public Repository", comment: "Public Repository (singular)")
            
            str.append(NSAttributedString(string: "\(reposCount) ", attributes: boldAttrs))
            str.append(NSAttributedString(string: reposText + "\n", attributes: attrs))
        }
        
        return str.copy() as! NSAttributedString
    }()
    
    lazy var shouldShowStats: Bool = {
        let followers = self.user.followers ?? 0
        let following = self.user.following ?? 0
        let repos = self.user.repos ?? 0
        
        return followers > 0 || following > 0 || repos > 0
    }()
    
    init(user: User, dataProvider: DataProvider? = nil) {
        self.user = user
        self.dataProvider = dataProvider
        
        super.init()
    }
    
    override func diffIdentifier() -> NSObjectProtocol {
        return user.id as NSObjectProtocol
    }
    
    override func isEqual(_ object: IGListDiffable?) -> Bool {
        guard let other = object as? UserViewModel else { return false }
        
        return self.user == other.user
    }
    
    /// This method should be called when the data is displayed to download missing data for the user
    func loadUserDetailsIfNeeded() {
        // Disabled because of a crash in RxRealm, line 344. TODO: investigate
        guard self.user.name == nil else { return }
//
//        // loads the user's details, which causes the user record to be updated on the database
        _ = dataProvider?.user(with: self.user.login)
    }
    
}
