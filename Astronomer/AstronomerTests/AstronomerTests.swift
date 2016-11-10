//
//  AstronomerTests.swift
//  AstronomerTests
//
//  Created by Guilherme Rambo on 10/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import Astronomer

class AstronomerTests: XCTestCase {
    
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
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
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
    
}
