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
        let paneViewController = PaneViewController(primaryViewController: demoPrimaryViewController)
        XCTAssertEqual(paneViewController.primaryViewController, demoPrimaryViewController)
    }
    
}
