//
//  SideMenu.swift
//  SwiftSideMenu
//
//  Created by Evgeny on 24.07.14.
//  Copyright (c) 2014 Evgeny Nazarov. All rights reserved.
//

import UIKit

@objc public protocol ENSideMenuDelegate {
    @objc optional func sideMenuWillOpen()
    @objc optional func sideMenuWillClose()
    @objc optional func sideMenuDidOpen()
    @objc optional func sideMenuDidClose()
    @objc optional func sideMenuShouldOpenSideMenu () -> Bool
}

@objc public protocol ENSideMenuProtocol {
    var sideMenu : ENSideMenu? { get }
    func setContentViewController(_ contentViewController: UIViewController)
}

public enum ENSideMenuAnimation : Int {
    case none
    case `default`
}
/**
The position of the side view on the screen.

- Left:  Left side of the screen
- Right: Right side of the screen
*/
public enum ENSideMenuPosition : Int {
    case left
    case right
}

public extension UIViewController {
    /**
    Changes current state of side menu view.
    */
    public func toggleSideMenuView () {
        sideMenuController()?.sideMenu?.toggleMenu()
    }
    /**
    Hides the side menu view.
    */
    public func hideSideMenuView () {
        sideMenuController()?.sideMenu?.hideSideMenu()
    }
    /**
    Shows the side menu view.
    */
    public func showSideMenuView () {
        
        sideMenuController()?.sideMenu?.showSideMenu()
    }
    
    /**
    Returns a Boolean value indicating whether the side menu is showed.
    
    :returns: BOOL value
    */
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
    /**
    Returns a view controller containing a side menu
    
    :returns: A `UIViewController`responding to `ENSideMenuProtocol` protocol
    */
    public func sideMenuController () -> ENSideMenuProtocol? {
        var iteration : UIViewController? = self.parent
        if (iteration == nil) {
            return topMostController()
        }
        repeat {
            if (iteration is ENSideMenuProtocol) {
                return iteration as? ENSideMenuProtocol
            } else if (iteration?.parent != nil && iteration?.parent != iteration) {
                iteration = iteration!.parent
            } else {
                iteration = nil
            }
        } while (iteration != nil)
        
        return iteration as? ENSideMenuProtocol
    }
    
    internal func topMostController () -> ENSideMenuProtocol? {
        var topController : UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        if (topController is UITabBarController) {
            topController = (topController as! UITabBarController).selectedViewController
        }
        var lastMenuProtocol : ENSideMenuProtocol?
        while (topController?.presentedViewController != nil) {
            if(topController?.presentedViewController is ENSideMenuProtocol) {
                lastMenuProtocol = topController?.presentedViewController as? ENSideMenuProtocol
            }
            topController = topController?.presentedViewController
        }
        
        if (lastMenuProtocol != nil) {
            return lastMenuProtocol
        }
        else {
            return topController as? ENSideMenuProtocol
        }
    }
}

open class ENSideMenu : NSObject, UIGestureRecognizerDelegate {
    /// The width of the side menu view. The default value is 160.
    open var menuWidth : CGFloat = 160.0 {
        didSet {
            needUpdateApperance = true
            updateSideMenuApperanceIfNeeded()
            updateFrame()
        }
    }
    fileprivate var menuPosition:ENSideMenuPosition = .left
    fileprivate var blurStyle: UIBlurEffectStyle = .light
    ///  A Boolean value indicating whether the bouncing effect is enabled. The default value is TRUE.
    open var bouncingEnabled :Bool = true
    /// The duration of the slide animation. Used only when `bouncingEnabled` is FALSE.
    open var animationDuration = 0.4
    fileprivate let sideMenuContainerView =  UIView()
    fileprivate(set) var menuViewController : UIViewController!
    fileprivate var animator : UIDynamicAnimator!
    fileprivate var sourceView : UIView!
    fileprivate var needUpdateApperance : Bool = false
    /// The delegate of the side menu
    open weak var delegate : ENSideMenuDelegate?
    fileprivate(set) var isMenuOpen : Bool = false
    /// A Boolean value indicating whether the left swipe is enabled.
    open var allowLeftSwipe : Bool = true
    /// A Boolean value indicating whether the right swipe is enabled.
    open var allowRightSwipe : Bool = true
    open var allowPanGesture : Bool = true
    fileprivate var panRecognizer : UIPanGestureRecognizer?
    
