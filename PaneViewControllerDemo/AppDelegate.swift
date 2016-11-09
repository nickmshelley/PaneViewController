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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let primaryNavigationController = UINavigationController(rootViewController: DemoPrimaryViewController())
        let secondaryNavigationController = UINavigationController(rootViewController: DemoSecondaryViewController())
        let paneViewController = PaneViewController(primaryViewController: primaryNavigationController, secondaryViewController: secondaryNavigationController)
        window?.rootViewController = paneViewController
        let secondaryViewToBlur = UIView()
        secondaryViewToBlur.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 1, alpha: 0.5)
        paneViewController.secondaryViewToBlur = secondaryViewToBlur
        window?.makeKeyAndVisible()
        
        return true
    }
    
}
