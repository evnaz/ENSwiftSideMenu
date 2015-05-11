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
    
    public func isSideMenuOpen () -> Bool {
        let sieMenuOpen = self.sideMenuController()?.sideMenu?.isMenuOpen
        return sieMenuOpen!
    }
    
    /**
     * You must call this method from viewDidLayoutSubviews in your content view controlers so it fixes size and position of the side menu when the screen
     * rotates.
     * A convenient way to do it might be creating a subclass of UIViewController that does precisely that and then subclassing your view controllers from it.
     */
    func fixSideMenuSize() {
        if let navController = self.navigationController as? ENSideMenuNavigationController {
            navController.sideMenu?.updateFrame()
        }
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
                iteration = iteration!.parentViewController
            } else {
                iteration = nil
            }
        } while (iteration != nil)
        
        return iteration as? ENSideMenuProtocol
    }
    
    internal func topMostController () -> ENSideMenuProtocol? {
        var topController : UIViewController? = UIApplication.sharedApplication().keyWindow?.rootViewController
        while (topController?.presentedViewController is ENSideMenuProtocol) {
            topController = topController?.presentedViewController
        }
        
        return topController as? ENSideMenuProtocol
    }
}

public class ENSideMenu : NSObject, UIGestureRecognizerDelegate {
    
    public var menuWidth : CGFloat = 160.0 {
        didSet {
            needUpdateApperance = true
            updateFrame()
        }
    }
    private var menuPosition:ENSideMenuPosition = .Left
    public var bouncingEnabled :Bool = true
    public var animationDuration = 0.4
    private let sideMenuContainerView =  UIView()
    private var menuViewController : UIViewController!
    private var animator : UIDynamicAnimator!
    private var sourceView : UIView!
    private var needUpdateApperance : Bool = false
    public weak var delegate : ENSideMenuDelegate?
    private(set) var isMenuOpen : Bool = false
    public var allowLeftSwipe : Bool = true
    public var allowRightSwipe : Bool = true
    
    public init(sourceView: UIView, menuPosition: ENSideMenuPosition) {
        super.init()
        self.sourceView = sourceView
        self.menuPosition = menuPosition
        self.setupMenuView()
    
        animator = UIDynamicAnimator(referenceView:sourceView)
        
        // Add right swipe gesture recognizer
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        rightSwipeGestureRecognizer.delegate = self
        rightSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirection.Right
        
        // Add left swipe gesture recognizer
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        leftSwipeGestureRecognizer.delegate = self
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

    public convenience init(sourceView: UIView, menuViewController: UIViewController, menuPosition: ENSideMenuPosition) {
        self.init(sourceView: sourceView, menuPosition: menuPosition)
        self.menuViewController = menuViewController
        self.menuViewController.view.frame = sideMenuContainerView.bounds
        self.menuViewController.view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        sideMenuContainerView.addSubview(self.menuViewController.view)
    }

    public convenience init(sourceView: UIView, view: UIView, menuPosition: ENSideMenuPosition) {
        self.init(sourceView: sourceView, menuPosition: menuPosition)
        view.frame = sideMenuContainerView.bounds
        view.autoresizingMask = .FlexibleHeight | .FlexibleWidth
        sideMenuContainerView.addSubview(view)
    }

    /**
     * Do not make this function private, it must be called from your own UIViewControllers (using the fixSideMenuSize function of the extension).
     */
    func updateFrame() {
        var width:CGFloat
        var height:CGFloat
        (width, height) = adjustFrameDimensions( sourceView.frame.size.width, height: sourceView.frame.size.height)
        let menuFrame = CGRectMake(
            (menuPosition == .Left) ?
                isMenuOpen ? 0 : -menuWidth-1.0 :
                isMenuOpen ? width - menuWidth : width+1.0,
            sourceView.frame.origin.y,
            menuWidth,
            height
        )
        sideMenuContainerView.frame = menuFrame
    }
    
    private func adjustFrameDimensions( width: CGFloat, height: CGFloat ) -> (CGFloat,CGFloat) {
        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1 &&
            (UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeRight ||
                UIApplication.sharedApplication().statusBarOrientation == UIInterfaceOrientation.LandscapeLeft) {
                    // iOS 7.1 or lower and landscape mode -> interchange width and height
                    return (height, width)
        }
        else {
            return (width, height)
        }
        
    }
    
    private func setupMenuView() {
        
        // Configure side menu container
        updateFrame()

        sideMenuContainerView.backgroundColor = UIColor.clearColor()
        sideMenuContainerView.clipsToBounds = false
        sideMenuContainerView.layer.masksToBounds = false
        sideMenuContainerView.layer.shadowOffset = (menuPosition == .Left) ? CGSizeMake(1.0, 1.0) : CGSizeMake(-1.0, -1.0)
        sideMenuContainerView.layer.shadowRadius = 1.0
        sideMenuContainerView.layer.shadowOpacity = 0.125
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
            return
        }
        updateSideMenuApperanceIfNeeded()
        isMenuOpen = shouldOpen
        var width:CGFloat
        var height:CGFloat
        (width, height) = adjustFrameDimensions( sourceView.frame.size.width, height: sourceView.frame.size.height)
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
                boundaryPointX = (shouldOpen) ? width-menuWidth : width+menuWidth+2
                boundaryPointY =  -20
            }
            
            let gravityBehavior = UIGravityBehavior(items: [sideMenuContainerView])
            gravityBehavior.gravityDirection = CGVectorMake(gravityDirectionX,  0)
            animator.addBehavior(gravityBehavior)
            
            let collisionBehavior = UICollisionBehavior(items: [sideMenuContainerView])
            collisionBehavior.addBoundaryWithIdentifier("menuBoundary", fromPoint: CGPointMake(boundaryPointX, boundaryPointY),
                toPoint: CGPointMake(boundaryPointX, height))
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
                destFrame = CGRectMake((shouldOpen) ? -2.0 : -menuWidth, 0, menuWidth, height)
            }
            else {
                destFrame = CGRectMake((shouldOpen) ? width-menuWidth : width+2.0,
                                        0,
                                        menuWidth,
                                        height)
            }
            
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                self.sideMenuContainerView.frame = destFrame
            })
        }
        
        if (shouldOpen) {
            delegate?.sideMenuWillOpen?()
        } else {
            delegate?.sideMenuWillClose?()
        }
    }
    
    public func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer {
            let swipeGestureRecognizer = gestureRecognizer as! UISwipeGestureRecognizer
            if !self.allowLeftSwipe {
                if swipeGestureRecognizer.direction == .Left {
                    return false
                }
            }
            
            if !self.allowRightSwipe {
                if swipeGestureRecognizer.direction == .Right {
                    return false
                }
            }
        }
        return true
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

