//
//  AppDelegate.swift
//  NoBus
//
//  Created by Gao on 2018/10/24.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let coordinator = SharedCoordinator()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = coordinator.window
        coordinator.start()
        return true
    }



}

