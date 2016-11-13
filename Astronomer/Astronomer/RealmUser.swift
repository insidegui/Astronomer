//
//  RealmUser.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 13/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmUser: Object {
    
    dynamic var id = ""
    dynamic var login = ""
    dynamic var avatar = ""
    
    dynamic var email: String?
    dynamic var name: String?
    dynamic var company: String?
    dynamic var location: String?
    dynamic var blog: String?
    dynamic var bio: String?
    
    dynamic var repos: Int32 = 0
    dynamic var followers: Int32 = 0
    dynamic var following: Int32 = 0
    
    override static func indexedProperties() -> [String] {
        return ["login", "email", "name"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

extension RealmUser {
    
    convenience init(user: User) {
        self.init()
        
        self.id = user.id
        self.login = user.login
        self.avatar = user.avatar
        self.email = user.email
        self.name = user.name
        self.company = user.company
        self.location = user.location
        self.blog = user.blog
        self.bio = user.bio
        
        self.repos = Int32(user.repos ?? 0)
        self.followers = Int32(user.followers ?? 0)
        self.following = Int32(user.following ?? 0)
    }
    
    var user: User {
        return User(
            id: id,
            login: login,
            email: email,
            name: name,
            company: company,
            location: location,
            blog: blog,
            avatar: avatar,
            bio: bio,
            repos: repos == 0 ? nil : Int(repos),
            followers: followers == 0 ? nil : Int(followers),
            following: following == 0 ? nil : Int(following)
        )
    }
    
}
