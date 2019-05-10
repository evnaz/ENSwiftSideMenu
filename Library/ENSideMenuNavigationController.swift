//
//  RootNavigationViewController.swift
//  SwiftSideMenu
//
//  Created by Evgeny Nazarov on 29.09.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

open class ENSideMenuNavigationController: UINavigationController, ENSideMenuProtocol {

    open var sideMenu : ENSideMenu?
    open var sideMenuAnimationType : ENSideMenuAnimation = .default


    // MARK: - Life cycle
    open override func viewDidLoad() {
        super.viewDidLoad()
    }

    public init( menuViewController: UIViewController, contentViewController: UIViewController?) {
        super.init(nibName: nil, bundle: nil)

        if (contentViewController != nil) {
            self.viewControllers = [contentViewController!]
        }

        sideMenu = ENSideMenu(sourceView: self.view, menuViewController: menuViewController, menuPosition:.left)
        view.bringSubviewToFront(navigationBar)
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Navigation
    open func setContentViewController(_ contentViewController: UIViewController) {
        self.sideMenu?.toggleMenu()
        switch sideMenuAnimationType {
        case .none:
            self.viewControllers = [contentViewController]
            break
        default:
            contentViewController.navigationItem.hidesBackButton = true
            self.setViewControllers([contentViewController], animated: true)
            break
        }

    }

}
