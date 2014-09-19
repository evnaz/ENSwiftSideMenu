//
//  SideMenuNavigationHelper.swift
//  SwiftSideMenu
//
//  Created by Neeraj Kumar on 19/09/14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import Foundation
import UIKit

class SideMenuNavigationHelper: NSObject, SideMenuProtocol {
    var currentSelectedIndex: Int = -1
    
    class func mennuData() ->Array<String> {
        return ["MenuItem1", "MenuItem2", "MenuItem3", "MenuItem4"];
    }
    
    // SideMenuProtocol Implementation.
    func sideMenuDidSelectItemAtIndex(index:Int, viewController:SideMenuViewController!) {
        if (currentSelectedIndex != index) {
            currentSelectedIndex = index
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
            switch(index) {
            case 0:
                let controller:UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController1") as UIViewController
                viewController.setCenterViewControllerTo(controller)
            
            case 1:
                let controller:UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController2") as UIViewController
                viewController.setCenterViewControllerTo(controller)
            
            case 2:
                let controller:UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController3") as UIViewController
                viewController.setCenterViewControllerTo(controller)
                
            case 3:
                let controller:UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("ViewController4") as UIViewController
                viewController.setCenterViewControllerTo(controller)
                
            default:
                NSLog("Do nothing")
            }
        }
    }
    
}