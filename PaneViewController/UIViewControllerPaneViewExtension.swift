//
//  UIViewControllerPaneViewExtension.swift
//  PaneViewController
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import UIKit

public protocol PaneViewControllerProtocol {
    
    func showSecondaryViewAnimated(_ animated: Bool)
    func dismissSecondaryViewAnimated(_ animated: Bool)
    
}

extension UIViewController: PaneViewControllerProtocol {
    
    public var paneViewController: PaneViewController? {
        get {
            return self as? PaneViewController ?? parent?.paneViewController
        }
    }
    
    public func showSecondaryViewAnimated(_ animated: Bool) {
        parent?.showSecondaryViewAnimated(animated)
    }
    
    public func dismissSecondaryViewAnimated(_ animated: Bool) {
        parent?.dismissSecondaryViewAnimated(animated)
    }
    
}
