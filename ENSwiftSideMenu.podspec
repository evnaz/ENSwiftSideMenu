#
#  Be sure to run `pod spec lint ENSwiftSideMenu.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name         = "ENSwiftSideMenu"
  s.version      = "0.0.5"
  s.summary      = "A simple side menu for iOS 7/8"
  s.homepage     = "https://github.com/evnaz/ENSwiftSideMenu"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Evgeny Nazarov" => "e.nazarov@yahoo.com" }
  s.requires_arc      = true
  s.platform = :ios, "7.0"
  s.source   = { :git => "https://github.com/evnaz/ENSwiftSideMenu.git", :tag => "v0.0.5" }
  s.source_files      = "Library/ENSideMenu.swift", "Library/ENSideMenuNavigationController.swift"

end
