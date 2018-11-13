#
# Be sure to run `pod lib lint dpsdk.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'dpsdk'
  s.version          = '0.1.0'
  s.summary          = 'A short description of dpsdk.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/ly/dpsdk'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ly' => '1090336995@qq.com' }
  s.source           = { :git => 'https://github.com/ly/dpsdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'include/**/*.{h,m,mm}','include/DPSDK/api/*.h'
  
  #s.vendored_frameworks ='Depend/Bugly/Bugly.framework'
  s.vendored_libraries = 'Lib/*.a','Lib/playsdk/*.a'
  s.frameworks = 'VideoToolbox','AVFoundation','UIKIT', 'Foundation', 'OpenAL', 'OpenGLES', 'AudioToolbox', 'CoreMedia'
  s.library = 'resolv','c++','iconv', 'stdc++.6.0.9'
  
  s.pod_target_xcconfig = { 'ENABLE_BITCODE' => 'false'}
  
  # s.resource_bundles = {
  #   'dpsdk' => ['dpsdk/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
