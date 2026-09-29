import 'dart:convert';
import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// iOS 실제 화면과 민감한 payload를 제외한 API 결과를 보존한다.
Future<void> main() async {
  await integrationDriver(
    writeResponseOnFailure: true,
    onScreenshot: (name, bytes, [args]) async {
      await File('build/qa/$name.png').create(recursive: true);
      await File('build/qa/$name.png').writeAsBytes(bytes);
      return true;
    },
    responseDataCallback: (data) async {
      await Directory('build/qa').create(recursive: true);
      final safe = Map<String, dynamic>.from(data ?? {})..remove('screenshots');
      await File('build/qa/results.json').writeAsString(jsonEncode(safe));
    },
  );
}
