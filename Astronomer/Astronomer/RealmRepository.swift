//
//  RealmRepository.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 13/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import RealmSwift

final class RealmRepository: Object {
    
    dynamic var id = ""
    dynamic var name = ""
    dynamic var fullName = ""
    dynamic var tagline = ""

    dynamic var stars: Int32 = 0
    dynamic var forks: Int32 = 0
    dynamic var watchers: Int32 = 0
    
    override static func indexedProperties() -> [String] {
        return ["name", "fullName", "tagline"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
}

extension RealmRepository {
    
    convenience init(repository: Repository) {
        self.init()
        
        self.id = repository.id
        self.name = repository.name
        self.fullName = repository.fullName
        self.tagline = repository.description
        
        self.stars = Int32(repository.stars)
        self.forks = Int32(repository.forks)
		self.watchers = Int32(repository.watchers)
    }
    
	var repository: Repository {
		return Repository(
            id: id,
            name: name,
            fullName: fullName,
            description: tagline,
            stars: Int(stars),
            forks: Int(forks),
            watchers: Int(watchers)
        )
	}
	
}
