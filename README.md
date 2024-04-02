# Podspec Config

* Swift Package will be build automatically when you first `pod install`, the first build need a few time.
* This means that when there is a `relase` shortcut in the directory `CodableWrapper/.build`, the Package builds successfully.
* There is a situation that `pod install` will build automatically, if the Package auto build is not completed, the build will fail when you build the project.

  ```
  script = <<-SCRIPT
    env -i PATH="$PATH" "$SHELL" -l -c "swift build -c release --package-path \\"$PODS_TARGET_SRCROOT\\""
    SCRIPT
  ```

* The first important setting, it's used to set the SwiftMacros plugin path for the main project.
* You need to replace this with your custom path

  ```
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['OTHER_SWIFT_FLAGS'] = '$(inherited) -Xfrontend -load-plugin-executable -Xfrontend $(PODS_ROOT)/../CodableWrapper/.build/release/CodableWrapperMacros#CodableWrapperMacros'
      end
    end
  end
  ```

* The second important setting, both of them are used to set the SwiftMacros plugin path for the Development Pods in the Pod project. 
* You need to replace them with your custom path

  ```
  s.pod_target_xcconfig = {
    "OTHER_SWIFT_FLAGS" => "-Xfrontend -load-plugin-executable -Xfrontend $(PODS_ROOT)/../CodableWrapper/.build/release/CodableWrapperMacros#CodableWrapperMacros"
  }
      
  s.user_target_xcconfig = {
    "OTHER_SWIFT_FLAGS" => "-Xfrontend -load-plugin-executable -Xfrontend $(PODS_ROOT)/../CodableWrapper/.build/release/CodableWrapperMacros#CodableWrapperMacros"
  }
  ```
