//
//  PaneViewControllerUITests.swift
//  PaneViewControllerUITests
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import XCTest

@available(iOS 9.0, *)
class PaneViewControllerUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    
    func testShowHideSide() {
        let app = XCUIApplication()
        XCTAssertTrue(app.staticTexts["Primary View"].hittable)
        app.buttons["Show"].tap()
        // The primary view should be covered in Compact, but not in Regular
        if app.windows.elementBoundByIndex(0).horizontalSizeClass == .Compact {
            XCTAssertFalse(app.staticTexts["Primary View"].hittable)
        } else {
            XCTAssertTrue(app.staticTexts["Primary View"].hittable)
        }
        XCTAssertTrue(app.staticTexts["Secondary View"].hittable)
        // Now close the drawer
        app.buttons["X"].tap()
        XCTAssertTrue(app.staticTexts["Primary View"].hittable)
    }
    
}
