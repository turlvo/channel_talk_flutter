#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint channel_talk.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'channel_talk_flutter'
  s.version          = '2.1.1'
  s.summary          = 'A Channel Talk flutter plugin project.(Unofficial)'
  s.description      = <<-DESC
  A Channel Talk flutter plugin project.
                       DESC
  s.homepage         = 'http://deepnatural.ai'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'DeepNatural' => 'yeonho@deepnatural.ai' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'ChannelIOSDK'
  s.platform = :ios, '11.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
end
