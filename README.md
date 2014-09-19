ENSwiftSideMenu
===============

A simple side menu for iOS 7,8 written in Swift language. Using UIDynamics, UIGestures and UIBlurEffect, Access control.

##Demo
![](http://i.imgur.com/U5gvMTN.gif)

##Requirements
* Xcode 6
* iOS 7

##How to use
1. Copy the library foler from the project which contains three files - MenuTableViewController,SideMenu,SideMenuViewController.
2.Add the following code in AppDelegate viewDidFinishWithLaunchingFunction  (Code is self explanatory)

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        // Initial center view controller.
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let controller:UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController1") as UIViewController
        // A Object which will help in Navigation on the sideMenu.
        var menuNavigationHelper: SideMenuNavigationHelper = SideMenuNavigationHelper()

        // Setup the Side Menu Controller.
        var menuViewController: SideMenuViewController = SideMenuViewController(menuData: SideMenuNavigationHelper.mennuData(), centerController: controller)
        menuViewController.sideMenuProtocol = menuNavigationHelper
        var navigationController: UINavigationController = UINavigationController(rootViewController: menuViewController)
        self.window!.rootViewController = navigationController

3.   SideMenuNavigationHelper - A helper class which responds to SideMenuProtocol.It does the following functions.(A sample is provided with the project). 
    - Supply menu data.
    - Handle callback 'sideMenuDidSelectItem', initialize the appropriate viewController and call 'setCenterViewControllerTo'.

4. Customize menu table view cells in `MenuTableViewController.swift`.