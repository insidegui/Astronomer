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
        guard self.user.name == nil else { return }

        // loads the user's details, which causes the user record to be updated on the database
        _ = dataProvider?.user(with: self.user.login)
    }
    
}

extension User: Equatable { }

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
        && lhs.login == rhs.login
        && lhs.email == rhs.email
        && lhs.name == rhs.name
        && lhs.company == rhs.company
        && lhs.location == rhs.location
        && lhs.blog == rhs.blog
        && lhs.avatar == rhs.avatar
        && lhs.bio == rhs.bio
        && lhs.repos == rhs.repos
        && lhs.followers == rhs.followers
        && lhs.following == rhs.following
}
