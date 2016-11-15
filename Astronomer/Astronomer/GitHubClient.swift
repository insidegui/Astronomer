//
//  GithubClient.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 15/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import Siesta

extension Siesta.Resource {
    
    var error: APIError {
        if let underlyingError = self.latestError {
            return .http(underlyingError)
        } else {
            return .unknown
        }
    }
    
}

final class GithubClient: APIClient {
    
    private let concreteClient = GithubAPI()
    
    func searchUsers(query: String, completion: @escaping (Result<SearchResults<User>, APIError>) -> ()) {
        concreteClient.searchUsers(query: query).addObserver(owner: self) { [weak self] resource, event in
            self?.process(resource, event: event, with: completion)
        }.loadIfNeeded()
    }
    
    func user(with login: String, completion: @escaping (Result<User, APIError>) -> ()) {
        concreteClient.user(with: login).addObserver(owner: self) { [weak self] resource, event in
            self?.process(resource, event: event, with: completion)
        }.loadIfNeeded()
    }
    
    func repositories(by login: String, completion: @escaping (Result<[Repository], APIError>) -> ()) {
        concreteClient.repositories(by: login).addObserver(owner: self) { [weak self] resource, event in
            self?.process(resource, event: event, with: completion)
        }.loadIfNeeded()
    }
    
    func repository(by login: String, named name: String, completion: @escaping (Result<Repository, APIError>) -> ()) {
        concreteClient.repository(by: login, named: name).addObserver(owner: self) { [weak self] resource, event in
            self?.process(resource, event: event, with: completion)
        }.loadIfNeeded()
    }
    
    func stargazers(for repositoryName: String, ownedBy login: String, completion: @escaping(Result<[User], APIError>) -> ()) {
        concreteClient.stargazers(for: repositoryName, ownedBy: login).addObserver(owner: self) { [weak self] resource, event in
            self?.process(resource, event: event, with: completion)
        }.loadIfNeeded()
    }
    
    
    private func process<M>(_ resource: Siesta.Resource, event: Siesta.ResourceEvent, with completion: @escaping (Result<M, APIError>) -> ()) {
        switch event {
        case .error:
            completion(.error(resource.error))
        case .newData(_):
            if let results: M = resource.typedContent() {
                completion(.success(results))
            } else {
                completion(.error(.adapter))
            }
        default: break
        }
    }
}
