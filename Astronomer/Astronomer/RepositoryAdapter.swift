//
//  RepositoryAdapter.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 10/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftyJSON

private extension Repository {
    
    struct Keys {
        static let id = "id"
        static let name = "name"
        static let fullName = "full_name"
        static let description = "description"
        static let stars = "stargazers_count"
        static let forks = "forks"
        static let watchers = "watchers_count"
    }
    
}

final class RepositoryAdapter: Adapter<JSON, Repository> {
    
    override func adapt() -> Result<Repository, AdapterError> {
        let id = input[Repository.Keys.id].stringValue
        let name = input[Repository.Keys.name].stringValue
        let fullName = input[Repository.Keys.fullName].stringValue
        let description = input[Repository.Keys.description].stringValue
        
        guard !id.isEmpty && !name.isEmpty && !fullName.isEmpty && !description.isEmpty else {
            return .error(.missingRequiredFields)
        }
        
        let repo = Repository(
            id: id,
            name: name,
            fullName: fullName,
            description: description,
            stars: input[Repository.Keys.stars].intValue,
            forks: input[Repository.Keys.forks].intValue,
            watchers: input[Repository.Keys.watchers].intValue
        )
        
        return .success(repo)
    }
    
}

final class RepositoriesAdapter: Adapter<JSON, [Repository]> {
    
    override func adapt() -> Result<[Repository], AdapterError> {
        guard let reposArray = input.array else {
            return .error(.missingRequiredFields)
        }
        
        let repos = reposArray.flatMap { repoJSON -> Repository? in
            let result = RepositoryAdapter(input: repoJSON).adapt()
            switch result {
            case .error(_): return nil
            case .success(let repo): return repo
            }
        }
        
        return .success(repos)
    }
    
}
