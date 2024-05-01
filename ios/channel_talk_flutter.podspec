#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint channel_talk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'channel_talk_flutter'
  s.version          = '2.6.2'
  s.summary          = 'A Channel Talk flutter plugin project.(Unofficial)'
  s.description      = <<-DESC
  A Channel Talk flutter plugin project.
                       DESC
  s.homepage         = 'http://kuku.pe.kr'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'KuKu' => 'turlvo@gmail.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'ChannelIOSDK', '11.6.0'
  s.platform = :ios, '12.0'
  s.resource_bundles = {'channel_talk_flutter_privacy' => ['PrivacyInfo.xcprivacy']}

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
