#import "ChannelTalkPlugin.h"
#if __has_include(<channel_talk/channel_talk-Swift.h>)
#import <channel_talk/channel_talk-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "channel_talk-Swift.h"
#endif



@implementation ChannelTalkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftChannelTalkPlugin registerWithRegistrar:registrar];
}
@end