    /**
    Initializes an instance of a `ENSideMenu` object.
    
    :param: sourceView   The parent view of the side menu view.
    :param: menuPosition The position of the side menu view.
    
    :returns: An initialized `ENSideMenu` object, added to the specified view.
    */
    public init(sourceView: UIView, menuPosition: ENSideMenuPosition, blurStyle: UIBlurEffectStyle = .light) {
        super.init()
        self.sourceView = sourceView
        self.menuPosition = menuPosition
        self.blurStyle = blurStyle
        self.setupMenuView()
    
        animator = UIDynamicAnimator(referenceView:sourceView)
        animator.delegate = self
        
        self.panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ENSideMenu.handlePan(_:)))
        panRecognizer!.delegate = self
        sourceView.addGestureRecognizer(panRecognizer!)
        
        // Add right swipe gesture recognizer
        let rightSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ENSideMenu.handleGesture(_:)))
        rightSwipeGestureRecognizer.delegate = self
        rightSwipeGestureRecognizer.direction =  UISwipeGestureRecognizerDirection.right
        
        // Add left swipe gesture recognizer
        let leftSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(ENSideMenu.handleGesture(_:)))
        leftSwipeGestureRecognizer.delegate = self
        leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirection.left
        
        if (menuPosition == .left) {
            sourceView.addGestureRecognizer(rightSwipeGestureRecognizer)
            sideMenuContainerView.addGestureRecognizer(leftSwipeGestureRecognizer)
        }
        else {
            sideMenuContainerView.addGestureRecognizer(rightSwipeGestureRecognizer)
            sourceView.addGestureRecognizer(leftSwipeGestureRecognizer)
        }
        
    }
    /**
    Initializes an instance of a `ENSideMenu` object.
    
    :param: sourceView         The parent view of the side menu view.
    :param: menuViewController A menu view controller object which will be placed in the side menu view.
    :param: menuPosition       The position of the side menu view.
    
    :returns: An initialized `ENSideMenu` object, added to the specified view, containing the specified menu view controller.
    */
    public convenience init(sourceView: UIView, menuViewController: UIViewController, menuPosition: ENSideMenuPosition, blurStyle: UIBlurEffectStyle = .light) {
        self.init(sourceView: sourceView, menuPosition: menuPosition, blurStyle: blurStyle)
        self.menuViewController = menuViewController
        self.menuViewController.view.frame = sideMenuContainerView.bounds
        self.menuViewController.view.autoresizingMask =  [.flexibleHeight, .flexibleWidth]
        sideMenuContainerView.addSubview(self.menuViewController.view)
    }
