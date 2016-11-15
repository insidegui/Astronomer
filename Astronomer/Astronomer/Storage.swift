//
//  Storage.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 15/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import RxSwift

enum StorageError: Error {
    case notFound(String?)
    case exception(Error)
}

/// Protocol specifying the interface for a class that can store and retrieve models for the Astronomer app
protocol Storage: class {
    
    func store(users: [User], completion: ((StorageError?) -> ())?)
    func store(repositories: [Repository], completion: ((StorageError?) -> ())?)
    
    func searchUsers(with query: String) -> Observable<[User]>
    func user(withLogin login: String) -> Observable<User>
    func user(withId id: String) -> Observable<User>
    func repositories(by user: User) -> Observable<[Repository]>
    func repository(named name: String) -> Observable<Repository>
    func repository(withId id: String) -> Observable<Repository>
    func stargazers(for repository: Repository) -> Observable<[User]>
    
}
