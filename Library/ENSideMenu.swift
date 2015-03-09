//
//  SideMenu.swift
//  SwiftSideMenu
//
//  Created by Evgeny on 24.07.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

@objc public protocol ENSideMenuDelegate {
    optional func sideMenuWillOpen()
    optional func sideMenuWillClose()
    optional func sideMenuShouldOpenSideMenu () -> Bool
}

@objc public protocol ENSideMenuProtocol {
    var sideMenu : ENSideMenu? { get }
    func setContentViewController(contentViewController: UIViewController)
}

public enum ENSideMenuAnimation : Int {
    case None
    case Default
}

public enum ENSideMenuPosition : Int {
    case Left
    case Right
}

public extension UIViewController {
    
    public func toggleSideMenuView () {
        sideMenuController()?.sideMenu?.toggleMenu()
    }
    
    public func hideSideMenuView () {
        sideMenuController()?.sideMenu?.hideSideMenu()
    }
    
    public func showSideMenuView () {
        
        sideMenuController()?.sideMenu?.showSideMenu()
    }
    
    public func sideMenuController () -> ENSideMenuProtocol? {
        var iteration : UIViewController? = self.parentViewController
        if (iteration == nil) {
            return topMostController()
        }
        do {
            if (iteration is ENSideMenuProtocol) {
                return iteration as? ENSideMenuProtocol
            } else if (iteration?.parentViewController != nil && iteration?.parentViewController != iteration) {
                iteration = iteration!.parentViewController;
            } else {
                iteration = nil;
            }
        } while (iteration != nil)
        
        return iteration as? ENSideMenuProtocol
    }
    
    internal func topMostController () -> ENSideMenuProtocol? {
        var topController : UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController
        while (topController?.presentedViewController is ENSideMenuProtocol) {
            topController = topController?.presentedViewController;
        }
        
        return topController as? ENSideMenuProtocol
    }
}

public class ENSideMenu : NSObject {
    
    public var menuWidth : CGFloat = 160.0 {
        didSet {
            needUpdateApperance = true
            updateFrame()
        }
    }
    private let menuPosition:ENSideMenuPosition = .Left
    public var bouncingEnabled :Bool = true
    private let sideMenuContainerView =  UIView()
    private var menuTableViewController : UITableViewController!
    private var animator : UIDynamicAnimator!
    private let sourceView : UIView!
    private var needUpdateApperance : Bool = false
    public weak var delegate : ENSideMenuDelegate?
    private var isMenuOpen : Bool = false
    
    public init(sourceView: UIView, menuPosition: ENSideMenuPosition) {
        super.init()
        self.sourceView = sourceView
        self.menuPosition = menuPosition
        self.setupMenuView()
    
        animator = UIDynamicAnimator(referenceView:sourceView)
        
        // Add right swipe gesture recognizer
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        rightSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirection.Right
        sourceView.addGestureRecognizer(rightSwipeGestureRecognizer)
        
        // Add left swipe gesture recognizer
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        
        if (menuPosition == .Left) {
            sourceView.addGestureRecognizer(rightSwipeGestureRecognizer)
            sideMenuContainerView.addGestureRecognizer(leftSwipeGestureRecognizer)
        }
        else {
            sideMenuContainerView.addGestureRecognizer(rightSwipeGestureRecognizer)
            sourceView.addGestureRecognizer(leftSwipeGestureRecognizer)
        }
        
    }

    public convenience init(sourceView: UIView, menuTableViewController: UITableViewController, menuPosition: ENSideMenuPosition) {
        self.init(sourceView: sourceView, menuPosition: menuPosition)
        self.menuTableViewController = menuTableViewController
        self.menuTableViewController.tableView.frame = sideMenuContainerView.bounds
        self.menuTableViewController.tableView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        sideMenuContainerView.addSubview(self.menuTableViewController.tableView)
    }
    
    private func updateFrame() {
        let menuFrame = CGRectMake(
            (menuPosition == .Left) ?
                isMenuOpen ? 0 : -menuWidth-1.0 :
                isMenuOpen ? sourceView.frame.size.width - menuWidth : sourceView.frame.size.width+1.0,
            sourceView.frame.origin.y,
            menuWidth,
            sourceView.frame.size.height
        )
        
        sideMenuContainerView.frame = menuFrame
    }

    private func setupMenuView() {
        
        // Configure side menu container
        updateFrame()

        sideMenuContainerView.backgroundColor = UIColor.clearColor()
        sideMenuContainerView.clipsToBounds = false
        sideMenuContainerView.layer.masksToBounds = false;
        sideMenuContainerView.layer.shadowOffset = (menuPosition == .Left) ? CGSizeMake(1.0, 1.0) : CGSizeMake(-1.0, -1.0);
        sideMenuContainerView.layer.shadowRadius = 1.0;
        sideMenuContainerView.layer.shadowOpacity = 0.125;
        sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).CGPath
        
