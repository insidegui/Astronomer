//
//  StorageController.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 13/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import RealmSwift
import RxSwift

enum StorageError: Error {
    case notFound
}

final class StorageController {
    
    private let configuration: Realm.Configuration
    
    private let queue = DispatchQueue(label: "Storage", qos: .background)
    
    func realm() -> Realm {
        return try! Realm(configuration: self.configuration)
    }
    
    init(configuration: Realm.Configuration = Realm.Configuration()) {
        self.configuration = configuration
    }
    
    // MARK: - Write
    
    func store(users: [User], completion: @escaping (Error?) -> ()) {
        queue.async {
            let realmUsers = users.map(RealmUser.init)
            do {
                let realm = self.realm()
                
                try realm.write {
                    realm.add(realmUsers, update: true)
                }
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    func store(repositories: [Repository], completion: @escaping (Error?) -> ()) {
        queue.async {
            let realm = self.realm()
            
            do {
                let realmRepositories = try repositories.map { repository -> RealmRepository in
                    // try to find existing user record for this repo's owner
                    var realmOwner = realm.object(ofType: RealmUser.self, forPrimaryKey: repository.owner?.id)
                    
                    if realmOwner == nil {
                        // owner record doesn't exist, create one
                        realmOwner = RealmUser(user: repository.owner!)
                        
                        try realm.write {
                            realm.add(realmOwner!)
                        }
                    }
                    
                    return RealmRepository(repository: repository, owner: realmOwner)
                }
                
                try realm.write {
                    realm.add(realmRepositories, update: true)
                }
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    // MARK: - Fetch
    
    /// Search for users
    func searchUsers(with query: String) -> Observable<[User]> {
        let users = self.realm().objects(RealmUser.self).filter("login CONTAINS[c] '\(query)'")
        
        return Observable.from(users).map { realmUsers in
            return realmUsers.map({ $0.user })
        }
    }
    
    /// Fetch a single user based on login
    func user(withLogin login: String) -> Observable<User> {
        guard let user = self.realm().objects(RealmUser.self).filter("login == '\(login)'").first else {
            return Observable<User>.error(StorageError.notFound)
        }
        
        return Observable.from(user).map({ $0.user })
    }
    
    /// Fetch a single user based on id
    func user(withId id: String) -> Observable<User> {
        guard let user = self.realm().object(ofType: RealmUser.self, forPrimaryKey: id) else {
            return Observable<User>.error(StorageError.notFound)
        }
        
        return Observable.from(user).map({ $0.user })
    }
    
    /// Fetch a single repository based on name
    func repository(named name: String) -> Observable<Repository> {
        guard let repository = self.realm().objects(RealmRepository.self).filter("name == '\(name)'").first else {
            return Observable<Repository>.error(StorageError.notFound)
        }
        
        return Observable.from(repository).map({ $0.repository })
    }
    
    /// Fetch a single repository based on id
    func repository(withId id: String) -> Observable<Repository> {
        guard let repository = self.realm().object(ofType: RealmRepository.self, forPrimaryKey: id) else {
            return Observable<Repository>.error(StorageError.notFound)
        }
        
        return Observable.from(repository).map({ $0.repository })
    }
    
}
