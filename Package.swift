// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ENSwiftSideMenu",    
    platforms: [
      .iOS(.v10)
    ],
    products: [        
        .library(name: "ENSwiftSideMenu", targets: ["ENSwiftSideMenu"]),
    ],
    targets: [     
        .target(name: "ENSwiftSideMenu", path: "Library"),
    ]
)