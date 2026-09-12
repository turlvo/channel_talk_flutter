#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint channel_talk_flutter.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'channel_talk_flutter'
  s.version          = '4.3.0'
  s.summary          = 'A Channel Talk flutter plugin project.(Unofficial)'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://kuku.pe.kr'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'KuKu' => 'turlvo@gmail.com' }
  s.source           = { :path => '.' }
  # Single source of truth shared with the Swift Package Manager target
  # (ios/channel_talk_flutter/Package.swift) so CocoaPods and SPM builds
  # never diverge.
  s.source_files = 'channel_talk_flutter/Sources/channel_talk_flutter/**/*.swift'
  s.dependency 'Flutter'
  s.dependency 'ChannelIOSDK', '13.3.0'
  s.platform = :ios, '15.0'
  s.resource_bundles = {
    'channel_talk_flutter_privacy' => [
      'channel_talk_flutter/Sources/channel_talk_flutter/PrivacyInfo.xcprivacy'
    ]
  }

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
