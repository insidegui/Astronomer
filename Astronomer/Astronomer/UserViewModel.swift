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
    
    var repositoriesTitle: String {
        guard let repositoryCount = user.repos, repositoryCount > 0 else { return nameForTitle }
        
        if repositoryCount > 1 {
            return nameForTitle + "'s Repositories"
        } else {
            return nameForTitle + "'s Repository"
        }
    }
    
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
//        guard self.user.name == nil else { return }
//
//        // loads the user's details, which causes the user record to be updated on the database
//        _ = dataProvider?.user(with: self.user.login)
    }
    
}