/*
    public convenience init(sourceView: UIView, view: UIView, menuPosition: ENSideMenuPosition) {
        self.init(sourceView: sourceView, menuPosition: menuPosition)
        view.frame = sideMenuContainerView.bounds
        view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        sideMenuContainerView.addSubview(view)
    }
*/
    /**
    Updates the frame of the side menu view.
    */
    func updateFrame() {
        var width:CGFloat
        var height:CGFloat
        (width, height) = adjustFrameDimensions( sourceView.frame.size.width, height: sourceView.frame.size.height)
        let menuFrame = CGRect(
            x: (menuPosition == .left) ?
                isMenuOpen ? 0 : -menuWidth-1.0 :
                isMenuOpen ? width - menuWidth : width+1.0,
            y: sourceView.frame.origin.y,
            width: menuWidth,
            height: height
        )
        sideMenuContainerView.frame = menuFrame
    }
    
    fileprivate func adjustFrameDimensions( _ width: CGFloat, height: CGFloat ) -> (CGFloat,CGFloat) {
        if floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1 &&
            (UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeRight ||
                UIApplication.shared.statusBarOrientation == UIInterfaceOrientation.landscapeLeft) {
                    // iOS 7.1 or lower and landscape mode -> interchange width and height
                    return (height, width)
        }
        else {
            return (width, height)
        }
        
    }
    
    fileprivate func setupMenuView() {
        
        // Configure side menu container
        updateFrame()

        sideMenuContainerView.backgroundColor = UIColor.clear
        sideMenuContainerView.clipsToBounds = false
        sideMenuContainerView.layer.masksToBounds = false
        sideMenuContainerView.layer.shadowOffset = (menuPosition == .left) ? CGSize(width: 1.0, height: 1.0) : CGSize(width: -1.0, height: -1.0)
        sideMenuContainerView.layer.shadowRadius = 1.0
        sideMenuContainerView.layer.shadowOpacity = 0.125
        sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).cgPath
        
        sourceView.addSubview(sideMenuContainerView)
        
        if (NSClassFromString("UIVisualEffectView") != nil) {
            // Add blur view
            let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: blurStyle)) as UIVisualEffectView
            visualEffectView.frame = sideMenuContainerView.bounds
            visualEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            sideMenuContainerView.addSubview(visualEffectView)
        }
        else {
            // TODO: add blur for ios 7
        }
    }
    
    fileprivate func toggleMenu (_ shouldOpen: Bool) {
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
            
            if (menuPosition == .left) {
                // Left side menu
                gravityDirectionX = (shouldOpen) ? 1 : -1
                pushMagnitude = (shouldOpen) ? 35 : -35
                boundaryPointX = (shouldOpen) ? menuWidth : -menuWidth-2
                boundaryPointY = 25
            }
            else {
                // Right side menu
                gravityDirectionX = (shouldOpen) ? -1 : 1
                pushMagnitude = (shouldOpen) ? -35 : 35
                boundaryPointX = (shouldOpen) ? width-menuWidth : width+menuWidth+2
                boundaryPointY =  -25
            }
            
            let gravityBehavior = UIGravityBehavior(items: [sideMenuContainerView])
            gravityBehavior.gravityDirection = CGVector(dx: gravityDirectionX,  dy: 0)
            animator.addBehavior(gravityBehavior)
            
            let collisionBehavior = UICollisionBehavior(items: [sideMenuContainerView])
            collisionBehavior.addBoundary(withIdentifier: "menuBoundary" as NSCopying, from: CGPoint(x: boundaryPointX, y: boundaryPointY),
                to: CGPoint(x: boundaryPointX, y: height))
            animator.addBehavior(collisionBehavior)
            
            let pushBehavior = UIPushBehavior(items: [sideMenuContainerView], mode: UIPushBehaviorMode.instantaneous)
            pushBehavior.magnitude = pushMagnitude
            animator.addBehavior(pushBehavior)
            
            let menuViewBehavior = UIDynamicItemBehavior(items: [sideMenuContainerView])
            menuViewBehavior.elasticity = 0.25
            animator.addBehavior(menuViewBehavior)
            
        }
        else {
            var destFrame :CGRect
            if (menuPosition == .left) {
                destFrame = CGRect(x: (shouldOpen) ? -2.0 : -menuWidth, y: 0, width: menuWidth, height: height)
            }
            else {
                destFrame = CGRect(x: (shouldOpen) ? width-menuWidth : width+2.0,
                                        y: 0,
                                        width: menuWidth,
                                        height: height)
            }
            
            UIView.animate(
                withDuration: animationDuration,
                animations: { () -> Void in
                    self.sideMenuContainerView.frame = destFrame
                },
                completion: { (Bool) -> Void in
                    if (self.isMenuOpen) {
                        self.delegate?.sideMenuDidOpen?()
                    } else {
                        self.delegate?.sideMenuDidClose?()
                    }
            })
        }
        
        if (shouldOpen) {
            delegate?.sideMenuWillOpen?()
        } else {
            delegate?.sideMenuWillClose?()
        }
    }
    
    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if delegate?.sideMenuShouldOpenSideMenu?() == false {
            return false
        }
        
        if gestureRecognizer is UISwipeGestureRecognizer {
            let swipeGestureRecognizer = gestureRecognizer as! UISwipeGestureRecognizer
            if !self.allowLeftSwipe {
                if swipeGestureRecognizer.direction == .left {
                    return false
                }
            }
            
            if !self.allowRightSwipe {
                if swipeGestureRecognizer.direction == .right {
                    return false
                }
            }
        }
        else if gestureRecognizer.isEqual(panRecognizer) {
            if allowPanGesture == false {
                return false
            }
            animator.removeAllBehaviors()
            let touchPosition = gestureRecognizer.location(ofTouch: 0, in: sourceView)
            if menuPosition == .left {
                if isMenuOpen {
                    if touchPosition.x < menuWidth {
                        return true
                    }
                }
                else {
                    if touchPosition.x < 25 {
                        return true
                    }
                }
            }
            else {
                if isMenuOpen {
                    if touchPosition.x > sourceView.frame.width - menuWidth {
                        return true
                    }
                }
                else {
                    if touchPosition.x > sourceView.frame.width-25 {
                        return true
                    }
                }
            }
            
            return false
        }
        return true
    }
    
    internal func handleGesture(_ gesture: UISwipeGestureRecognizer) {
        toggleMenu((self.menuPosition == .right && gesture.direction == .left)
                || (self.menuPosition == .left && gesture.direction == .right))
    }
    
    internal func handlePan(_ recognizer : UIPanGestureRecognizer){
        
        let leftToRight = recognizer.velocity(in: recognizer.view).x > 0
        
        switch recognizer.state {
        case .began:
            
            break
            
        case .changed:
            
            let translation = recognizer.translation(in: sourceView).x
            let xPoint : CGFloat = sideMenuContainerView.center.x + translation + (menuPosition == .left ? 1 : -1) * menuWidth / 2
            
            if menuPosition == .left {
                if xPoint <= 0 || xPoint > self.sideMenuContainerView.frame.width {
                    return
                }
            }else{
                if xPoint <= sourceView.frame.size.width - menuWidth || xPoint >= sourceView.frame.size.width
                {
                    return
                }
            }
            
            sideMenuContainerView.center.x = sideMenuContainerView.center.x + translation
            recognizer.setTranslation(CGPoint.zero, in: sourceView)
            
        default:
            
            let shouldClose = menuPosition == .left ? !leftToRight && sideMenuContainerView.frame.maxX < menuWidth : leftToRight && sideMenuContainerView.frame.minX >  (sourceView.frame.size.width - menuWidth)
            
            toggleMenu(!shouldClose)
            
        }
    }
    
    fileprivate func updateSideMenuApperanceIfNeeded () {
        if (needUpdateApperance) {
            var frame = sideMenuContainerView.frame
            frame.size.width = menuWidth
            sideMenuContainerView.frame = frame
            sideMenuContainerView.layer.shadowPath = UIBezierPath(rect: sideMenuContainerView.bounds).cgPath

            needUpdateApperance = false
        }
    }
    
    /**
    Toggles the state of the side menu.
    */
    open func toggleMenu () {
        if (isMenuOpen) {
            toggleMenu(false)
        }
        else {
            updateSideMenuApperanceIfNeeded()
            toggleMenu(true)
        }
    }
    /**
    Shows the side menu if the menu is hidden.
    */
    open func showSideMenu () {
        if (!isMenuOpen) {
            toggleMenu(true)
        }
    }
    /**
    Hides the side menu if the menu is showed.
    */
    open func hideSideMenu () {
        if (isMenuOpen) {
            toggleMenu(false)
        }
    }
}

extension ENSideMenu: UIDynamicAnimatorDelegate {
    public func dynamicAnimatorDidPause(_ animator: UIDynamicAnimator) {
        if (self.isMenuOpen) {
            self.delegate?.sideMenuDidOpen?()
        } else {
            self.delegate?.sideMenuDidClose?()
        }
    }
}

