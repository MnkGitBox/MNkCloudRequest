#
# Be sure to run `pod lib lint MNkCloudRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'MNkCloudRequest'
  s.version          = '0.1.2.1'
  s.summary          = 'Help iOS Network Request Lib.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = 'iOS library what help to call api request with-out cording generic code lines.'

  s.homepage         = 'https://github.com/MnkGitBox/MNkCloudRequest'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Malith Nadeeshan' => 'malith.mnk93@gmail.com' }
  s.source           = { :git => 'https://github.com/MnkGitBox/MNkCloudRequest.git', :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/malithnadeeshan'

  s.ios.deployment_target = '11.0'

  s.source_files = 'Classes/**/*'
  
  # s.resource_bundles = {
  #   'MNkCloudRequest' => ['MNkCloudRequest/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
    s.frameworks = 'SystemConfiguration'
  # s.dependency 'AFNetworking', '~> 2.3'
    s.swift_version = '4.0'
end
