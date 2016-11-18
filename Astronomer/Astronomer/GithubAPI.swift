//
//  GithubAPI.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 13/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import Siesta
import SwiftyJSON

final class GithubAPI {
    
    private struct Endpoints {
        static let searchUsers = "/search/users"
        static let singleUser = "/users/*"
        static let userRepos = "/users/*/repos"
        static let singleRepo = "/repos/*/*"
        static let stargazers = "/repos/*/*/stargazers"
    }
    
    private let service = Service(baseURL: "https://api.github.com")
    
    init() {
        service.configure("**") { config in
            config.useNetworkActivityIndicator()
            
            // set HTTP basic authentication header
            config.headers["Authorization"] = self.authenticationHeader
            
            // add SwiftyJSON parser to the pipeline for JSON responses
            config.pipeline[.parsing].add(self.jsonParser, contentTypes: ["*/json"])
            
            // add Github error handler to the pipeline, to fetch Github's specific error message (if any)
            config.pipeline[.cleanup].add(GithubErrorHandler())
        }
        
        service.configureTransformer(Endpoints.searchUsers) {
            try self.failableAdapt(using: SearchUsersAdapter(input: $0.content as JSON))
        }
        
        service.configureTransformer(Endpoints.singleUser) {
            try self.failableAdapt(using: UserAdapter(input: $0.content as JSON))
        }
        
        service.configureTransformer(Endpoints.userRepos) {
            try self.failableAdapt(using: RepositoriesAdapter(input: $0.content as JSON))
        }
        
        service.configureTransformer(Endpoints.singleRepo) {
            try self.failableAdapt(using: RepositoryAdapter(input: $0.content as JSON))
        }
        
        service.configureTransformer(Endpoints.stargazers) {
            try self.failableAdapt(using: UsersAdapter(input: $0.content as JSON))
        }
    }
    
    // MARK: - Resources
    
    /// Resource representing a search for users
    ///
    /// - Parameter query: Search query
    /// - Returns: A resource containing a search result with a list of users
    func searchUsers(query: String) -> Resource {
        return service
            .resource("/search/users")
            .withParam("q", query)
            .withParam("per_page", "100")
    }
    
    /// Resource representing a single user
    ///
    /// - Parameter login: The user's login
    /// - Returns: A resource containing the user
    func user(with login: String) -> Resource {
        return service
            .resource("/users")
            .child(login.lowercased())
    }
    
    /// Resource representing a list of repositories
    ///
    /// - Parameter login: The login of the user for which to get the repositories
    /// - Returns: A resource containing a list of repositories
    func repositories(by login: String) -> Resource {
        return service
            .resource("/users")
            .child(login.lowercased())
            .child("repos")
            .withParam("per_page", "100")
    }
    
    /// Resource representing a repository
    ///
    /// - Parameters:
    ///   - login: The login of the repository's owner
    ///   - name: The name of the repository
    /// - Returns: A resource containing the repository
    func repository(by login: String, named name: String) -> Resource {
        return service
            .resource("/repos")
            .child(login.lowercased())
            .child(name.lowercased())
    }
    
    /// Resource representing a repository's  stargazers
    ///
    /// - Parameters:
    ///   - repositoryName: The name of the repository
    ///   - login: The login of the repository's owner
    /// - Returns: A resource containing the list of stargazers
    func stargazers(for repositoryName: String, ownedBy login: String) -> Resource {
        return service
            .resource("/repos")
            .child(login.lowercased())
            .child(repositoryName.lowercased())
            .child("stargazers")
            .withParam("per_page", "100")
    }
    
    // MARK: - Auth
    
    private lazy var authenticationHeader: String = {
        guard let auth = "\(Credentials.username):\(Credentials.accessToken)".data(using: String.Encoding.utf8) else {
            fatalError("Unable to generate authentication header, check username and accessToken in Credentials.swift")
        }
        
        return "Basic \(auth.base64EncodedString())"
    }()
    
    // MARK: - Transformations
    
    private let jsonParser = ResponseContentTransformer { JSON($0.content as AnyObject) }
    
    /// This error handler will process the response to extract Github's specific error message
    private struct GithubErrorHandler: ResponseTransformer {
        
        func process(_ response: Response) -> Response {
            switch response {
            case .success:
                return response
            case .failure(var error):
                // update error with Github error
                error.userMessage = error.jsonDict["message"] as? String ?? error.userMessage
                return .failure(error)
            }
        }
        
    }
    
    /// Convenience method to use a model adapter as a method that returns the model(s) or throws an error
    private func failableAdapt<T>(using adapter: Adapter<JSON, T>) throws -> T {
        let result = adapter.adapt()
        switch result {
        case .success(let entity):
            return entity
        case .error(let error):
            throw error
        }
    }
    
}
