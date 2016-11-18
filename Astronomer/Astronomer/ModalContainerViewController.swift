//
//  ModalContainerViewController.swift
//  Astronomer
//
//  Created by Guilherme Rambo on 18/11/16.
//  Copyright © 2016 Guilherme Rambo. All rights reserved.
//

import UIKit

class ModalContainerViewController: UINavigationController {

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_:)))
        topViewController?.navigationItem.rightBarButtonItem = doneItem
    }
    
    @objc private func done(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }

}
