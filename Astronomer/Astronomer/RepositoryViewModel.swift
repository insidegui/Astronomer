//
//  RepositoryViewModel.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 16/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import IGListDiff

final class RepositoryViewModel: NSObject {
    
    let repository: Repository
    
    var stars: String {
        return "★ " + String(repository.stars)
    }
    
    init(repository: Repository) {
        self.repository = repository
        
        super.init()
    }
    
    override func diffIdentifier() -> NSObjectProtocol {
        return repository.id as NSObjectProtocol
    }
    
    override func isEqual(_ object: IGListDiffable?) -> Bool {
        guard let other = object as? RepositoryViewModel else { return false }
        
        return other.repository == self.repository
    }
    
}
