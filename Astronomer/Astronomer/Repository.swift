//
//  Repository.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 10/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

struct Repository {
    
    let id: String
    let name: String
    let fullName: String
    let description: String
    
    let stars: Int
    let forks: Int
    let watchers: Int
    
    let owner: User?
    var stargazers: [User]
    
}

extension Repository: Equatable { }

func ==(lhs: Repository, rhs: Repository) -> Bool {
    return lhs.id == rhs.id
        && lhs.name == rhs.name
        && lhs.fullName == rhs.fullName
        && lhs.description == rhs.description
        && lhs.stars == rhs.stars
        && lhs.forks == rhs.forks
        && lhs.watchers == rhs.watchers
        && lhs.owner == rhs.owner
}
