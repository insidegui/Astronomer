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
    
    let repositories: [Repository]
    
}
