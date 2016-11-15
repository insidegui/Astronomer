//
//  UITableView+Diff.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 15/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit
import IGListDiff

extension UITableView {
    
    func reload(oldData: [IGListDiffable], newData: [IGListDiffable]) {
        let diff = IGListDiffPaths(0, 0, oldData, newData, .equality)
        
        beginUpdates()
        insertRows(at: diff.inserts, with: .automatic)
        deleteRows(at: diff.deletes, with: .automatic)
        reloadRows(at: diff.updates, with: .automatic)
        endUpdates()
    }
    
}
