//
//  PaneViewController.swift
//  PaneViewController
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import UIKit

class PaneViewController: UIViewController {

    let primaryViewController: UIViewController
    let secondaryViewController: UIViewController
    
    private let defaultSideBySideWidthOfSecondaryView = CGFloat(320)

    private var secondaryViewWidthConstraint: NSLayoutConstraint?
    
    init(primaryViewController: UIViewController, secondaryViewController: UIViewController) {
        self.primaryViewController = primaryViewController
        self.secondaryViewController = secondaryViewController
        
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addChildViewController(primaryViewController)
        primaryViewController.view.frame = view.bounds
        primaryViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(primaryViewController.view)
        primaryViewController.didMoveToParentViewController(self)
        
        addChildViewController(secondaryViewController)
        secondaryViewController.view.frame = view.bounds
        secondaryViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(secondaryViewController.view)
        secondaryViewController.didMoveToParentViewController(self)
        
        let views = ["primaryView": primaryViewController.view, "secondaryView": secondaryViewController.view]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[primaryView][secondaryView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[primaryView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[secondaryView]|", options: [], metrics: nil, views: views))

        let startingWidth = view.traitCollection.horizontalSizeClass == .Regular ? defaultSideBySideWidthOfSecondaryView : 0
        let secondaryViewWidthConstraint = NSLayoutConstraint(item: secondaryViewController.view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: startingWidth)
        secondaryViewController.view.addConstraint(secondaryViewWidthConstraint)
        self.secondaryViewWidthConstraint = secondaryViewWidthConstraint
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        secondaryViewWidthConstraint?.constant = newCollection.horizontalSizeClass == .Regular ? defaultSideBySideWidthOfSecondaryView : 0
    }
    
}
