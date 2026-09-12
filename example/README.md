# Channel Talk Flutter example

This app demonstrates the plugin through a path dependency on the parent directory.

## Run on iOS

Follow the [plugin's iOS setup instructions](../README.md#ios), then run:

```sh
flutter pub get
flutter build ios --debug --simulator
```

The example targets iOS 15 or later. Flutter 3.44 enables Swift Package Manager by default,
unless your Flutter configuration disables it. To select the integration for this example,
add the following under the existing `flutter` section in `pubspec.yaml`:

```yaml
flutter:
  config:
    enable-swift-package-manager: true
```

Use `false` to verify the CocoaPods integration. Run `flutter pub get` after changing it.
Neither integration needs a direct `ChannelIOSDK` entry in `ios/Podfile`.

## Xcode package references

Keep the committed Xcode project linked through `FlutterGeneratedPluginSwiftPackage`.
Flutter may add direct local overrides for `channel_talk_flutter` and `FlutterFramework`
to support live diagnostics in Xcode. Leave these generated overrides out of commits:
their package identities can conflict when the checkout directory has a different name.
The aggregate package already supplies the dependencies needed to build the example.
