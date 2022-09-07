#
#  Be sure to run `pod spec lint CodableWrapper.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "CodableWrapper"
  spec.version      = "0.3.1"
  spec.requires_arc = true
  spec.summary      = "Codable + PropertyWrapper"
  spec.description  = "Codable + PropertyWrapper = ☕"

  spec.homepage     = "https://github.com/winddpan/CodableWrapper"
  spec.license      = "MIT"
  spec.authors      = { "winddpan" => "winddpan@126.com", "scyano" => "scyano@icloud.com" }

  spec.source       = { :git => "https://github.com/winddpan/CodableWrapper.git", :tag => "#{spec.version}" }
  spec.source_files  = "Sources/CodableWrapper/**/*.swift"

  spec.ios.deployment_target = '8.0'
  spec.osx.deployment_target = '10.9'
  spec.watchos.deployment_target = '2.0'
  spec.tvos.deployment_target = '9.0'

  spec.swift_versions = '5.0'
end
