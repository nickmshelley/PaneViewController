//
//  DemoPrimaryViewController.swift
//  PaneViewController
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import UIKit

class DemoPrimaryViewController: UIViewController {
    
    private let colors = [UIColor.greenColor(), UIColor.blackColor(), UIColor.orangeColor(), UIColor.purpleColor()]
    
    private var colorIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Primary View"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show", style: .Plain, target: self, action: #selector(showSecondaryView))
        
        view.backgroundColor = colors[colorIndex]
    }
    
    func showSecondaryView() {
        showSecondaryViewAnimated(true)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        colorIndex += 1
        colorIndex %= colors.count
        view.backgroundColor = colors[colorIndex]
    }
    
}
