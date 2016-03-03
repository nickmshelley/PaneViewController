//
//  PaneViewController.swift
//  PaneViewController
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import UIKit
import Swiftification

public class PaneViewController: UIViewController {

    enum PredeterminedWidth {
        case Half
        case Set320
        case Set0
        
        func currentValueForFullWidth(fullWidth: CGFloat) -> CGFloat {
            switch self {
            case .Half:
                return fullWidth / 2.0
            case .Set320:
                return 320
            case .Set0:
                return 0
            }
        }
    }
    
    public let primaryViewController: UIViewController
    public let secondaryViewController: UIViewController
    public let primaryViewWillChangeWidthObservers = ObserverSet<UIView>()
    public let primaryViewDidChangeWidthObservers = ObserverSet<UIView>()
    
    public var isSecondaryViewShowing = false
    public var handleColor = UIColor(colorLiteralRed: 197.0 / 255.0, green: 197.0 / 255.0, blue: 197.0 / 255.0, alpha: 0.5) {
        didSet {
            if isViewLoaded() {
                handleView.backgroundColor = handleColor
            }
        }
    }
    public var paneSeparatorColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.16) {
        didSet {
            if isViewLoaded() {
                paneSeparatorView.backgroundColor = paneSeparatorColor
            }
        }
    }
    public var modalShadowColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.1) {
        didSet {
            if isViewLoaded() {
                modalShadowCloseButton.backgroundColor = modalShadowColor
            }
        }
    }
    
    private var isDragging = false
    private var secondaryViewSideContainerCurrentWidthConstraint: NSLayoutConstraint?
    private var secondaryViewSideContainerDraggingWidthConstraint: NSLayoutConstraint?
    private var secondaryViewModalContainerHiddenLeadingConstraint: NSLayoutConstraint?
    private var secondaryViewModalContainerShowingLeadingConstraint: NSLayoutConstraint?
    private var secondaryViewSideContainerWidthEnum = PredeterminedWidth.Set0
    private var previousRegularSizeClassSecondaryViewSideContainerWidthEnum = PredeterminedWidth.Set0
    
    private lazy var secondaryViewSideContainerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        return containerView
    }()
    private lazy var secondaryViewModalContainerView: UIView = {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.clipsToBounds = true
        return containerView
    }()
    private lazy var modalShadowCloseButton: UIButton = {
        let shadowButton = UIButton()
        shadowButton.addTarget(self, action: "shadowButtonTapped", forControlEvents: .TouchUpInside)
        shadowButton.alpha = 0
        shadowButton.backgroundColor = self.modalShadowColor
        shadowButton.translatesAutoresizingMaskIntoConstraints = false
        return shadowButton
    }()
    private lazy var handleView: UIView = {
        let handleView = UIView()
        handleView.translatesAutoresizingMaskIntoConstraints = false
        handleView.layer.cornerRadius = 2
        handleView.backgroundColor = self.handleColor
        return handleView
    }()
    private lazy var paneSeparatorView: UIView = {
        let separatorView = UIView()
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        separatorView.backgroundColor = self.paneSeparatorColor
        return separatorView
    }()
    private lazy var sideHandleView: UIView = {
        let sideHandleView = UIView()
        sideHandleView.translatesAutoresizingMaskIntoConstraints = false
        sideHandleView.backgroundColor = UIColor.clearColor()
        sideHandleView.addSubview(self.handleView)
        sideHandleView.addSubview(self.paneSeparatorView)
        let views = ["handleView": self.handleView, "paneSeparatorView": self.paneSeparatorView]
        sideHandleView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[paneSeparatorView(==1)]-3-[handleView(==4)]", options: [], metrics: nil, views: views))
        sideHandleView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[handleView(==44)]", options: [], metrics: nil, views: views))
        sideHandleView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[paneSeparatorView]|", options: [], metrics: nil, views: views))
        sideHandleView.addConstraint(NSLayoutConstraint(item: self.handleView, attribute: .CenterY, relatedBy: .Equal, toItem: sideHandleView, attribute: .CenterY, multiplier: 1, constant: 0))
        return sideHandleView
    }()
    
    public init(primaryViewController: UIViewController, secondaryViewController: UIViewController) {
        self.primaryViewController = primaryViewController
        self.secondaryViewController = secondaryViewController
        
        super.init(nibName: nil, bundle: nil)
        
        addChildViewController(primaryViewController)
        primaryViewController.didMoveToParentViewController(self)
        
        addChildViewController(secondaryViewController)
        secondaryViewController.didMoveToParentViewController(self)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        
        primaryViewController.view.frame = view.bounds
        primaryViewController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(primaryViewController.view)
        
        view.addSubview(secondaryViewSideContainerView)
        
        view.addSubview(secondaryViewModalContainerView)
        
        let views = ["view": view, "primaryView": primaryViewController.view, "secondaryViewSideContainerView": secondaryViewSideContainerView, "secondaryViewModalContainerView": secondaryViewModalContainerView, "sideHandleView": sideHandleView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[primaryView][secondaryViewSideContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[secondaryViewModalContainerView(==view)]", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[primaryView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[secondaryViewSideContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[secondaryViewModalContainerView]|", options: [], metrics: nil, views: views))
        
        secondaryViewSideContainerView.addSubview(sideHandleView)
        let secondaryViewSideContainerWidthConstraint = NSLayoutConstraint(item: secondaryViewSideContainerView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
        secondaryViewSideContainerView.addConstraint(secondaryViewSideContainerWidthConstraint)
        self.secondaryViewSideContainerDraggingWidthConstraint = secondaryViewSideContainerWidthConstraint
        secondaryViewSideContainerDraggingWidthConstraint?.active = false
        secondaryViewSideContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[sideHandleView(==10)]", options: [], metrics: nil, views: views))
        secondaryViewSideContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[sideHandleView]|", options: [], metrics: nil, views: views))
        // We need a constraint for the width to make it off screen
        updateSecondaryViewSideBySideConstraintForEnum(.Set0)
        
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
    
    override public func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        // If they're going from Regular to Compact, save off the width enum so we can restore it if they go back
        if newCollection.horizontalSizeClass == .Compact && traitCollection.horizontalSizeClass == .Regular {
            previousRegularSizeClassSecondaryViewSideContainerWidthEnum = secondaryViewSideContainerWidthEnum
        }
        
        // We also want to show the default side view had they not had the side view showing, but did have the modal showing
        if newCollection.horizontalSizeClass == .Regular && traitCollection.horizontalSizeClass == .Compact && previousRegularSizeClassSecondaryViewSideContainerWidthEnum == .Set0 && isSecondaryViewShowing {
            previousRegularSizeClassSecondaryViewSideContainerWidthEnum = .Set320
        }
        
        updateSecondaryViewLocationForTraitCollection(newCollection)
        
        // If we're going back to Regular from Compact, restore the secondary view width enum
        if newCollection.horizontalSizeClass == .Regular && traitCollection.horizontalSizeClass == .Compact {
            updateSecondaryViewSideBySideConstraintForEnum(previousRegularSizeClassSecondaryViewSideContainerWidthEnum)
        }
    }
    
    // MARK: Touch methods
    
    override public func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        
        guard let firstTouch = touches.first else { return }
        
        let location = firstTouch.locationInView(secondaryViewSideContainerView)
        let touchRect = CGRect(x: location.x - 22, y: location.y, width: 22, height: 44)
        if touchRect.intersects(sideHandleView.frame) {
            primaryViewWillChangeWidthObservers.notify(primaryViewController.view)
            isDragging = true
            secondaryViewSideContainerDraggingWidthConstraint?.constant = secondaryViewSideContainerView.bounds.width
            secondaryViewSideContainerDraggingWidthConstraint?.active = true
            secondaryViewSideContainerCurrentWidthConstraint?.active = false
        }
    }
    
    override public func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesMoved(touches, withEvent: event)

        guard isDragging, let firstTouch = touches.first else { return }
        
        let location = firstTouch.previousLocationInView(view)
        secondaryViewSideContainerDraggingWidthConstraint?.constant = abs(location.x - view.bounds.width)
    }
    
    override public func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        
        touchesEndedOrCancelled()
    }
    
    override public func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        super.touchesCancelled(touches, withEvent: event)
        
        touchesEndedOrCancelled()
    }
    
    // MARK: Methods
    
    override public func showSecondaryViewAnimated(animated: Bool) {
        guard !isSecondaryViewShowing else { return }
        
        isSecondaryViewShowing = true
        
        switch traitCollection.horizontalSizeClass {
        case .Regular:
            primaryViewWillChangeWidthObservers.notify(primaryViewController.view)
            updateSecondaryViewSideBySideConstraintForEnum(.Set320)
        case .Compact, .Unspecified:
            secondaryViewModalContainerHiddenLeadingConstraint?.active = false
            secondaryViewModalContainerShowingLeadingConstraint?.active = true
        }
        
        UIView.animateWithDuration(animated ? 0.3 : 0, animations: {
            self.view.layoutIfNeeded()
            self.modalShadowCloseButton.alpha = 1
        }) { _ in
            if self.traitCollection.horizontalSizeClass == .Regular {
                self.primaryViewDidChangeWidthObservers.notify(self.primaryViewController.view)
            }
        }
    }
    
    override public func dismissSecondaryViewAnimated(animated: Bool) {
        guard isSecondaryViewShowing else { return }
        
        isSecondaryViewShowing = false
        
        switch traitCollection.horizontalSizeClass {
        case .Regular:
            primaryViewWillChangeWidthObservers.notify(primaryViewController.view)
            updateSecondaryViewSideBySideConstraintForEnum(.Set0)
        case .Compact, .Unspecified:
            secondaryViewModalContainerHiddenLeadingConstraint?.active = true
            secondaryViewModalContainerShowingLeadingConstraint?.active = false
        }
        
        UIView.animateWithDuration(animated ? 0.3 : 0, animations: {
            self.view.layoutIfNeeded()
            self.modalShadowCloseButton.alpha = 0
        }) { _ in
            if self.traitCollection.horizontalSizeClass == .Regular {
                self.primaryViewDidChangeWidthObservers.notify(self.primaryViewController.view)
            }
        }
    }
    
    private func touchesEndedOrCancelled() {
        if isDragging {
            isDragging = false
            secondaryViewSideContainerDraggingWidthConstraint?.active = false
            secondaryViewSideContainerCurrentWidthConstraint?.active = true
            moveSideViewToPredeterminedPositionClosetToWidthAnimated(true)
        }
    }
    
    private func updateSecondaryViewSideBySideConstraintForEnum(predeterminedWidth: PredeterminedWidth) {
        if let secondaryViewSideContainerCurrentWidthConstraint = secondaryViewSideContainerCurrentWidthConstraint {
            secondaryViewSideContainerView.removeConstraint(secondaryViewSideContainerCurrentWidthConstraint)
            view.removeConstraint(secondaryViewSideContainerCurrentWidthConstraint)
        }
        
        secondaryViewSideContainerWidthEnum = predeterminedWidth
        
        let newSideSecondaryViewWidthConstraint: NSLayoutConstraint
        switch predeterminedWidth {
        case .Half:
            isSecondaryViewShowing = true
            newSideSecondaryViewWidthConstraint = NSLayoutConstraint(item: secondaryViewSideContainerView, attribute: .Width, relatedBy: .Equal, toItem: primaryViewController.view, attribute: .Width, multiplier: 1, constant: 0)
            view.addConstraint(newSideSecondaryViewWidthConstraint)
        case .Set320:
            isSecondaryViewShowing = true
            newSideSecondaryViewWidthConstraint = NSLayoutConstraint(item: secondaryViewSideContainerView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 320)
            secondaryViewSideContainerView.addConstraint(newSideSecondaryViewWidthConstraint)
        case .Set0:
            isSecondaryViewShowing = false
            newSideSecondaryViewWidthConstraint = NSLayoutConstraint(item: secondaryViewSideContainerView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 0)
            secondaryViewSideContainerView.addConstraint(newSideSecondaryViewWidthConstraint)
        }
        
        secondaryViewSideContainerCurrentWidthConstraint = newSideSecondaryViewWidthConstraint
    }
    
    private func moveSideViewToPredeterminedPositionClosetToWidthAnimated(animated: Bool) {
        let fullWidth = view.bounds.width
        let currentWidth = secondaryViewSideContainerView.bounds.width
        let predeterminedWidthEnums: [PredeterminedWidth] = [.Half, .Set320, .Set0]
        var bestPredeterminedWidthEnum = PredeterminedWidth.Set0
        for possibleWidthEnum in predeterminedWidthEnums {
            if abs(currentWidth - bestPredeterminedWidthEnum.currentValueForFullWidth(fullWidth)) > abs(currentWidth - possibleWidthEnum.currentValueForFullWidth(fullWidth)) {
                bestPredeterminedWidthEnum = possibleWidthEnum
            }
        }
        
        updateSecondaryViewSideBySideConstraintForEnum(bestPredeterminedWidthEnum)
        
        UIView.animateWithDuration(animated ? 0.3 : 0, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            self.primaryViewDidChangeWidthObservers.notify(self.primaryViewController.view)
        }
    }
    
    func shadowButtonTapped() {
        dismissSecondaryViewAnimated(true)
    }
    
    private func updateSecondaryViewLocationForTraitCollection(traitCollection: UITraitCollection) {
        dismissSecondaryViewAnimated(false)
        
        switch traitCollection.horizontalSizeClass {
        case .Regular:
            secondaryViewController.view.frame = secondaryViewSideContainerView.bounds
            secondaryViewController.view.translatesAutoresizingMaskIntoConstraints = true
            secondaryViewSideContainerView.insertSubview(secondaryViewController.view, atIndex: 0)
        case .Compact, .Unspecified:
            secondaryViewController.view.translatesAutoresizingMaskIntoConstraints = false
            secondaryViewModalContainerView.addSubview(secondaryViewController.view)
            
            let views = ["secondaryView": secondaryViewController.view, "shadowButton": modalShadowCloseButton]
            secondaryViewModalContainerView.removeConstraints(modalShadowCloseButton.constraints)
            secondaryViewModalContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[shadowButton(==24)][secondaryView]|", options: [], metrics: nil, views: views))
            secondaryViewModalContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[shadowButton]|", options: [], metrics: nil, views: views))
            secondaryViewModalContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[secondaryView]|", options: [], metrics: nil, views: views))
        }
    }
    
}
