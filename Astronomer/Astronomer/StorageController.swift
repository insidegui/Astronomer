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
    
    func searchUsers(with query: String) -> Observable<[User]> {
        let users = self.realm().objects(RealmUser.self).filter("login CONTAINS[c] '\(query)'")
        
        return Observable.from(users).map { realmUsers in
            return realmUsers.map({ $0.user })
        }
    }
    
}
