//
//  DemoPrimaryViewController.swift
//  PaneViewController
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import UIKit

class DemoPrimaryViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Primary View"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show", style: .Plain, target: self, action: "showSecondaryView")
        
        view.backgroundColor = UIColor.greenColor()
    }
    
    func showSecondaryView() {
        showSecondaryViewModallyAnimated(true)
    }
    
}
