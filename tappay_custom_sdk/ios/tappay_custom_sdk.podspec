#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tappay_custom_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tappay_custom_sdk'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin for TapPay payment integration.'
  s.description      = <<-DESC
A Flutter plugin for TapPay payment integration.
                       DESC
  s.homepage         = 'https://github.com/DKMonster/tappay_custom_sdk'
  s.license          = { :type => 'MIT', :file => '../LICENSE' }
  s.author           = { 'DKMonster' => 'davidkross@mapswalker.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.public_header_files = 'Classes/**/*.h'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
