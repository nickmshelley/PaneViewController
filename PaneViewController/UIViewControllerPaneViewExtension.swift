//
//  UIViewControllerPaneViewExtension.swift
//  PaneViewController
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import UIKit

public protocol PaneViewControllerProtocol {
    
    func showSecondaryViewAnimated(_ animated: Bool, pinningState: PaneViewPinningState)
    func dismissSecondaryViewAnimated(_ animated: Bool)
    
}

extension UIViewController: PaneViewControllerProtocol {
    
    public var paneViewController: PaneViewController? {
        return self as? PaneViewController ?? parent?.paneViewController
    }
    
    public func showSecondaryViewAnimated(_ animated: Bool, pinningState: PaneViewPinningState = .openDefault) {
        parent?.showSecondaryViewAnimated(animated, pinningState: pinningState)
    }
    
    public func dismissSecondaryViewAnimated(_ animated: Bool) {
        parent?.dismissSecondaryViewAnimated(animated)
    }
    
}
