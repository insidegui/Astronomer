//
//  SearchResultsAdapter.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 10/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftyJSON

private struct SearchResultsKeys {
    static let count = "total_count"
    static let items = "items"
}

final class SearchUsersAdapter: Adapter<JSON, SearchResults<User>> {
    
    override func adapt() -> Result<SearchResults<User>, AdapterError> {
        guard let itemArray = input[SearchResultsKeys.items].array else {
            return .error(.missingRequiredFields)
        }

        let count = input[SearchResultsKeys.count].intValue

        let items: [User] = itemArray.flatMap { jsonUser -> User? in
            let result = UserAdapter(input: jsonUser).adapt()
            switch result {
            case .error(_): return nil
            case .success(let user): return user
            }
        }

        let searchResults = SearchResults<User>(count: count, items: items)
        
        return .success(searchResults)
    }
    
}
