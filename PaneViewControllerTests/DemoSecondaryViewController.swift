//
//  DemoSecondaryViewController.swift
//  PaneViewController
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import UIKit

class DemoSecondaryViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Secondary View"

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "X", style: .Plain, target: self, action: #selector(hideSecondaryView))
        
        view.backgroundColor = UIColor.redColor()
    }
    
    func hideSecondaryView() {
        dismissSecondaryViewAnimated(true)
    }
    
}
