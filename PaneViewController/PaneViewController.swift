//
//  PaneViewController.swift
//  PaneViewController
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import UIKit

class PaneViewController: UIViewController {

    var primaryViewController: UIViewController
    
    init(primaryViewController: UIViewController) {
        self.primaryViewController = primaryViewController
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(primaryViewController)
        primaryViewController.view.frame = view.bounds
        view.addSubview(primaryViewController.view)
        primaryViewController.didMoveToParentViewController(self)
    }
    
}
