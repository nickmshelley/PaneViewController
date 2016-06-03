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
    
    public enum PresentationMode {
        case SideBySide
        case Modal
    }
    
    public let primaryViewController: UIViewController
    public let secondaryViewController: UIViewController
    public let primaryViewWillChangeWidthObservers = ObserverSet<UIView>()
    public let primaryViewDidChangeWidthObservers = ObserverSet<UIView>()
    
    public private(set) var presentationMode = PresentationMode.Modal
    public private(set) var isSecondaryViewShowing = false
    public var primaryViewToBlur: UIView?
    public var secondaryViewToBlur: UIView?
    public var shouldBlurWhenSideBySideResizes = true
    public var shouldAllowDragModal = true
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
                modalShadowView.backgroundColor = modalShadowColor
            }
        }
    }
    
    public lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognized))
        panGestureRecognizer.delegate = self
        return panGestureRecognizer
    }()
    public lazy var modalShadowCloseTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized))
        return tapGestureRecognizer
    }()
    public lazy var modalHandleCloseTapGestureRecognizer: UITapGestureRecognizer = {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureRecognized))
        return tapGestureRecognizer
    }()
    
    private let modalOpenGap = CGFloat(20)
    
    private var touchStartedDownInHandle = false
    private var touchStartedWithSecondaryOpen = false
    private var secondaryViewSideContainerCurrentWidthConstraint: NSLayoutConstraint?
    private var secondaryViewSideContainerDraggingWidthConstraint: NSLayoutConstraint?
    private var secondaryViewModalContainerHiddenLeadingConstraint: NSLayoutConstraint?
    private var secondaryViewModalContainerShowingLeadingConstraint: NSLayoutConstraint?
    private var secondaryViewModalContainerWidthConstraint: NSLayoutConstraint?
    private var secondaryViewModalContainerOpenLocation = CGFloat(0)
    private var secondaryViewSideContainerWidthEnum = PredeterminedWidth.Set0
    private var previousRegularSizeSecondaryViewSideContainerWidthEnum = PredeterminedWidth.Set0
    
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
    private lazy var modalShadowView: UIView = {
        let shadowView = UIView()
        shadowView.alpha = 0
        shadowView.backgroundColor = self.modalShadowColor
        shadowView.translatesAutoresizingMaskIntoConstraints = false
        return shadowView
    }()
    private lazy var modalShadowImageView: UIImageView = {
        let shadowImageView = UIImageView(image: UIImage(named: "modalEdgeShadow", inBundle: NSBundle(forClass: PaneViewController.self), compatibleWithTraitCollection: nil))
        shadowImageView.alpha = 0
        shadowImageView.translatesAutoresizingMaskIntoConstraints = false
        return shadowImageView
    }()
    private lazy var sideHandleTouchView: UIView = {
        let touchHandleView = HandleView()
        touchHandleView.delegate = self
        touchHandleView.backgroundColor = .clearColor()
        touchHandleView.translatesAutoresizingMaskIntoConstraints = false
        return touchHandleView
    }()
    private lazy var modalHandleTouchView: UIView = {
        let touchHandleView = HandleView()
        touchHandleView.delegate = self
        touchHandleView.backgroundColor = .clearColor()
        touchHandleView.translatesAutoresizingMaskIntoConstraints = false
        return touchHandleView
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
        let separatorLineWidth: CGFloat = 1.0 / UIScreen.mainScreen().scale
        let metrics = ["separatorLineWidth": separatorLineWidth]
        sideHandleView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[paneSeparatorView(==separatorLineWidth)]-3-[handleView(==4)]", options: [], metrics: metrics, views: views))
        sideHandleView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[handleView(==44)]", options: [], metrics: nil, views: views))
        sideHandleView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[paneSeparatorView]|", options: [], metrics: nil, views: views))
        sideHandleView.addConstraint(NSLayoutConstraint(item: self.handleView, attribute: .CenterY, relatedBy: .Equal, toItem: sideHandleView, attribute: .CenterY, multiplier: 1, constant: 0))
        return sideHandleView
    }()
    private lazy var primaryVisualEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visualEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        return visualEffectView
    }()
    private lazy var secondaryVisualEffectView: UIVisualEffectView = {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
        visualEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        return visualEffectView
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
        view.addSubview(sideHandleTouchView)
        view.addSubview(modalHandleTouchView)
        
        primaryViewController.view.addSubview(modalShadowView)
        
        let views = ["view": view, "primaryView": primaryViewController.view, "secondaryViewSideContainerView": secondaryViewSideContainerView, "secondaryViewModalContainerView": secondaryViewModalContainerView, "sideHandleView": sideHandleView, "modalShadowView": modalShadowView, "sideHandleTouchView": sideHandleTouchView, "modalHandleTouchView": modalHandleTouchView]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[primaryView][secondaryViewSideContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[primaryView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[secondaryViewSideContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[secondaryViewModalContainerView]|", options: [], metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[sideHandleTouchView]|", options: [], metrics: nil, views: views))
        let secondaryViewModalContainerWidthConstraint = NSLayoutConstraint(item: secondaryViewModalContainerView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: view.bounds.width)
        secondaryViewModalContainerView.addConstraint(secondaryViewModalContainerWidthConstraint)
        self.secondaryViewModalContainerWidthConstraint = secondaryViewModalContainerWidthConstraint
        
        primaryViewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[modalShadowView]|", options: [], metrics: nil, views: views))
        primaryViewController.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[modalShadowView]|", options: [], metrics: nil, views: views))
        
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
        
        // Center the side touch to the handle view
        sideHandleTouchView.addConstraint(NSLayoutConstraint(item: sideHandleTouchView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 88))
        view.addConstraint(NSLayoutConstraint(item: sideHandleTouchView, attribute: .CenterX, relatedBy: .Equal, toItem: handleView, attribute: .CenterX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: sideHandleTouchView, attribute: .CenterY, relatedBy: .Equal, toItem: handleView, attribute: .CenterY, multiplier: 1, constant: 0))
        
        modalHandleTouchView.addConstraint(NSLayoutConstraint(item: modalHandleTouchView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: 110))
        view.addConstraint(NSLayoutConstraint(item: modalHandleTouchView, attribute: .Leading, relatedBy: .Equal, toItem: secondaryViewModalContainerView, attribute: .Leading, multiplier: 1, constant: -44))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[modalHandleTouchView]|", options: [], metrics: nil, views: views))
        
        updateSecondaryViewLocationForTraitCollection(traitCollection)
        
        updateSizeClassOfChildViewControllers()
        
        view.addGestureRecognizer(panGestureRecognizer)
        modalShadowView.addGestureRecognizer(modalShadowCloseTapGestureRecognizer)
        modalHandleTouchView.addGestureRecognizer(modalHandleCloseTapGestureRecognizer)
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !touchStartedDownInHandle {
            // Find the narrow side and make it so the modal only goes out that far, even in the other orientation
            if traitCollection.horizontalSizeClass == .Compact || traitCollection.verticalSizeClass == .Compact {
                let narrowestSide = min(view.bounds.height, view.bounds.width)
                secondaryViewModalContainerOpenLocation = view.bounds.width - narrowestSide
                secondaryViewModalContainerWidthConstraint?.constant = narrowestSide
                
                if isSecondaryViewShowing {
                    secondaryViewModalContainerShowingLeadingConstraint?.constant = secondaryViewModalContainerOpenLocation
                }
            } else {
                secondaryViewModalContainerOpenLocation = 0
            }
        }
    }
    
    override public func willTransitionToTraitCollection(newCollection: UITraitCollection, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransitionToTraitCollection(newCollection, withTransitionCoordinator: coordinator)
        
        // If they're going from Regular to Compact, save off the width enum so we can restore it if they go back
        if newCollection.horizontalSizeClass == .Compact && traitCollection.horizontalSizeClass == .Regular {
            previousRegularSizeSecondaryViewSideContainerWidthEnum = secondaryViewSideContainerWidthEnum
        }
        
        // We also want to show the default side view had they not had the side view showing, but did have the modal showing
        if newCollection.horizontalSizeClass == .Regular && traitCollection.horizontalSizeClass == .Compact && previousRegularSizeSecondaryViewSideContainerWidthEnum == .Set0 && isSecondaryViewShowing {
            previousRegularSizeSecondaryViewSideContainerWidthEnum = .Set320
        }
        
        // Close the secondary view if we're changing from compact to regular or regular to compact
        if newCollection.horizontalSizeClass != traitCollection.horizontalSizeClass {
            dismissSecondaryViewAnimated(false)
        }
        
        updateSecondaryViewLocationForTraitCollection(newCollection)
        
        // If we're going back to Regular from Compact, restore the secondary view width enum
        if newCollection.horizontalSizeClass == .Regular && traitCollection.horizontalSizeClass == .Compact {
            updateSecondaryViewSideBySideConstraintForEnum(previousRegularSizeSecondaryViewSideContainerWidthEnum)
        }
    }
    
    public override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        updateSizeClassOfChildViewControllers()
    }
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ _ in
            self.updateSizeClassOfChildViewControllers()
        }, completion: nil)
    }
    
    func panGestureRecognized(gestureRecognizer: UIPanGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Began:
            // Ignore if they're moving up/down too much
            guard abs(gestureRecognizer.velocityInView(view).y) < abs(gestureRecognizer.velocityInView(view).x) else { break }
            
            touchStartedWithSecondaryOpen = isSecondaryViewShowing
            
            switch presentationMode {
            case .SideBySide:
                if sideHandleTouchView.frame.contains(gestureRecognizer.locationInView(view)) {
                    primaryViewWillChangeWidthObservers.notify(primaryViewController.view)
                    touchStartedDownInHandle = true
                    secondaryViewSideContainerDraggingWidthConstraint?.constant = secondaryViewSideContainerView.bounds.width
                    secondaryViewSideContainerDraggingWidthConstraint?.active = true
                    secondaryViewSideContainerCurrentWidthConstraint?.active = false
                    
                    blurIfNeeded()
                }
            case .Modal:
                if modalHandleTouchView.frame.contains(gestureRecognizer.locationInView(view)) ||
                    (shouldAllowDragModal && secondaryViewModalContainerView.frame.contains(gestureRecognizer.locationInView(view))) {
                    // This allows the view to be dragged onto the screen from the right
                    if !isSecondaryViewShowing {
                        isSecondaryViewShowing = true
                        modalShadowImageView.alpha = 1
                        secondaryViewModalContainerShowingLeadingConstraint?.constant = view.bounds.width
                        secondaryViewModalContainerHiddenLeadingConstraint?.active = false
                        secondaryViewModalContainerShowingLeadingConstraint?.active = true
                    }
                    touchStartedDownInHandle = true
                }
            }
        case .Changed:
            guard touchStartedDownInHandle else {
                // Cancel the recognition
                gestureRecognizer.enabled = false
                gestureRecognizer.enabled = true
                return
            }
            
            let location = gestureRecognizer.locationInView(view)
            switch presentationMode {
            case .SideBySide:
                secondaryViewSideContainerDraggingWidthConstraint?.constant = abs(location.x - view.bounds.width)
                primaryViewDidChangeWidthObservers.notify(primaryViewController.view)
            case .Modal:
                secondaryViewModalContainerShowingLeadingConstraint?.constant = max(location.x - modalOpenGap, secondaryViewModalContainerOpenLocation)
                modalShadowView.alpha = 1.0 - (location.x / view.bounds.width)
            }
        case .Ended, .Failed, .Cancelled:
            guard touchStartedDownInHandle else { return }
            
            switch presentationMode {
            case .SideBySide:
                secondaryViewSideContainerDraggingWidthConstraint?.active = false
                secondaryViewSideContainerCurrentWidthConstraint?.active = true
                moveSideViewToPredeterminedPositionClosestToWidthAnimated(true)
                primaryViewDidChangeWidthObservers.notify(primaryViewController.view)
            case .Modal:
                // If they tapped or dragged past the first quarter of the screen (if secondary was open) or drag only to the first quarter of the screen (if secondary started closed), close (again)
                let dragVelocity = gestureRecognizer.velocityInView(view).x
                if dragVelocity > 10 ||
                    (dragVelocity > -10 &&
                        (secondaryViewModalContainerShowingLeadingConstraint?.constant > (view.bounds.width * 0.25) + secondaryViewModalContainerOpenLocation && touchStartedWithSecondaryOpen) ||
                        (secondaryViewModalContainerShowingLeadingConstraint?.constant > (view.bounds.width * 0.75) + secondaryViewModalContainerOpenLocation && !touchStartedWithSecondaryOpen)) {
                    secondaryViewModalContainerShowingLeadingConstraint?.constant = secondaryViewModalContainerOpenLocation
                    dismissSecondaryViewAnimated(true)
                } else {
                    // Fake that the view wasn't showing so we can animate back into place
                    isSecondaryViewShowing = false
                    showSecondaryViewAnimated(true)
                }
            }
            
            touchStartedDownInHandle = false
        case .Possible:
            break
        }
    }
    
    func tapGestureRecognized(gestureRecognizer: UITapGestureRecognizer) {
        switch gestureRecognizer.state {
        case .Ended:
            dismissSecondaryViewAnimated(true)
        case _:
            break
        }
    }
    
    // MARK: Methods
    
    override public func showSecondaryViewAnimated(animated: Bool) {
        guard !isSecondaryViewShowing else { return }
        
        isSecondaryViewShowing = true
        
        let modalShadowViewAlpha: CGFloat
        switch traitCollection.horizontalSizeClass {
        case .Regular:
            modalShadowViewAlpha = 0
            blurIfNeeded()
            primaryViewWillChangeWidthObservers.notify(primaryViewController.view)
            updateSecondaryViewSideBySideConstraintForEnum(.Set320)
        case .Compact, .Unspecified:
            primaryViewController.view.addSubview(modalShadowView)
            modalShadowViewAlpha = 1
            secondaryViewModalContainerShowingLeadingConstraint?.constant = secondaryViewModalContainerOpenLocation
            secondaryViewModalContainerHiddenLeadingConstraint?.active = false
            secondaryViewModalContainerShowingLeadingConstraint?.active = true
        }
        
        modalShadowImageView.alpha = modalShadowViewAlpha
        let startingHorizontalSizeClass = self.traitCollection.horizontalSizeClass
        UIView.animateWithDuration(animated ? 0.3 : 0, animations: {
            self.view.layoutIfNeeded()
            self.modalShadowView.alpha = modalShadowViewAlpha
        }, completion: { _ in
            self.removeBlurIfNeeded()
            self.updateSizeClassOfChildViewControllers()
            if startingHorizontalSizeClass == .Regular {
                self.primaryViewDidChangeWidthObservers.notify(self.primaryViewController.view)
            }
        })
    }
    
    override public func dismissSecondaryViewAnimated(animated: Bool) {
        guard isSecondaryViewShowing else { return }
        
        isSecondaryViewShowing = false
        
        switch traitCollection.horizontalSizeClass {
        case .Regular:
            blurIfNeeded()
            primaryViewWillChangeWidthObservers.notify(primaryViewController.view)
            updateSecondaryViewSideBySideConstraintForEnum(.Set0)
        case .Compact, .Unspecified:
            secondaryViewModalContainerShowingLeadingConstraint?.active = false
            secondaryViewModalContainerHiddenLeadingConstraint?.active = true
        }
        
        let startingHorizontalSizeClass = self.traitCollection.horizontalSizeClass
        UIView.animateWithDuration(animated ? 0.3 : 0, animations: {
            self.view.layoutIfNeeded()
            self.modalShadowView.alpha = 0
        }, completion: { _ in
            self.modalShadowImageView.alpha = 0
            self.removeBlurIfNeeded()
            self.updateSizeClassOfChildViewControllers()
            if startingHorizontalSizeClass == .Regular {
                self.primaryViewDidChangeWidthObservers.notify(self.primaryViewController.view)
            }
        })
    }
    
    private func blurIfNeeded() {
        guard shouldBlurWhenSideBySideResizes && primaryVisualEffectView.superview == nil && secondaryVisualEffectView.superview == nil else { return }
        
        if let primaryView = primaryViewToBlur {
            primaryView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            primaryView.alpha = 0
            primaryView.frame = primaryViewController.view.bounds
            primaryViewController.view.addSubview(primaryView)
        }
        
        primaryVisualEffectView.alpha = 0
        primaryVisualEffectView.frame = primaryViewController.view.bounds
        primaryViewController.view.addSubview(primaryVisualEffectView)
        
        if let secondaryView = secondaryViewToBlur {
            secondaryView.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            secondaryView.alpha = 0
            secondaryView.frame = secondaryViewController.view.bounds
            secondaryViewController.view.addSubview(secondaryView)
        }
        
        secondaryVisualEffectView.alpha = 0
        secondaryVisualEffectView.frame = secondaryViewController.view.bounds
        secondaryViewController.view.addSubview(secondaryVisualEffectView)
        
        UIView.animateWithDuration(0.1) {
            self.primaryViewToBlur?.alpha = 1
            self.primaryVisualEffectView.alpha = 1
            self.secondaryViewToBlur?.alpha = 1
            self.secondaryVisualEffectView.alpha = 1
        }
    }
    
    private func removeBlurIfNeeded() {
        guard primaryVisualEffectView.superview != nil && secondaryVisualEffectView.superview != nil else { return }
        
        UIView.animateWithDuration(0.1, animations: {
            self.primaryViewToBlur?.alpha = 0
            self.primaryVisualEffectView.alpha = 0
            self.secondaryViewToBlur?.alpha = 0
            self.secondaryVisualEffectView.alpha = 0
        }, completion: { _ in
            self.primaryViewToBlur?.removeFromSuperview()
            self.primaryVisualEffectView.removeFromSuperview()
            self.secondaryViewToBlur?.removeFromSuperview()
            self.secondaryVisualEffectView.removeFromSuperview()
        })
    }
    
    private func updateSizeClassOfChildViewControllers() {
        // The vertical size class will be the same as self's
        let compactTraitCollection = UITraitCollection(traitsFromCollections: [UITraitCollection(verticalSizeClass: traitCollection.verticalSizeClass), UITraitCollection(horizontalSizeClass: .Compact)])
        let regularTraitCollection = UITraitCollection(traitsFromCollections: [UITraitCollection(verticalSizeClass: traitCollection.verticalSizeClass), UITraitCollection(horizontalSizeClass: .Regular)])
        
        // If self is Regular, the child controllers may be Compact
        // If self is Compact, the child controllers are all Compact
        switch traitCollection.horizontalSizeClass {
        case .Regular:
            // This value seemed to be a good one on iPad to choose when subviews should be compact or not
            setOverrideTraitCollection(primaryViewController.view.bounds.width >= 500 ? regularTraitCollection : compactTraitCollection, forChildViewController: primaryViewController)
            setOverrideTraitCollection(secondaryViewController.view.bounds.width >= 500 ? regularTraitCollection : compactTraitCollection, forChildViewController: secondaryViewController)
        case .Compact, .Unspecified:
            setOverrideTraitCollection(compactTraitCollection, forChildViewController: primaryViewController)
            setOverrideTraitCollection(compactTraitCollection, forChildViewController: secondaryViewController)
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
    
    private func moveSideViewToPredeterminedPositionClosestToWidthAnimated(animated: Bool) {
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
        }, completion: { _ in
            self.removeBlurIfNeeded()
            self.updateSizeClassOfChildViewControllers()
            self.primaryViewDidChangeWidthObservers.notify(self.primaryViewController.view)
        })
    }
    
    private func updateSecondaryViewLocationForTraitCollection(traitCollection: UITraitCollection) {
        switch traitCollection.horizontalSizeClass {
        case .Regular:
            presentationMode = .SideBySide
            sideHandleTouchView.userInteractionEnabled = true
            modalHandleTouchView.userInteractionEnabled = false
            secondaryViewController.view.frame = secondaryViewSideContainerView.bounds
            secondaryViewController.view.translatesAutoresizingMaskIntoConstraints = true
            secondaryViewSideContainerView.insertSubview(secondaryViewController.view, atIndex: 0)
        case .Compact, .Unspecified:
            presentationMode = .Modal
            sideHandleTouchView.userInteractionEnabled = false
            modalHandleTouchView.userInteractionEnabled = true
            secondaryViewController.view.translatesAutoresizingMaskIntoConstraints = false
            secondaryViewModalContainerView.addSubview(secondaryViewController.view)
            secondaryViewModalContainerView.addSubview(modalShadowImageView)
            
            let views = ["secondaryView": secondaryViewController.view, "modalShadowImageView": modalShadowImageView]
            let metrics = ["modalOpenGap": modalOpenGap]
            secondaryViewModalContainerView.removeConstraints(modalShadowView.constraints)
            secondaryViewModalContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[modalShadowImageView][secondaryView]|", options: [], metrics: nil, views: views))
            secondaryViewModalContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-modalOpenGap-[secondaryView]|", options: [], metrics: metrics, views: views))
            secondaryViewModalContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[secondaryView]|", options: [], metrics: nil, views: views))
            secondaryViewModalContainerView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[modalShadowImageView]|", options: [], metrics: nil, views: views))
        }
    }
    
}

extension PaneViewController: HandleViewDelegate {
    
    func hitTest(point: CGPoint, withEvent event: UIEvent?, inView: UIView) -> UIView? {
        let mainViewPoint = inView.convertPoint(point, toView: view)
        if secondaryViewModalContainerView.frame.contains(mainViewPoint) || secondaryViewSideContainerView.frame.contains(mainViewPoint) {
            let convertedPoint = inView.convertPoint(point, toView: secondaryViewController.view)
            return secondaryViewController.view.hitTest(convertedPoint, withEvent: event)
        }
        
        let convertedPoint = inView.convertPoint(point, toView: primaryViewController.view)
        return primaryViewController.view.hitTest(convertedPoint, withEvent: event)
    }
    
}

extension PaneViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
