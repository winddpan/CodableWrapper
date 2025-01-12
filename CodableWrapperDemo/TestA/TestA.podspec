#
# Be sure to run `pod lib lint CodableWrapper.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TestA'
  s.version          = '0.0.1'
  s.summary          = 'A short description of TestA.'

  s.description      = <<-DESC
    TestA
                       DESC

  s.homepage         = 'https://github.com/winddpan/CodableWrapper'
  s.author           = { 'winddpan' => 'https://github.com/winddpan' }
  s.source           = { :git => 'git@github.com:winddpan/CodableWrapper.git', :tag => s.version.to_s }

  s.ios.deployment_target = '13.0'

  s.source_files     = ['TestA/Classes/**/*.{h,m,cpp,c,mm,xml,swift}', 'TestA/TestA.h']
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  
  s.dependency 'CodableWrapper'
end
