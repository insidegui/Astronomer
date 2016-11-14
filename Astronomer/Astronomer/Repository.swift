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
    
}
