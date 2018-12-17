//
//  SharedCoordinator.swift
//  NoBus
//
//  Created by Gao on 2018/12/17.
//  Copyright © 2018 me.leavez. All rights reserved.
//

import UIKit

class SharedCoordinator {
    
    let window: UIWindow
    let navigationControlelr: UINavigationController
    
    init() {
        window = UIWindow(frame: UIScreen.main.bounds)
        navigationControlelr = UINavigationController()
        navigationControlelr.navigationBar.isHidden = true

        let rootVC = CardListViewController()
        navigationControlelr.pushViewController(rootVC, animated: false)
        window.rootViewController = navigationControlelr
    }
    
    func start() {
        window.makeKeyAndVisible()
    }
}
