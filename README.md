ENSwiftSideMenu
===============

A simple side menu for iOS 7/8 written in Swift. Using the UIDynamic framework, UIGestures and UIBlurEffect.

##Demo
![](http://i.imgur.com/SlilJ5M.gif?1)

##Requirements
* Xcode 6
* iOS 7 or higher

##How to use
1. Import `ENSideMenu.swift` and `ENSideMenuNavigationController.swift` to your project folder
2. Create a root UINavigationController subclassing from ENSideMenuNavigationController
3. Create a UITableViewController for menu table
4. Initilize the menu with source view and menu table view controller:
```swift
  override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenu = ENSideMenu(sourceView: self.view, menuTableViewController: MyMenuTableViewController())
        
        // make navigation bar showing over side menu
        view.bringSubviewToFront(navigationBar)
    }
```

Check example project for more explanation

