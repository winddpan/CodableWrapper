#
# Be sure to run `pod lib lint CodableWrapper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CodableWrapper'
  s.version          = '1.0.3'
  s.summary          = 'A short description of CodableWrapper.'

  s.description      = <<-DESC
    CodableWrapper Pod 
                       DESC

  s.homepage         = 'https://github.com/winddpan/CodableWrapper'
  s.author           = { 'winddpan' => 'https://github.com/winddpan' }
  s.source           = { :git => 'git@github.com:winddpan/CodableWrapper.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files = 'Sources/CodableWrapper/*{.swift}'
  s.preserve_paths = ["Package.swift", "Sources/CodableWrapperMacros", "Tests", "Bin"]
  
  s.pod_target_xcconfig = {
    "OTHER_SWIFT_FLAGS" => "-Xfrontend -load-plugin-executable -Xfrontend $(PODS_BUILD_DIR)/CodableWrapper/release/CodableWrapperMacros#CodableWrapperMacros"
  }
  
  s.user_target_xcconfig = {
    "OTHER_SWIFT_FLAGS" => "-Xfrontend -load-plugin-executable -Xfrontend $(PODS_BUILD_DIR)/CodableWrapper/release/CodableWrapperMacros#CodableWrapperMacros"
  }

  script = <<-SCRIPT
    env -i PATH="$PATH" "$SHELL" -l -c "swift build -c release --package-path \\"$PODS_TARGET_SRCROOT\\" --build-path \\"${PODS_BUILD_DIR}/CodableWrapper\\""
    SCRIPT
  
  s.script_phase = {
      :name => 'Build CodableWrapper macro plugin',
      :script => script,
      :execution_position => :before_compile
  }
end
