//
//  User.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 10/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

struct User {
    
    let id: String
    let login: String
    let email: String?
    let name: String?
    let company: String?
    let location: String?
    let blog: String?
    let avatar: String
    let bio: String?
    
    let repos: Int?
    let followers: Int?
    let following: Int?
    
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
