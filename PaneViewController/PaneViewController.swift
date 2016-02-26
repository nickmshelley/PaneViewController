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
    private var secondaryViewModalContainerHiddenLeadingConstraint: NSLayoutConstraint?
    private var secondaryViewModalContainerShowingLeadingConstraint: NSLayoutConstraint?

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
    private lazy var modalShadowCloseButton: UIButton = {
        let shadowButton = UIButton()
        shadowButton.addTarget(self, action: "shadowButtonTapped", forControlEvents: .TouchUpInside)
        shadowButton.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.1)
        shadowButton.translatesAutoresizingMaskIntoConstraints = false
        return shadowButton
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
        
        let views = ["view": view, "primaryView": primaryViewController.view, "secondaryViewSideContainerView": secondaryViewSideContainerView, "secondaryViewModalContainerView": secondaryViewModalContainerView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[primaryView][secondaryViewSideContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[secondaryViewModalContainerView(==view)]", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[primaryView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[secondaryViewSideContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[secondaryViewModalContainerView]|", options: [], metrics: nil, views: views))
        
        let secondaryViewSideContainerWidthConstraint = NSLayoutConstraint(item: secondaryViewSideContainerView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        secondaryViewSideContainerView.addConstraint(secondaryViewSideContainerWidthConstraint)
        self.secondaryViewSideContainerWidthConstraint = secondaryViewSideContainerWidthConstraint
        
        let secondaryViewModalContainerHiddenLeadingConstraint = NSLayoutConstraint(item: secondaryViewModalContainerView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0)
        let secondaryViewModalContainerShowingLeadingConstraint = NSLayoutConstraint(item: secondaryViewModalContainerView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0)
        view.addConstraint(secondaryViewModalContainerHiddenLeadingConstraint)
        view.addConstraint(secondaryViewModalContainerShowingLeadingConstraint)
        secondaryViewModalContainerShowingLeadingConstraint.active = false
        self.secondaryViewModalContainerHiddenLeadingConstraint = secondaryViewModalContainerHiddenLeadingConstraint
        self.secondaryViewModalContainerShowingLeadingConstraint = secondaryViewModalContainerShowingLeadingConstraint
        
        secondaryViewModalContainerView.addSubview(modalShadowCloseButton)
        
        updateSecondaryViewLocationForTraitCollection(traitCollection)
    }
    
    override func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        updateSecondaryViewLocationForTraitCollection(newCollection)
    }
    
    // MARK: Methods
    
    override func showSecondaryViewModallyAnimated(animated: Bool) {
        guard view.traitCollection.horizontalSizeClass == .Compact else { return }
        
        secondaryViewModalContainerHiddenLeadingConstraint?.active = false
        secondaryViewModalContainerShowingLeadingConstraint?.active = true
        
        UIView.animateWithDuration(animated ? 0.3 : 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func dismissModalSecondaryViewAnimated(animated: Bool) {
        guard view.traitCollection.horizontalSizeClass == .Compact else { return }
        
        secondaryViewModalContainerHiddenLeadingConstraint?.active = true
        secondaryViewModalContainerShowingLeadingConstraint?.active = false
        
        UIView.animateWithDuration(animated ? 0.3 : 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    func shadowButtonTapped() {
        dismissModalSecondaryViewAnimated(true)
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
            secondaryViewModalContainerView.addSubview(secondaryViewController.view)
            
            let views = ["secondaryView": secondaryViewController.view, "shadowButton": modalShadowCloseButton]
            secondaryViewModalContainerView.removeConstraints(modalShadowCloseButton.constraints)
            secondaryViewModalContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[shadowButton(==24)][secondaryView]|", options: [], metrics: nil, views: views))
            secondaryViewModalContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[shadowButton]|", options: [], metrics: nil, views: views))
            secondaryViewModalContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[secondaryView]|", options: [], metrics: nil, views: views))
        }
    }
    
}
