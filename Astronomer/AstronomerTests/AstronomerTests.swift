//
//  AstronomerTests.swift
//  AstronomerTests
//
//  Created by Guilherme Rambo on 10/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import XCTest
import SwiftyJSON
import RealmSwift
@testable import Astronomer

class AstronomerTests: XCTestCase {
    
    private var realm: Realm!
    
    private class func url(for resource: String) -> URL {
        return Bundle(for: AstronomerTests.self).url(forResource: resource, withExtension: "json")!
    }
    
    private class func data(for resource: String) -> Data {
        let url = self.url(for: resource)
        return try! Data(contentsOf: url)
    }
    
    private lazy var singleUserData = AstronomerTests.data(for: "SingleUser")
    private lazy var singleRepoData = AstronomerTests.data(for: "SingleRepo")
    private lazy var searchUsersData = AstronomerTests.data(for: "SearchUsers")
    private lazy var userReposData = AstronomerTests.data(for: "UserRepos")
    private lazy var repoStargazersData = AstronomerTests.data(for: "RepoStargazers")
    
    override func setUp() {
        super.setUp()
        
        // reset database for each test
        realm = try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: "test"))
    }
    
    override func tearDown() {
        super.tearDown()
        
        realm = nil
    }
    
    // MARK: - Adapter tests
    
    func testUserAdapter() {
        let json = JSON(data: singleUserData)
        let result = UserAdapter(input: json).adapt()
        
        switch result {
        case .error(let error):
            XCTFail("Expected to succeed but failed with error \(error)")
        case .success(let user):
            XCTAssertEqual(user.id, "67184")
            XCTAssertEqual(user.login, "insidegui")
            XCTAssertEqual(user.email, "insidegui@gmail.com")
            XCTAssertEqual(user.name, "Guilherme Rambo")
            XCTAssertEqual(user.company, "FAKECOMPANYFORTESTS")
            XCTAssertEqual(user.location, "Brazil")
            XCTAssertEqual(user.blog, "twitter.com/_inside")
            XCTAssertEqual(user.avatar, "https://avatars.githubusercontent.com/u/67184?v=3")
            XCTAssertEqual(user.bio, "Mac and iOS developer. Maker of WWDC for macOS, @BrowserFreedom, PodcastMenu @chibistudioapp and a bunch of other stuff.")
            XCTAssertEqual(user.repos, 79)
            XCTAssertEqual(user.followers, 399)
            XCTAssertEqual(user.following, 25)
        }
    }
    
    func testSearchUsersAdapter() {
        let json = JSON(data: searchUsersData)
        let result = SearchUsersAdapter(input: json).adapt()
        
        switch result {
        case .error(let error):
            XCTFail("Expected to succeed but failed with error \(error)")
        case .success(let searchResults):
            XCTAssertEqual(searchResults.items.count, 30)
            XCTAssertEqual(searchResults.count, 7662)
            
            let user = searchResults.items[3]
            
            XCTAssertEqual(user.id, "67184")
            XCTAssertEqual(user.login, "insidegui")
            XCTAssertEqual(user.avatar, "https://avatars.githubusercontent.com/u/67184?v=3")
        }
    }
    
    func testRepositoryAdapter() {
        let json = JSON(data: singleRepoData)
        let result = RepositoryAdapter(input: json).adapt()
        
        switch result {
        case .error(let error):
            XCTFail("Expected to succeed but failed with error \(error)")
        case .success(let repository):
            XCTAssertEqual(repository.id, "34222505")
            XCTAssertEqual(repository.name, "WWDC")
            XCTAssertEqual(repository.fullName, "insidegui/WWDC")
            XCTAssertEqual(repository.description, "The unofficial WWDC app for macOS")
            
            XCTAssertEqual(repository.stars, 4838)
            XCTAssertEqual(repository.forks, 361)
            XCTAssertEqual(repository.watchers, 4838)
        }
    }
    
    func testRepositoriesAdapter() {
        let json = JSON(data: userReposData)
        let result = RepositoriesAdapter(input: json).adapt()
        
        switch result {
        case .error(let error):
            XCTFail("Expected to succeed but failed with error \(error)")
        case .success(let repositories):
            XCTAssertEqual(repositories.count, 29)
            
            let repo = repositories[5]
            XCTAssertEqual(repo.id, "62277423")
            XCTAssertEqual(repo.name, "Binge")
            XCTAssertEqual(repo.fullName, "insidegui/Binge")
            XCTAssertEqual(repo.description, "Projeto exemplo da minha palestra sobre desenvolvimento pra Mac")
            XCTAssertEqual(repo.stars, 6)
            XCTAssertEqual(repo.forks, 2)
            XCTAssertEqual(repo.watchers, 6)
        }
    }
    
    func testUsersAdapter() {
        let json = JSON(data: repoStargazersData)
        let result = UsersAdapter(input: json).adapt()
        
        switch result {
        case .error(let error):
            XCTFail("Expected to succeed but failed with error \(error)")
        case .success(let users):
            XCTAssertEqual(users.count, 30)
            let user = users[1]
            XCTAssertEqual(user.id, "97697")
            XCTAssertEqual(user.login, "connor")
        }
    }
    
    // MARK: - Storage tests
    
    private lazy var userForStorageTests: User? = {
        let json = JSON(data: self.singleUserData)
        let result = UserAdapter(input: json).adapt()
        
        switch result {
        case .success(let user):
            return user
        default: return nil
        }
    }()
    
    private func repositoryForStorageTests() -> Repository? {
        let json = JSON(data: self.singleRepoData)
        let result = RepositoryAdapter(input: json).adapt()
        
        switch result {
        case .success(let repo):
            return repo
        default: return nil
        }
    }
    
    func testRealmUserStorage() {
        let user = userForStorageTests!
        
        try! realm.write { realm.add(RealmUser(user: user)) }
        
        let realmUser = realm.objects(RealmUser.self).first!
        
        XCTAssertEqual(realmUser.id, user.id)
        XCTAssertEqual(realmUser.login, user.login)
        XCTAssertEqual(realmUser.email, user.email)
        XCTAssertEqual(realmUser.name, user.name)
        XCTAssertEqual(realmUser.company, user.company)
        XCTAssertEqual(realmUser.location, user.location)
        XCTAssertEqual(realmUser.blog, user.blog)
        XCTAssertEqual(realmUser.avatar, user.avatar)
        XCTAssertEqual(realmUser.bio, user.bio)
        XCTAssertEqual(realmUser.repos, Int32(user.repos ?? 0))
        XCTAssertEqual(realmUser.followers, Int32(user.followers ?? 0))
        XCTAssertEqual(realmUser.following, Int32(user.following ?? 0))
        
        XCTAssertEqual(realmUser.user.id, user.id)
        XCTAssertEqual(realmUser.user.login, user.login)
        XCTAssertEqual(realmUser.user.email, user.email)
        XCTAssertEqual(realmUser.user.name, user.name)
        XCTAssertEqual(realmUser.user.company, user.company)
        XCTAssertEqual(realmUser.user.location, user.location)
        XCTAssertEqual(realmUser.user.blog, user.blog)
        XCTAssertEqual(realmUser.user.avatar, user.avatar)
        XCTAssertEqual(realmUser.user.bio, user.bio)
        XCTAssertEqual(realmUser.user.repos, user.repos)
        XCTAssertEqual(realmUser.user.followers, user.followers)
        XCTAssertEqual(realmUser.user.following, user.following)
    }
    
    func testRealmRepositoryStorage() {
        let repository = repositoryForStorageTests()!
        
        try! realm.write { realm.add(RealmRepository(repository: repository)) }
        
        let realmRepo = realm.objects(RealmRepository.self).first!
		
		XCTAssertEqual(realmRepo.id, repository.id)
		XCTAssertEqual(realmRepo.name, repository.name)
		XCTAssertEqual(realmRepo.fullName, repository.fullName)
		XCTAssertEqual(realmRepo.tagline, repository.description)
		XCTAssertEqual(realmRepo.stars, Int32(repository.stars))
		XCTAssertEqual(realmRepo.forks, Int32(repository.forks))
		XCTAssertEqual(realmRepo.watchers, Int32(repository.watchers))
		
		XCTAssertEqual(realmRepo.repository.id, repository.id)
		XCTAssertEqual(realmRepo.repository.name, repository.name)
		XCTAssertEqual(realmRepo.repository.fullName, repository.fullName)
		XCTAssertEqual(realmRepo.repository.description, repository.description)
		XCTAssertEqual(realmRepo.repository.stars, repository.stars)
		XCTAssertEqual(realmRepo.repository.forks, repository.forks)
		XCTAssertEqual(realmRepo.repository.watchers, repository.watchers)
    }
    
}
