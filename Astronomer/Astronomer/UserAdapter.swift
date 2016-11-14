//
//  UserAdapter.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 10/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftyJSON

private extension User {
    struct Keys {
        static let id = "id"
        static let login = "login"
        static let email = "email"
        static let name = "name"
        static let company = "company"
        static let location = "location"
        static let blog = "blog"
        static let avatar = "avatar_url"
        static let bio = "bio"
        static let repos = "public_repos"
        static let followers = "followers"
        static let following = "following"
    }
}

final class UserAdapter: Adapter<JSON, User> {
    
    override func adapt() -> Result<User, AdapterError> {
        let id = input[User.Keys.id].stringValue
        let login = input[User.Keys.login].stringValue
        let avatar = input[User.Keys.avatar].stringValue
        
        // the fields id, login and avatar are the minimum required to consider the user valid
        guard !id.isEmpty && !login.isEmpty && !avatar.isEmpty else {
            return .error(.missingRequiredFields)
        }
        
        let user = User(
            id: id,
            login: login,
            email: input[User.Keys.email].string,
            name: input[User.Keys.name].string,
            company: input[User.Keys.company].string,
            location: input[User.Keys.location].string,
            blog: input[User.Keys.blog].string,
            avatar: avatar,
            bio: input[User.Keys.bio].string,
            repos: input[User.Keys.repos].int,
            followers: input[User.Keys.followers].int,
            following: input[User.Keys.following].int
        )
        
        return .success(user)
    }
    
}
