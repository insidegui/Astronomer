//
//  AppRouter.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 10/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit

final class AppRouter {
    
    private var window: UIWindow
    private var navigationController: UINavigationController
    
    private var appLaunchOptions: [UIApplicationLaunchOptionsKey: Any]?
    
    private lazy var client: GithubClient = GithubClient()
    private lazy var storage: StorageController = StorageController()
    
    private lazy var provider: DataProvider = {
        return DataProvider(client: self.client, storage: self.storage)
    }()
    
    init(appLaunchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        self.appLaunchOptions = appLaunchOptions
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.navigationController = UINavigationController()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    func showInitialViewController() {
        let controller = SearchUsersViewController(provider: self.provider, delegate: self)
        navigationController.viewControllers = [controller]
    }
    
    func showRepositoriesViewController(for user: User) {
        let controller = RepositoriesTableViewController(provider: self.provider, user: user, delegate: self)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func showStargazersViewController(for repository: Repository) {
        let controller = StargazersViewController(provider: self.provider, delegate: self, repository: repository)
        navigationController.pushViewController(controller, animated: true)
    }
    
    func showProfileViewController(for user: User) {
        let controller = UserProfileViewController(provider: self.provider, user: user)
        navigationController.pushViewController(controller, animated: true)
    }
    
}

extension AppRouter: UsersTableViewControllerDelegate {
    
    func usersTableViewController(_ controller: UsersTableViewController, didSelect user: User) {
        if controller is SearchUsersViewController {
            showRepositoriesViewController(for: user)
        } else if controller is StargazersViewController {
            showProfileViewController(for: user)
        }
    }
    
}

extension AppRouter: RepositoriesTableViewControllerDelegate {
    
    func repositoriesTableViewController(_ controller: RepositoriesTableViewController, didSelect repository: Repository) {
        showStargazersViewController(for: repository)
    }
    
}
