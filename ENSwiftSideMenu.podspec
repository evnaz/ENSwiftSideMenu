Pod::Spec.new do |s|

  s.name         = "ENSwiftSideMenu"
  s.version      = "0.1.4"
  s.summary      = "A simple side menu for iOS 9 and higher"
  s.homepage     = "https://github.com/evnaz/ENSwiftSideMenu"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "Evgeny Nazarov" => "e.nazarov@yahoo.com" }
  s.requires_arc      = true
  s.platform = :ios, "9.0"
  s.swift_version = '5.0'
  s.source   = { :git => "https://github.com/evnaz/ENSwiftSideMenu.git", :tag => "0.1.5"}
  s.source_files      = "Library/*.swift"

end
