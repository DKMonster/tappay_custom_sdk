#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tappay_custom_sdk.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tappay_custom_sdk'
  s.version          = '0.0.1'
  s.summary          = 'TapPay Flutter plugin'
  s.description      = <<-DESC
A Flutter plugin for TapPay payment SDK.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  
  # 改用 xcframework
  s.vendored_frameworks = 'Frameworks/TPDirect.xcframework'
  
  # 設定最低 iOS 版本
  s.platform = :ios, '12.0'
  
  # 加入需要的系統框架
  s.frameworks = 'PassKit'
  
  # Swift 版本
  s.swift_version = '5.0'
  
  # 確保 arm64 架構支援
  s.pod_target_xcconfig = { 
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386',
    'VALID_ARCHS' => 'arm64 x86_64'
  }
end
