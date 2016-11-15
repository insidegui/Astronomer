//
//  Appearance.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 10/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit

struct Appearance {
    
    static let tintColor = #colorLiteral(red: 1, green: 0.5891644021739131, blue: 0, alpha: 1)
    static let searchBarTintColor = UIColor(red:0.976, green:0.976, blue:0.976, alpha:1)
    
    static func install() {
        UIWindow.appearance().tintColor = tintColor
    }
    
}
