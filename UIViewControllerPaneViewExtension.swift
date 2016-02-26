//
//  UIViewControllerPaneViewExtension.swift
//  PaneViewController
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import UIKit

protocol PaneViewControllerProtocol {
    
    func showSecondaryViewAnimated(animated: Bool)
    func dismissSecondaryViewAnimated(animated: Bool)
    
}

extension UIViewController: PaneViewControllerProtocol {
    
    func showSecondaryViewAnimated(animated: Bool) {
        parentViewController?.showSecondaryViewAnimated(animated)
    }
    
    func dismissSecondaryViewAnimated(animated: Bool) {
        parentViewController?.dismissSecondaryViewAnimated(animated)
    }
    
}
