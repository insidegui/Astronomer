//
//  APIClient.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 15/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

enum APIError: Error {
    case unknown
    case http(Error)
    case adapter
}

/// Protocol specifying the interface for a class that can make API requests and return models for the Astronomer app
protocol APIClient {
    
    func searchUsers(query: String, completion: @escaping (Result<SearchResults<User>, APIError>) -> ())
    func user(with login: String, completion: @escaping (Result<User, APIError>) -> ())
    func repositories(by login: String, completion: @escaping (Result<[Repository], APIError>) -> ())
    func repository(by login: String, named name: String, completion: @escaping (Result<Repository, APIError>) -> ())
    func stargazers(for repositoryName: String, ownedBy login: String, completion: @escaping(Result<[User], APIError>) -> ())
    
}
