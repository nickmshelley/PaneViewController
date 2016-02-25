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
    
    private var secondaryViewSideContainerWidthConstraint: NSLayoutConstraint?
    private var secondaryViewModalContainerLeadingConstraint: NSLayoutConstraint?

    private lazy var secondaryViewSideContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = self.view.bounds
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    private lazy var secondaryViewModalContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = self.view.bounds
        containerView.translatesAutoresizingMaskIntoConstraints = false
        return containerView
    }()
    
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
        secondaryViewController.didMoveToParentViewController(self)
        
        view.addSubview(secondaryViewSideContainerView)
        
        view.addSubview(secondaryViewModalContainerView)
        
        let views = ["primaryView": primaryViewController.view, "secondaryViewSideContainerView": secondaryViewSideContainerView, "secondaryViewModalContainerView": secondaryViewModalContainerView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[primaryView][secondaryViewSideContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[secondaryViewModalContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[primaryView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[secondaryViewSideContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[secondaryViewModalContainerView]|", options: [], metrics: nil, views: views))
        
        let secondaryViewSideContainerWidthConstraint = NSLayoutConstraint(item: secondaryViewSideContainerView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        secondaryViewSideContainerView.addConstraint(secondaryViewSideContainerWidthConstraint)
        self.secondaryViewSideContainerWidthConstraint = secondaryViewSideContainerWidthConstraint
        
        view.addConstraint(NSLayoutConstraint(item: secondaryViewModalContainerView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0))
        let secondaryViewModalContainerLeadingConstraint = NSLayoutConstraint(item: secondaryViewModalContainerView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: view.bounds.width)
        view.addConstraint(secondaryViewModalContainerLeadingConstraint)
        self.secondaryViewModalContainerLeadingConstraint = secondaryViewModalContainerLeadingConstraint
        
        updateSecondaryViewLocationForTraitCollection(traitCollection)
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        updateSecondaryViewLocationForTraitCollection(newCollection)
    }
    
    // MARK: Methods
    
    override func showSecondaryViewModallyAnimated(animated: Bool) {
        guard view.traitCollection.horizontalSizeClass == .Compact && secondaryViewModalContainerLeadingConstraint?.constant != 0 else { return }
        
        secondaryViewModalContainerLeadingConstraint?.constant = 0
        
        UIView.animateWithDuration(animated ? 0.3 : 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func dismissModalSecondaryViewAnimated(animated: Bool) {
        guard view.traitCollection.horizontalSizeClass == .Compact && secondaryViewModalContainerLeadingConstraint?.constant == 0 else { return }
        
        secondaryViewModalContainerLeadingConstraint?.constant = view.bounds.width
        
        UIView.animateWithDuration(animated ? 0.3 : 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func updateSecondaryViewLocationForTraitCollection(traitCollection: UITraitCollection) {
        switch traitCollection.horizontalSizeClass {
        case .Regular:
            // Hide the modal if it was showing
            dismissModalSecondaryViewAnimated(false)
            
            secondaryViewController.view.frame = secondaryViewSideContainerView.bounds
            secondaryViewController.view.translatesAutoresizingMaskIntoConstraints = true
            secondaryViewSideContainerWidthConstraint?.constant = defaultSideBySideWidthOfSecondaryView
            secondaryViewSideContainerView.addSubview(secondaryViewController.view)
        case .Compact, .Unspecified:
            secondaryViewController.view.translatesAutoresizingMaskIntoConstraints = false
            secondaryViewSideContainerWidthConstraint?.constant = 0
            secondaryViewController.view.frame = view.bounds
            secondaryViewModalContainerView.addSubview(secondaryViewController.view)
        }
    }
    
}
