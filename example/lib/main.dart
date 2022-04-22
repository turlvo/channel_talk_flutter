import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:channel_talk_flutter/channel_talk_flutter.dart';
import 'package:toast/toast.dart';

void main() async {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String content = '';
  TextEditingController contentInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    contentInputController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ToastContext().init(context);
  }

  void showMessageToast(message) {
    Toast.show(message, duration: Toast.lengthShort, gravity: Toast.bottom);
  }

  void showInputDialog(title, onClick) {
    contentInputController.text = content;
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return Dialog(
          elevation: 0.0,
          insetPadding: EdgeInsets.symmetric(
            horizontal: 24.0,
            vertical: 24.0,
          ),
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.only(
              top: 40,
              right: 32,
              bottom: 32,
              left: 32,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: const Offset(0.0, 12.0),
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
                    style: TextStyle(
                      color: Color(0XFF1A1A1A),
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: contentInputController,
                      maxLines: null,
                      decoration: InputDecoration(
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
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color.fromRGBO(214, 227, 255, 1.0),
                              width: 2.0,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
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
                      SizedBox(width: 11),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(92, 145, 255, 1.0),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Color.fromRGBO(92, 145, 255, 1.0),
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
                            child: Text(
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
          padding: EdgeInsets.symmetric(
            horizontal: 50,
          ),
          child: ListView(
            children: <Widget>[
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  content = '''
{
  "pluginKey": "",
  "email": "",
  "memberId": "",
  "name": "",
  "memberHash": "",
  "mobileNumber": "",
  "trackDefaultEvent": false,
  "hidePopup": false,
  "language": "english"
}
                            ''';
                  showInputDialog(
                    'boot payload',
                    () async {
                      try {
                        Map args = json.decode(content);
                        final result = await ChannelTalk.boot(
                          pluginKey: args['pluginKey'],
                          memberId: args['memberId'],
                          email: args['email'],
                          name: args['name'],
                          memberHash: args['memberHash'],
                          mobileNumber: args['mobileNumber'],
                          trackDefaultEvent: args['trackDefaultEvent'],
                          hidePopup: args['hidePopup'],
                          language: args['language'],
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
                child: Text('boot'),
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
                child: Text('sleep'),
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
                child: Text('shutdown'),
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
                child: Text('showChannelButton'),
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
                child: Text('hideChannelButton'),
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
                child: Text('showMessenger'),
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
                child: Text('hideMessenger'),
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
                child: Text('openChat'),
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
                child: Text('track'),
              ),
              ElevatedButton(
                onPressed: () async {
                  content = '''
{
  "name": "",
  "mobileNumber": "",
  "email": "",
  "avatarUrl": "https://unsplash.com/photos/oL3-V8xhqlI",
  "customAttributes": {
    "key1": "val1"
  },
  "language": "english",
  "tags": []
}
                            ''';
                  showInputDialog(
                    'updateUser payload',
                    () async {
                      try {
                        Map args = json.decode(content);
                        final result = await ChannelTalk.updateUser(
                          name: args['name'],
                          mobileNumber: args['mobileNumber'],
                          email: args['email'],
                          avatarUrl: args['avatarUrl'],
                          customAttributes: args['customAttributes'],
                          language: args['language'],
                          tags: List<String>.from(args['tags']),
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
                child: Text('updateUser'),
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
                child: Text('initPushToken'),
              ),
              ElevatedButton(
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
              ElevatedButton(
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
              ElevatedButton(
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
                child: Text('hasStoredPushNotification'),
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
                child: Text('openStoredPushNotification'),
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
                child: Text('isBooted'),
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
                child: Text('setDebugMode'),
              ),
              ElevatedButton(
                onPressed: () async {
                  content = '''
{
  "page": "Custom Value"
}
                  ''';

                  showInputDialog(
                    'page payload',
                    () async {
                      Map args = json.decode(content);

                      try {
                        final result =
                            await ChannelTalk.setPage(page: args['page']);

                        showMessageToast('Result: $result');
                      } on PlatformException catch (error) {
                        showMessageToast('PlatformException: ${error.message}');
                      } catch (err) {
                        showMessageToast(err.toString());
                      }
                    },
                  );
                },
                child: Text('setPage'),
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
                child: Text('resetPage'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
