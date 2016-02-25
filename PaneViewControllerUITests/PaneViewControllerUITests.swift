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
    
    func testPrimaryAndSecondaryViewsAppearInRegularHorizontal() {
        let app = XCUIApplication()
        if app.horizontalSizeClass == .Regular {
            XCTAssertTrue(app.staticTexts["Primary View"].exists)
            XCTAssertTrue(app.staticTexts["Secondary View"].exists)
        }
    }
    
    func testOnlyPrimaryViewAppearsInCompactHorizontal() {
        let app = XCUIApplication()
        if app.horizontalSizeClass == .Compact {
            XCTAssertTrue(app.staticTexts["Primary View"].exists)
            XCTAssertFalse(app.staticTexts["Secondary View"].exists)
        }
    }
    
}
