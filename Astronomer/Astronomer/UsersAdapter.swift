//
//  UsersAdapter.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 13/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import Foundation
import SwiftyJSON

final class UsersAdapter: Adapter<JSON, [User]> {
    
    override func adapt() -> Result<[User], AdapterError> {
        guard let jsonArray = input.array else {
            return .error(.missingRequiredFields)
        }
        
        let users: [User] = jsonArray.flatMap { jsonUser -> User? in
            let result = UserAdapter(input: jsonUser).adapt()
            switch result {
            case .error(_): return nil
            case .success(let user): return user
            }
        }
        
        return .success(users)
    }
    
}
