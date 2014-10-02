//
//  SideMenu.swift
//  SwiftSideMenu
//
//  Created by Evgeny on 24.07.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

@objc protocol ENSideMenuDelegate {
    optional func sideMenuWillOpen()
    optional func sideMenuWillClose()
}

@objc protocol ENSideMenuProtocol {
    var sideMenu : ENSideMenu? { get }
    var sideMenuWidth : NSNumber? { get set }
    func setContentViewController(contentViewController: UIViewController)
}

enum ENSideMenuAnimation : Int {
    case None
    case Default
}

extension UIViewController {
    
    public func toggleSideMenuView () {
        sideMenuController()?.sideMenu?.toggleMenu()
    }
    
    public func hideSideMenuView () {
        sideMenuController()?.sideMenu?.hideSideMenu()
    }
    
    public func showSideMenuView () {
        
        sideMenuController()?.sideMenu?.showSideMenu()
    }
    
    internal func sideMenuController () -> ENSideMenuProtocol? {
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
        var topController : UIViewController? = UIApplication.sharedApplication().keyWindow.rootViewController
        while (topController?.presentedViewController is ENSideMenuProtocol) {
            topController = topController?.presentedViewController;
        }
        
        return topController as? ENSideMenuProtocol
    }
}

class ENSideMenu : NSObject {
    
    internal var menuWidth : CGFloat = 160.0 {
        didSet {
            needUpdateApperance = true
        }
    }
    private let sideMenuContainerView =  UIView()
    private var menuTableViewController : UITableViewController!
    private var animator : UIDynamicAnimator!
    private let sourceView : UIView!
    private var needUpdateApperance : Bool = false
    weak var delegate : ENSideMenuDelegate?
    private var isMenuOpen : Bool = false
    
    init(sourceView: UIView) {
        super.init()
        self.sourceView = sourceView
        self.setupMenuView()
        
        animator = UIDynamicAnimator(referenceView:sourceView)
        // Add show gesture recognizer
        var showGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        showGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Right
        sourceView.addGestureRecognizer(showGestureRecognizer)
        
        // Add hide gesture recognizer
        var hideGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        hideGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        sideMenuContainerView.addGestureRecognizer(hideGestureRecognizer)
    }

    convenience init(sourceView: UIView, menuTableViewController: UITableViewController) {
        self.init(sourceView: sourceView)
        self.menuTableViewController = menuTableViewController
        self.menuTableViewController.tableView.frame = sideMenuContainerView.bounds
        self.menuTableViewController.tableView.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        sideMenuContainerView.addSubview(self.menuTableViewController.tableView)
    }
    
    private func setupMenuView() {
        
        // Configure side menu container
        sideMenuContainerView.frame = CGRectMake(-menuWidth-1.0, sourceView.frame.origin.y, menuWidth, sourceView.frame.size.height)
        sideMenuContainerView.backgroundColor = UIColor.clearColor()
        sideMenuContainerView.clipsToBounds = false
        sideMenuContainerView.layer.masksToBounds = false;
        sideMenuContainerView.layer.shadowOffset = CGSizeMake(1.0, 1.0);
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
    }
    
    private func toggleMenu (shouldOpen: Bool) {
        animator.removeAllBehaviors()
        isMenuOpen = shouldOpen
        let gravityDirectionX: CGFloat = (shouldOpen) ? 0.5 : -0.5;
        let pushMagnitude: CGFloat = (shouldOpen) ? 20.0 : -20.0;
        let boundaryPointX: CGFloat = (shouldOpen) ? menuWidth : -menuWidth-1.0;
        
        let gravityBehavior = UIGravityBehavior(items: [sideMenuContainerView])
        gravityBehavior.gravityDirection = CGVectorMake(gravityDirectionX, 0.0)
        animator.addBehavior(gravityBehavior)
        
        let collisionBehavior = UICollisionBehavior(items: [sideMenuContainerView])
        collisionBehavior.addBoundaryWithIdentifier("menuBoundary", fromPoint: CGPointMake(boundaryPointX, 20.0),
            toPoint: CGPointMake(boundaryPointX, sourceView.frame.size.height))
        animator.addBehavior(collisionBehavior)
        
        let pushBehavior = UIPushBehavior(items: [sideMenuContainerView], mode: UIPushBehaviorMode.Instantaneous)
        pushBehavior.magnitude = pushMagnitude
        animator.addBehavior(pushBehavior)
        
        let menuViewBehavior = UIDynamicItemBehavior(items: [sideMenuContainerView])
        menuViewBehavior.elasticity = 0.3
        animator.addBehavior(menuViewBehavior)
    }
    
    internal func handleGesture(gesture: UISwipeGestureRecognizer) {
        
        if (gesture.direction == .Left) {
            toggleMenu(false)
            delegate?.sideMenuWillClose?()
        }
        else{
            updateSideMenuApperanceIfNeeded()
            toggleMenu(true)
            delegate?.sideMenuWillOpen?()
        }
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
    
    internal func toggleMenu () {
        if (isMenuOpen) {
            toggleMenu(false)
        }
        else {
            updateSideMenuApperanceIfNeeded()
            toggleMenu(true)
        }
    }
    
    internal func showSideMenu () {
        if (!isMenuOpen) {
            toggleMenu(true)
        }
    }
    
    internal func hideSideMenu () {
        if (isMenuOpen) {
            toggleMenu(false)
        }
    }
}

