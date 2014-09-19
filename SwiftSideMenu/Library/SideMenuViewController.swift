//
//  CenterContainerViewController.swift
//  SwiftSideMenu
//
//  Created by Neeraj Kumar on 19/09/14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol SideMenuProtocol {
    func sideMenuDidSelectItemAtIndex(index:Int, viewController:SideMenuViewController!)
    optional func sideMenuWillOpen()
    optional func sideMenuWillClose()
}

public class SideMenuViewController: UIViewController, SideMenuDelegate {
   private var sideMenu: SideMenu?
   public var sideMenuProtocol : SideMenuProtocol?
    
    func didTapToggleButton() {
        sideMenu?.toggleMenu()
    }
    // initializers.
     public init(menuData: Array<String>!, centerController: UIViewController) {
        super.init(nibName: nil, bundle: nil)
        sideMenu = SideMenu(sourceView: self.view, menuData: menuData)
        sideMenu!.delegate = self
        sideMenu?.selectRowAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: UITableViewScrollPosition.None)
        self.setCenterViewControllerTo(centerController)
    }
    
     public required init(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
   }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        var menuButton: UIBarButtonItem = UIBarButtonItem(title: "Toggle", style: UIBarButtonItemStyle.Plain, target: self, action:Selector("didTapToggleButton"))
        self.navigationItem.leftBarButtonItem = menuButton
    }
    
 
   // public functions
   public func setCenterViewControllerTo(viewController:UIViewController!) {
        // First remove all the child view controllers.
        var array: NSArray = self.childViewControllers as NSArray
        for controller in array {
            var viewCon : UIViewController = controller as UIViewController
            self.removeChildController(viewCon)
        }
        self.addChildController(viewController)
    }
    
    // Private functions.
    private func addChildController(viewController:UIViewController!) {
        self.addChildViewController(viewController)
        self.view.addSubview(viewController.view)
        self.view.sendSubviewToBack(viewController.view)
        viewController.didMoveToParentViewController(self)
    }
    private func removeChildController(viewController:UIViewController!) {
        viewController.didMoveToParentViewController(nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParentViewController()
    }
 
    // SideMenuDelegate
    func sideMenuDidSelectItemAtIndex(index:Int) {
        sideMenu?.toggleMenu()
        weak var weakSelf: SideMenuViewController? = self
        sideMenuProtocol?.sideMenuDidSelectItemAtIndex(index, viewController: weakSelf!)
    }
    
    func sideMenuWillClose() {
        sideMenuProtocol?.sideMenuWillClose?()
    }
    
    func sideMenuWillOpen() {
        sideMenuProtocol?.sideMenuWillOpen?()
    }
}