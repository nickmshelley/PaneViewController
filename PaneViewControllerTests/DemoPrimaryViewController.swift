//
//  DemoPrimaryViewController.swift
//  PaneViewController
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import UIKit

class DemoPrimaryViewController: UIViewController {
    
    fileprivate let colors = [UIColor.green, UIColor.black, UIColor.orange, UIColor.purple]
    
    fileprivate var colorIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Primary View"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Show", style: .plain, target: self, action: #selector(showSecondaryView))
        
        view.backgroundColor = colors[colorIndex]
    }
    
    func showSecondaryView() {
        showSecondaryViewAnimated(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        colorIndex += 1
        colorIndex %= colors.count
        view.backgroundColor = colors[colorIndex]
    }
    
}
