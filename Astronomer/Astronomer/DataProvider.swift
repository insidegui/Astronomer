//
//  DataProvider.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 15/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation

import RxSwift

/// Uses an APIClient and a Storage to provide data for the Astronomer app
final class DataProvider {
    
    private let client: APIClient
    private let storage: Storage
    
    init(client: APIClient, storage: Storage) {
        self.client = client
        self.storage = storage
    }
    
}
