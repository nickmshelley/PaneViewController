//
//  UIViewControllerPaneViewExtension.swift
//  PaneViewController
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import UIKit

protocol PaneViewControllerProtocol {
    
    func showSecondaryViewModallyAnimated(animated: Bool)
    func dismissModalSecondaryViewAnimated(animated: Bool)
    
}

extension UIViewController: PaneViewControllerProtocol {
    
    func showSecondaryViewModallyAnimated(animated: Bool) {
        parentViewController?.showSecondaryViewModallyAnimated(animated)
    }
    
    func dismissModalSecondaryViewAnimated(animated: Bool) {
        parentViewController?.dismissModalSecondaryViewAnimated(animated)
    }
    
}
