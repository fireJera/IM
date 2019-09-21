#
# Be sure to run `pod lib lint MessageLib.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MessageLib'
  s.version          = '0.1.0'
  s.summary          = 'https://git.imdsk.com/ios_zhuqiu/MessageLib.git'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

s.description      = '* Think: What does it do? Why did you write it? What is the focus? \n Try to keep it short, snappy and to the point.\n Write the description between the DESC delimiters below.\n Finally, do not worry about the indent, CocoaPods strips it!'
  s.homepage         = 'https://git.imdsk.com/ios_zhuqiu/MessageLib'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'r913218338@163.com' => 'r913218338@163.com' }
  s.source           = { :git => 'https://git.imdsk.com/ios_zhuqiu/MessageLib.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'MessageLib/Classes/**/*'
  
  # s.resource_bundles = {
  #   'MessageLib' => ['MessageLib/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'AFNetworking', '~> 3.2'
  s.dependency 'MQTTClient'
  s.dependency 'FMDB'
  
end
