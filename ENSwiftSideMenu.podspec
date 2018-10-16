#
#  Be sure to run `pod spec lint ENSwiftSideMenu.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ENSwiftSideMenu"
  s.version      = "1.0.0"
  s.summary      = "A simple side menu for iOS 8"
  s.homepage     = "https://github.com/andreaswillems/ENSwiftSideMenu"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Andreas Willems" => "andreas.willems@entwicklung.eq-3.de" }
  s.requires_arc      = true
  s.platform = :ios, "8.0"
  s.source   = { :git => "https://github.com/andreaswillems/ENSwiftSideMenu.git", :tag => "1.0.0"}
  s.source_files      = "Library/ENSideMenu.swift", "Library/ENSideMenuNavigationController.swift"

end