        sourceView.addSubview(sideMenuContainerView)
        
        if (NSClassFromString("UIVisualEffectView") != nil) {
            // Add blur view
            var visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
            visualEffectView.frame = sideMenuContainerView.bounds
            visualEffectView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
            sideMenuContainerView.addSubview(visualEffectView)
        }
        else {
            // TODO: add blur for ios 7
        }
    }
    
    private func toggleMenu (shouldOpen: Bool) {
        if (shouldOpen && delegate?.sideMenuShouldOpenSideMenu?() == false) {
            return;
        }
        updateSideMenuApperanceIfNeeded()
        isMenuOpen = shouldOpen
        if (bouncingEnabled) {
            
            animator.removeAllBehaviors()
            
            var gravityDirectionX: CGFloat
            var pushMagnitude: CGFloat
            var boundaryPointX: CGFloat
            var boundaryPointY: CGFloat
            
            if (menuPosition == .Left) {
                // Left side menu
                gravityDirectionX = (shouldOpen) ? 1 : -1
                pushMagnitude = (shouldOpen) ? 20 : -20
                boundaryPointX = (shouldOpen) ? menuWidth : -menuWidth-2
                boundaryPointY = 20
            }
            else {
                // Right side menu
                gravityDirectionX = (shouldOpen) ? -1 : 1
                pushMagnitude = (shouldOpen) ? -20 : 20
                boundaryPointX = (shouldOpen) ? sourceView.frame.size.width-menuWidth : sourceView.frame.size.width+menuWidth+2
                boundaryPointY =  -20
            }
            
            let gravityBehavior = UIGravityBehavior(items: [sideMenuContainerView])
            gravityBehavior.gravityDirection = CGVectorMake(gravityDirectionX,  0)
            animator.addBehavior(gravityBehavior)
            
            let collisionBehavior = UICollisionBehavior(items: [sideMenuContainerView])
            collisionBehavior.addBoundaryWithIdentifier("menuBoundary", fromPoint: CGPointMake(boundaryPointX, boundaryPointY),
                toPoint: CGPointMake(boundaryPointX, sourceView.frame.size.height))
            animator.addBehavior(collisionBehavior)
            
            let pushBehavior = UIPushBehavior(items: [sideMenuContainerView], mode: UIPushBehaviorMode.Instantaneous)
            pushBehavior.magnitude = pushMagnitude
            animator.addBehavior(pushBehavior)
            
            let menuViewBehavior = UIDynamicItemBehavior(items: [sideMenuContainerView])
            menuViewBehavior.elasticity = 0.25
            animator.addBehavior(menuViewBehavior)
            
        }
        else {
            var destFrame :CGRect
            if (menuPosition == .Left) {
                destFrame = CGRectMake((shouldOpen) ? -2.0 : -menuWidth, 0, menuWidth, sideMenuContainerView.frame.size.height)
            }
            else {
                destFrame = CGRectMake((shouldOpen) ? sourceView.frame.size.width-menuWidth : sourceView.frame.size.width+2.0,
                                        0,
                                        menuWidth,
                                        sideMenuContainerView.frame.size.height)
            }
            
            UIView.animateWithDuration(0.4, animations: { () -> Void in
                self.sideMenuContainerView.frame = destFrame
            })
        }
        
        if (shouldOpen) {
            delegate?.sideMenuWillOpen?()
        } else {
            delegate?.sideMenuWillClose?()
        }
    }
    
    internal func handleGesture(gesture: UISwipeGestureRecognizer) {
        toggleMenu((self.menuPosition == .Right && gesture.direction == .Left)
                || (self.menuPosition == .Left && gesture.direction == .Right))
    }
    
    private func updateSideMenuApperanceIfNeeded () {
        if (needUpdateApperance) {
            var frame = sideMenuContainerView.frame
            frame.size.width = menuWidth
            sideMenuContainerView.frame = frame
            sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).CGPath

            needUpdateApperance = false
        }
    }
    
    public func toggleMenu () {
        if (isMenuOpen) {
            toggleMenu(false)
        }
        else {
            updateSideMenuApperanceIfNeeded()
            toggleMenu(true)
        }
    }
    
    public func showSideMenu () {
        if (!isMenuOpen) {
            toggleMenu(true)
        }
    }
    
    public func hideSideMenu () {
        if (isMenuOpen) {
            toggleMenu(false)
        }
    }
}

