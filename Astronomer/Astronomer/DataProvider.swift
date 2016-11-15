//
//  DataProvider.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 15/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

import RxSwift

/// Uses an APIClient and a Storage to provide data for the Astronomer app
final class DataProvider {
    
    private let client: APIClient
    private let storage: Storage
    
    init(client: APIClient, storage: Storage) {
        self.client = client
        self.storage = storage
    }
    
    /// You can subscribe to this variable to get informed when an error occurs on any DataProvider operation
    var error = Variable<Error?>(nil)
    
    // MARK: - Data operations
    
    func searchUsers(with query: String) -> Observable<[User]> {
        client.searchUsers(query: query) { [weak self] result in
            switch result {
            case .success(let results):
                self?.storage.store(users: results.items, completion: nil)
            case .error(let error):
                self?.error.value = error
            }
        }
        
        return storage.searchUsers(with: query)
    }
    
}
