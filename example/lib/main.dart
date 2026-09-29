// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:channel_talk_flutter/channel_talk_flutter_platform_interface.dart';
import 'package:toast/toast.dart';

import 'sample_boot.dart';

void main() {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String content = '';
  String popupTimestamp = '수신 대기';
  TextEditingController contentInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    ChannelTalk.removeListener();
    contentInputController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ToastContext().init(context);
  }

  void showMessageToast(message) {
    print(message);
    Toast.show(message, gravity: Toast.bottom, duration: 3);
  }

  void registerListener() {
    ChannelTalk.setListener((event, arguments) {
      switch (event) {
        case ChannelTalkEvent.onShowMessenger:
          print('ON_SHOW_MESSENGER');
          break;
        case ChannelTalkEvent.onHideMessenger:
          print('ON_HIDE_MESSENGER');
          break;
        case ChannelTalkEvent.onChatCreated:
          print('ON_CHAT_CREATED:\nchatId: $arguments');
          break;
        case ChannelTalkEvent.onBadgeChanged:
          print('ON_BADGE_CHANGED:\n$arguments');
          break;
        case ChannelTalkEvent.onFollowUpChanged:
          print('ON_FOLLOW_UP_CHANGED\ndata: $arguments');
          break;
        case ChannelTalkEvent.onUrlClicked:
          print('ON_URL_CLICKED\nurl: $arguments');
          break;
        case ChannelTalkEvent.onPopupDataReceived:
          if (!mounted) return;
          final timestamp = arguments is Map ? arguments['timestamp'] : null;
          setState(() {
            popupTimestamp = timestamp?.toString() ?? 'SDK에서 제공하지 않음';
          });
          break;
        case ChannelTalkEvent.onPushNotificationClicked:
          print('ON_PUSH_NOTIFICATION_CLICKED\nevent: $arguments');
          break;
        default:
          break;
      }
    });
  }

  void unregisterListener() {
    ChannelTalk.removeListener();
  }

  /// 공통 입력 예제로 두 부팅 결과 형식과 웹 전용 옵션을 함께 확인한다.
  void showBootDialog({bool withStatus = false, bool forWeb = false}) {
    final method =
        forWeb ? 'bootForWeb' : (withStatus ? 'bootWithStatus' : 'boot');
    content = const JsonEncoder.withIndent('  ').convert({
      'pluginKey': 'pluginKey',
      'language': 'ko',
      'appearance': 'dark',
      'customAttributes': {'samplePlan': 'pro', 'obsoleteField': null},
      if (forWeb) 'hideChannelButtonOnBoot': false,
      if (!kIsWeb && !forWeb) ...{
        'channelButtonOption': {
          'icon': 'headset',
          'position': 'right',
          'xMargin': 20,
          'yMargin': 24,
        },
        'bubbleOption': {'position': 'bottom'},
      },
    });
    showInputDialog('$method payload', () async {
      try {
        final args = Map<String, dynamic>.from(json.decode(content) as Map);
        final result = await runSampleBoot(
          args,
          withStatus: withStatus,
          forWeb: forWeb,
        );
        if (!mounted) return;
        final value = result is ChannelTalkBootStatus ? result.value : result;
        showMessageToast('Result: $value');
      } on FormatException catch (error) {
        showMessageToast('입력 형식 오류: ${error.message}');
      } on UnsupportedError {
        showMessageToast('이 옵션은 Android/iOS에서만 지원합니다.');
      } on PlatformException catch (error) {
        showMessageToast('SDK 오류: ${error.code}');
      } catch (error) {
        showMessageToast('요청 실패: ${error.runtimeType}');
      }
    });
  }

  void showInputDialog(title, onClick) {
    contentInputController.text = content;
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          elevation: 0.0,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 24.0,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.only(
              top: 40,
              right: 32,
              bottom: 32,
              left: 32,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0.0, 12.0),
                  blurRadius: 24.0,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0XFF1A1A1A),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: contentInputController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Color(0XFF9E9E9E),
                        ),
                      ),
                      textInputAction: TextInputAction.newline,
                      autocorrect: false,
                      enableSuggestions: false,
                      onChanged: (text) {
                        content = text;
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color.fromRGBO(214, 227, 255, 1.0),
                              width: 2.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text(
                              'Cancel',
                              maxLines: 1,
                              style: TextStyle(
                                color: Color.fromRGBO(136, 157, 201, 1.0),
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(92, 145, 255, 1.0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color.fromRGBO(92, 145, 255, 1.0),
                              width: 2.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (onClick != null) {
                                onClick();
                                content = '';
                              }
                            },
                            child: const Text(
                              'OK',
                              maxLines: 1,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Channel Talk Plugin Test'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 50,
          ),
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 20),
              const Text('SDK 옵션 실행 예제'),
              const Text(kIsWeb
                  ? 'Web에서는 커스텀 프로필을 지원합니다. 버튼·팝업 배치는 모바일 전용입니다.'
                  : 'JSON에서 커스텀 프로필, 버튼 아이콘·여백, 팝업 위치를 변경할 수 있습니다.'),
              ElevatedButton(
                onPressed: () => showBootDialog(),
                child: const Text('boot'),
              ),
              ElevatedButton(
                onPressed: () => showBootDialog(withStatus: true),
                child: const Text('bootWithStatus'),
              ),
              ElevatedButton(
                onPressed: () => showBootDialog(forWeb: true),
                child: const Text('bootForWeb'),
              ),
              Text('최근 팝업 timestamp: $popupTimestamp'),
              ElevatedButton(
                onPressed: () async {
                  try {
                    registerListener();

                    showMessageToast('registerListener is called');
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('register listener'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    unregisterListener();

                    showMessageToast('unregisterListener is called');
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('unregister listener'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await ChannelTalk.sleep();

                    showMessageToast('Result: $result');
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('sleep'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await ChannelTalk.shutdown();

                    showMessageToast('Result: $result');
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('shutdown'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await ChannelTalk.showChannelButton();

                    showMessageToast('Result: $result');
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('showChannelButton'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await ChannelTalk.hideChannelButton();

                    showMessageToast('Result: $result');
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('hideChannelButton'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await ChannelTalk.showMessenger();

                    showMessageToast('Result: $result');
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('showMessenger'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await ChannelTalk.hideMessenger();

                    showMessageToast('Result: $result');
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('hideMessenger'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    content = '''
{
  "chatId": "",
  "message": ""
}
                            ''';
                    showInputDialog(
                      'openChat payload',
                      () async {
                        try {
                          Map args = json.decode(content);
                          final result = await ChannelTalk.openChat(
                            chatId: args['chatId'],
                            message: args['message'],
                          );

                          showMessageToast('Result: $result');
                        } on PlatformException catch (error) {
                          showMessageToast(
                              'PlatformException: ${error.message}');
                        } catch (err) {
                          showMessageToast(err.toString());
                        }
                      },
                    );
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('openChat'),
              ),
              ElevatedButton(
                onPressed: () async {
                  content = '''
{
  "eventName": "",
  "properties": {
    "key1": "val1",
    "key2": "val2"
  }
}
                            ''';
                  showInputDialog(
                    'track payload',
                    () async {
                      try {
                        Map args = json.decode(content);
                        final result = await ChannelTalk.track(
                          eventName: args['eventName'],
                          properties: args['properties'],
                        );

                        showMessageToast('Result: $result');
                      } on PlatformException catch (error) {
                        showMessageToast('PlatformException: ${error.message}');
                      } catch (err) {
                        showMessageToast(err.toString());
                      }
                    },
                  );
                },
                child: const Text('track'),
              ),
              ElevatedButton(
                onPressed: () async {
                  content = '''
{

    "name": "name",
    "email": "name@test.com",
    "mobileNumber": "01012341235",
    "avatarUrl": "https://unsplash.com/photos/oL3-V8xhqlI",
    "unsubscribeEmail": false,
    "unsubscribeTexting": false,
    "tags": ["a", "b", "c"],
    "customAttributes": {"custom1": "aaaa","custom2": "bbbb" },
    "profileOnce": {"signupSource": "sample-app", "firstVisit": true}
}
                            ''';
                  showInputDialog(
                    'updateUser payload',
                    () async {
                      try {
                        Map args = json.decode(content);
                        final result = await ChannelTalk.updateUser(
                          name: args['name'],
                          email: args['email'],
                          mobileNumber: args['mobileNumber'],
                          avatarUrl: args['avatarUrl'],
                          unsubscribeEmail: args['unsubscribeEmail'],
                          unsubscribeTexting: args['unsubscribeTexting'],
                          tags: args['tags'] != null
                              ? List<String>.from(args['tags'])
                              : null,
                          language: args['language'] == null
                              ? null
                              : Language.values.firstWhere(
                                  (language) =>
                                      language.value == args['language'],
                                ),
                          customAttributes: args['customAttributes'],
                          profileOnce: args['profileOnce'],
                        );

                        showMessageToast('Result: $result');
                      } on PlatformException catch (error) {
                        showMessageToast('PlatformException: ${error.message}');
                      } catch (err) {
                        showMessageToast(err.toString());
                      }
                    },
                  );
                },
                child: const Text('updateUser'),
              ),
              ElevatedButton(
                onPressed: () async {
                  content = '';

                  showInputDialog(
                    'initPushToken payload',
                    () async {
                      try {
                        final result = await ChannelTalk.initPushToken(
                            deviceToken: content);

                        showMessageToast('Result: $result');
                      } on PlatformException catch (error) {
                        showMessageToast('PlatformException: ${error.message}');
                      } catch (err) {
                        showMessageToast(err.toString());
                      }
                    },
                  );
                },
                child: const Text('initPushToken'),
              ),
              const ElevatedButton(
                onPressed: null,
//                 () async {
//                   content = '''
// { "content": ""}
//                   ''';
//                   showInputDialog(
//                     'isChannelPushNotification payload',
//                     () async {
//                       Map args = json.decode(content);
//                       try {
//                         final result =
//                             await ChannelTalk.isChannelPushNotification(
//                                 content: args);
//
//                         showMessageToast('Result: $result');
//                       } on PlatformException catch (error) {
//                         showMessageToast('PlatformException: ${error.message}');
//                       } catch (err) {
//                         showMessageToast(err.toString());
//                       }
//                     },
//                   );
//                 },
                child: Text('isChannelPushNotification'),
              ),
              const ElevatedButton(
                onPressed: null,
//              () async {
//                   content = '''
// { "content": ""}
//                   ''';
//                   showInputDialog(
//                     'receivePushNotification payload',
//                     () async {
//                       Map args = json.decode(content);
//                       try {
//                         final result =
//                             await ChannelTalk.receivePushNotification(
//                                 content: args);
//
//                         showMessageToast('Result: $result');
//                       } on PlatformException catch (error) {
//                         showMessageToast('PlatformException: ${error.message}');
//                       } catch (err) {
//                         showMessageToast(err.toString());
//                       }
//                     },
//                   );
//                 },
                child: Text('receivePushNotification'),
              ),
              const ElevatedButton(
                onPressed: null,
//              () async {
//                   content = '''
// { "content": ""}
//                   ''';
//                   showInputDialog(
//                     'receivePushNotification payload',
//                     () async {
//                       Map args = json.decode(content);
//                       try {
//                         final result =
//                             await ChannelTalk.storePushNotification(
//                                 content: args);
//
//                         showMessageToast('Result: $result');
//                       } on PlatformException catch (error) {
//                         showMessageToast('PlatformException: ${error.message}');
//                       } catch (err) {
//                         showMessageToast(err.toString());
//                       }
//                     },
//                   );
//                 },
                child: Text('storePushNotification'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result =
                        await ChannelTalk.hasStoredPushNotification();

                    showMessageToast('Result: $result');
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('hasStoredPushNotification'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final bool? result =
                        await ChannelTalk.openStoredPushNotification();

                    if (result!) {
                      showMessageToast('openStoredPushNotification success');
                    } else {
                      showMessageToast('openStoredPushNotification fail');
                    }
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('openStoredPushNotification'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final bool? result = await ChannelTalk.isBooted();

                    if (result!) {
                      showMessageToast('isBooted success');
                    } else {
                      showMessageToast('isBooted fail');
                    }
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('isBooted'),
              ),
              ElevatedButton(
                onPressed: () async {
                  content = '''
{
  "flag": true
}
                  ''';

                  showInputDialog(
                    'initPushToken payload',
                    () async {
                      Map args = json.decode(content);

                      try {
                        final result =
                            await ChannelTalk.setDebugMode(flag: args['flag']);

                        showMessageToast('Result: $result');
                      } on PlatformException catch (error) {
                        showMessageToast('PlatformException: ${error.message}');
                      } catch (err) {
                        showMessageToast(err.toString());
                      }
                    },
                  );
                },
                child: const Text('setDebugMode'),
              ),
              ElevatedButton(
                onPressed: () async {
                  content = '''
{
  "page": "Custom Value",
  "profile": {
    "orderId": "A-100"
  }
}
                  ''';

                  showInputDialog(
                    'page payload',
                    () async {
                      Map args = json.decode(content);

                      try {
                        final result = await ChannelTalk.setPage(
                          page: args['page'],
                          profile: (args['profile'] as Map?)
                              ?.cast<String, dynamic>(),
                        );

                        showMessageToast('Result: $result');
                      } on PlatformException catch (error) {
                        showMessageToast('PlatformException: ${error.message}');
                      } catch (err) {
                        showMessageToast(err.toString());
                      }
                    },
                  );
                },
                child: const Text('setPage'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await ChannelTalk.resetPage();

                    showMessageToast('Result: $result');
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('resetPage'),
              ),
              ElevatedButton(
                onPressed: () async {
                  content = '''
{
"tags" : ["a", "b"]
}
                  ''';

                  showInputDialog(
                    'addTags payload',
                    () async {
                      var args = json.decode(content);

                      try {
                        final result =
                            await ChannelTalk.addTags(tags: args['tags']);

                        showMessageToast('Result: $result');
                      } on PlatformException catch (error) {
                        showMessageToast('PlatformException: ${error.message}');
                      } catch (err) {
                        showMessageToast(err.toString());
                      }
                    },
                  );
                },
                child: const Text('addTags'),
              ),
              ElevatedButton(
                onPressed: () async {
                  content = '''
{
"tags" : ["a", "b"]
}
                  ''';

                  showInputDialog(
                    'removeTags payload',
                    () async {
                      var args = json.decode(content);

                      try {
                        final result =
                            await ChannelTalk.removeTags(tags: args['tags']);

                        showMessageToast('Result: $result');
                      } on PlatformException catch (error) {
                        showMessageToast('PlatformException: ${error.message}');
                      } catch (err) {
                        showMessageToast(err.toString());
                      }
                    },
                  );
                },
                child: const Text('removeTags'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final bool? result = await ChannelTalk.setAppearance(
                        appearance: Appearance.light);

                    if (result!) {
                      showMessageToast('setAppearance success');
                    } else {
                      showMessageToast('setAppearance fail');
                    }
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('setAppearance'),
              ),
              ElevatedButton(
                onPressed: () async {
                  content = '''
{
  "workflowId": ""
}
                            ''';
                  showInputDialog(
                    'openWorkflow payload',
                    () async {
                      try {
                        Map args = json.decode(content);
                        final result = await ChannelTalk.openWorkflow(
                          workflowId: args['workflowId'],
                        );

                        showMessageToast('Result: $result');
                      } on PlatformException catch (error) {
                        showMessageToast('PlatformException: ${error.message}');
                      } catch (err) {
                        showMessageToast(err.toString());
                      }
                    },
                  );
                },
                child: const Text('openWorkflow'),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final result = await ChannelTalk.hidePopup();

                    showMessageToast('Result: $result');
                  } on PlatformException catch (error) {
                    showMessageToast('PlatformException: ${error.message}');
                  } catch (err) {
                    showMessageToast(err.toString());
                  }
                },
                child: const Text('hidePopup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
