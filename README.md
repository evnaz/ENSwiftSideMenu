# ENSwiftSideMenu

A lightweight flyover side menu component for iOS with the ```UIDynamic```'s bouncing animation, ```UIGestures``` and ```UIBlurEffect```. Allows you to use native ```UINavigationController```'s logic to manage view controllers. The component is written in **Swift**.

![](https://github.com/evnaz/ENSwiftSideMenu/blob/master/demo.gif)

## Requirements
* Xcode 6.3 or higher
* iOS 8 or higher

## Installation
### CocoaPods
The recommended way for installating `ENSwiftSideMenu` is via the [CocoaPods](http://cocoapods.org/) package manager
``` bash
platform :ios, '8.0'
pod 'ENSwiftSideMenu', '~> 0.1.1'
```
### Manual Install
All you need is import `ENSideMenu.swift` and `ENSideMenuNavigationController.swift` to your project folder.

## Usage Example
1. Create a root UINavigationController subclassing from ENSideMenuNavigationController
2. Create a UIViewController for your side menu
3. Initilize the menu view with a source view and menu view controller:
  
  ```swift
  override func viewDidLoad() {
    super.viewDidLoad()
    sideMenu = ENSideMenu(sourceView: self.view, menuViewController: MyMenuViewController(), menuPosition:.Left)
    // show the navigation bar over the side menu view
    view.bringSubviewToFront(navigationBar)
  }
  ```
  
4. To change content view controller use next line in your menu view controller:

  ```swift
  sideMenuController()?.setContentViewController(destViewController)
  ```

5. Check example project for more explanation

## License

The MIT License (MIT)

Copyright (c) 2014 Evgeny Nazarov

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
