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

final class StorageController: Storage {
    
    private let configuration: Realm.Configuration
    
    private let queue = DispatchQueue(label: "Storage", qos: .background)
    
    func realm() -> Realm {
        return try! Realm(configuration: self.configuration)
    }
    
    init(configuration: Realm.Configuration = Realm.Configuration()) {
        self.configuration = configuration
    }
    
    // MARK: - Write
    
    func store(users: [User], completion: ((StorageError?) -> ())?) {
        queue.async {
            let realmUsers = users.map(RealmUser.init)
            do {
                try self.insertOrUpdate(objects: realmUsers) { oldUser, newUser in
                    // update old user record if it had no name and the new user has one
                    return oldUser.name == nil && newUser.name != nil
                }
                
                completion?(nil)
            } catch {
                completion?(.exception(error))
            }
        }
    }
    
    func store(repositories: [Repository], completion: ((StorageError?) -> ())?) {
        queue.async {
            let realm = self.realm()
            
            do {
                let realmRepositories = try repositories.map { repository -> RealmRepository in
                    // fetch or create user record for owner
                    let realmOwner = try self.fetchOrCreate(type: RealmUser.self, primaryKey: repository.owner?.id) {
                        return RealmUser(user: repository.owner!)
                    }
                    
                    // fetch or create user records for stargazers
                    let realmStargazers = try repository.stargazers.map { stargazer -> RealmUser in
                        return try self.fetchOrCreate(type: RealmUser.self, primaryKey: stargazer.id) {
                            return RealmUser(user: stargazer)
                        }
                    }
                    
                    return RealmRepository(repository: repository, owner: realmOwner, stargazers: realmStargazers)
                }
                
                try realm.write {
                    realm.add(realmRepositories, update: true)
                }
                
                completion?(nil)
            } catch {
                completion?(.exception(error))
            }
        }
    }
    
    // MARK: - Helpers
    
    /// Fetch or create an object
    ///
    /// - Parameters:
    ///   - type: The type of object to be fetched / created
    ///   - primaryKey: The value of the primary key to be used to find an existing object
    ///   - create: A block that returns a new object in case an existing one can't be found
    /// - Returns: An object of the specified type
    /// - Throws: A Realm error if the object doesn't exist and can't be created
    private func fetchOrCreate<T: Object, K>(type: T.Type, primaryKey: K, create: () -> T) throws -> T {
        let realm = self.realm()
        
        if let object = realm.object(ofType: type, forPrimaryKey: primaryKey) {
            return object
        } else {
            let object = create()
            
            try realm.write {
                realm.add(object)
            }
            
            return object
        }
    }
    
    /// Inserts or updates the objects using the updateDecisionHandler to determine whether an update is necessary or not
    ///
    /// - Parameters:
    ///   - object: The objects to insert or update
    ///   - updateDecisionHandler: A block called for each object pair, should return true if the object should be updated and false if it shouldn't
    ///   - oldObject: the existing object
    ///   - newObject: the new object
    /// - Throws: A Realm error if the object doesn't have a primary key or can't be updated/created
    private func insertOrUpdate<T: Object>(objects: [T], updateDecisionHandler: @escaping (_ oldObject: T, _ newObject: T) -> Bool) throws {
        try objects.forEach({ try self.insertOrUpdate(object: $0, updateDecisionHandler: updateDecisionHandler) })
    }
    
    /// Inserts or updates the object using the updateDecisionHandler to determine whether an update is necessary or not
    ///
    /// - Parameters:
    ///   - object: The object to insert or update
    ///   - updateDecisionHandler: A block that returns true if the object should be updated and false if it shouldn't
    ///   - oldObject: the existing object
    ///   - newObject: the new object
    /// - Throws: A Realm error if the object doesn't have a primary key or can't be updated/created
    private func insertOrUpdate<T: Object>(object: T, updateDecisionHandler: @escaping (_ oldObject: T, _ newObject: T) -> Bool) throws {
        let realm = self.realm()
        
        guard let primaryKey = T.primaryKey() else {
            fatalError("insertOrUpdate can't be used for objects without a primary key")
        }
        
        guard let primaryKeyValue = object.value(forKey: primaryKey) else {
            fatalError("insertOrUpdate can't be used for objects without a primary key")
        }
        
        if let existingObject = realm.object(ofType: T.self, forPrimaryKey: primaryKeyValue) {
            // object already exists, call updateDecisionHandler to determine whether we should update it or not
            if updateDecisionHandler(existingObject, object) {
                try realm.write {
                    realm.add(object, update: true)
                }
            }
        } else {
            // object doesn't exist, just add it
            try realm.write {
                realm.add(object)
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
            return Observable<User>.error(StorageError.notFound("User not found with login \(login)"))
        }
        
        return Observable.from(user).map({ $0.user })
    }
    
    /// Fetch a single user based on id
    func user(withId id: String) -> Observable<User> {
        guard let user = self.realm().object(ofType: RealmUser.self, forPrimaryKey: id) else {
            return Observable<User>.error(StorageError.notFound("User not found with id \(id)"))
        }
        
        return Observable.from(user).map({ $0.user })
    }
    
    /// Fetch repositories owned by the user
    func repositories(by user: User) -> Observable<[Repository]> {
        let repositories = self.realm().objects(RealmRepository.self).filter("owner.id == '\(user.id)'")
        
        return Observable.from(repositories).map { repos in
            return repos.map({ $0.repository })
        }
    }
    
    /// Fetch a single repository based on name
    func repository(named name: String) -> Observable<Repository> {
        guard let repository = self.realm().objects(RealmRepository.self).filter("name == '\(name)'").first else {
            return Observable<Repository>.error(StorageError.notFound("Repository not found with name \(name)"))
        }
        
        return Observable.from(repository).map({ $0.repository })
    }
    
    /// Fetch a single repository based on id
    func repository(withId id: String) -> Observable<Repository> {
        guard let repository = self.realm().object(ofType: RealmRepository.self, forPrimaryKey: id) else {
            return Observable<Repository>.error(StorageError.notFound("Repository not found with id \(id)"))
        }
        
        return Observable.from(repository).map({ $0.repository })
    }
    
    /// Fetch a repository's stargazers
    func stargazers(for repository: Repository) -> Observable<[User]> {
        guard let realmRepository = self.realm().object(ofType: RealmRepository.self, forPrimaryKey: repository.id) else {
            return Observable<[User]>.error(StorageError.notFound("Repository not found with id \(repository.id)"))
        }
        
        return Observable.from(realmRepository.stargazers).map { realmUsers -> [User] in
            return realmUsers.map({ $0.user })
        }
    }
    
}
