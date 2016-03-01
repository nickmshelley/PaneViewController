//
//  PaneViewControllerTests.swift
//  PaneViewControllerTests
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import XCTest
@testable import PaneViewController

class PaneViewControllerTests: XCTestCase {
    
    func testAddingPrimaryViewControllerInInit() {
        let demoPrimaryViewController = DemoPrimaryViewController()
        let demoSecondaryViewController = DemoSecondaryViewController()
        let paneViewController = PaneViewController(primaryViewController: demoPrimaryViewController, secondaryViewController: demoSecondaryViewController)
        XCTAssertEqual(paneViewController.primaryViewController, demoPrimaryViewController)
        XCTAssertEqual(paneViewController.secondaryViewController, demoSecondaryViewController)
    }
    
    func testGettingPaneViewControllerFromPaneViewController() {
        let paneViewController = PaneViewController(primaryViewController: DemoPrimaryViewController(), secondaryViewController: DemoSecondaryViewController())
        XCTAssertEqual(paneViewController.paneViewController(), paneViewController)
    }
    
    func testGettingPaneViewControllerFromPrimary() {
        let demoPrimaryViewController = DemoPrimaryViewController()
        let paneViewController = PaneViewController(primaryViewController: demoPrimaryViewController, secondaryViewController: DemoSecondaryViewController())
        XCTAssertEqual(demoPrimaryViewController.paneViewController(), paneViewController)
    }
    
    func testGettingCurrentPaneViewControllerFromNavStackViewControllerInPrimary() {
        let primaryNavigationViewController = UINavigationController(rootViewController: DemoPrimaryViewController())
        let pushedOnViewController = UIViewController()
        primaryNavigationViewController.pushViewController(pushedOnViewController, animated: false)
        let paneViewController = PaneViewController(primaryViewController: primaryNavigationViewController, secondaryViewController: DemoSecondaryViewController())
        XCTAssertEqual(pushedOnViewController.paneViewController(), paneViewController)
    }
    
}
