//
//  AppDelegate.swift
//  PaneViewController
//
//  Created by Branden Russell on 2/25/16.
//  Copyright © 2016 Intellectual Reserve, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let primaryNavigationController = UINavigationController(rootViewController: DemoPrimaryViewController())
        let secondaryNavigationController = UINavigationController(rootViewController: DemoSecondaryViewController())
        window?.rootViewController = PaneViewController(primaryViewController: primaryNavigationController, secondaryViewController: secondaryNavigationController)
        window?.makeKeyAndVisible()
        
        return true
    }
    
}
