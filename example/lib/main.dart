import 'dart:convert';

import 'package:channel_talk_flutter_plus/channel_talk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  String content = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void showSnackBar(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  void showInputDialog({required String title, required VoidCallback onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextFormField(
              initialValue: content,
              maxLines: null,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              textInputAction: TextInputAction.newline,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: (text) => content = text,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onOk();
                    content = '';
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Example')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
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
                title: 'boot payload',
                onOk: () async {
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

                    showSnackBar('Result: $result');
                  } on PlatformException catch (error) {
                    showSnackBar('PlatformException: ${error.message}');
                  } catch (err) {
                    showSnackBar(err.toString());
                  }
                },
              );
            },
            child: const Text('boot'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final result = await ChannelTalk.sleep();

                showSnackBar('Result: $result');
              } on PlatformException catch (error) {
                showSnackBar('PlatformException: ${error.message}');
              } catch (err) {
                showSnackBar(err.toString());
              }
            },
            child: const Text('sleep'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final result = await ChannelTalk.shutdown();

                showSnackBar('Result: $result');
              } on PlatformException catch (error) {
                showSnackBar('PlatformException: ${error.message}');
              } catch (err) {
                showSnackBar(err.toString());
              }
            },
            child: const Text('shutdown'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final result = await ChannelTalk.showChannelButton();

                showSnackBar('Result: $result');
              } on PlatformException catch (error) {
                showSnackBar('PlatformException: ${error.message}');
              } catch (err) {
                showSnackBar(err.toString());
              }
            },
            child: const Text('showChannelButton'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final result = await ChannelTalk.hideChannelButton();

                showSnackBar('Result: $result');
              } on PlatformException catch (error) {
                showSnackBar('PlatformException: ${error.message}');
              } catch (err) {
                showSnackBar(err.toString());
              }
            },
            child: const Text('hideChannelButton'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final result = await ChannelTalk.showMessenger();

                showSnackBar('Result: $result');
              } on PlatformException catch (error) {
                showSnackBar('PlatformException: ${error.message}');
              } catch (err) {
                showSnackBar(err.toString());
              }
            },
            child: const Text('showMessenger'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final result = await ChannelTalk.hideMessenger();

                showSnackBar('Result: $result');
              } on PlatformException catch (error) {
                showSnackBar('PlatformException: ${error.message}');
              } catch (err) {
                showSnackBar(err.toString());
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
                  title: 'openChat payload',
                  onOk: () async {
                    try {
                      Map args = json.decode(content);
                      final result = await ChannelTalk.openChat(
                        chatId: args['chatId'],
                        message: args['message'],
                      );

                      showSnackBar('Result: $result');
                    } on PlatformException catch (error) {
                      showSnackBar('PlatformException: ${error.message}');
                    } catch (err) {
                      showSnackBar(err.toString());
                    }
                  },
                );
              } on PlatformException catch (error) {
                showSnackBar('PlatformException: ${error.message}');
              } catch (err) {
                showSnackBar(err.toString());
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
                title: 'track payload',
                onOk: () async {
                  try {
                    Map args = json.decode(content);
                    final result = await ChannelTalk.track(
                      eventName: args['eventName'],
                      properties: args['properties'],
                    );

                    showSnackBar('Result: $result');
                  } on PlatformException catch (error) {
                    showSnackBar('PlatformException: ${error.message}');
                  } catch (err) {
                    showSnackBar(err.toString());
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
                title: 'updateUser payload',
                onOk: () async {
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

                    showSnackBar('Result: $result');
                  } on PlatformException catch (error) {
                    showSnackBar('PlatformException: ${error.message}');
                  } catch (err) {
                    showSnackBar(err.toString());
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
                title: 'initPushToken payload',
                onOk: () async {
                  try {
                    final result =
                        await ChannelTalk.initPushToken(deviceToken: content);

                    showSnackBar('Result: $result');
                  } on PlatformException catch (error) {
                    showSnackBar('PlatformException: ${error.message}');
                  } catch (err) {
                    showSnackBar(err.toString());
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
//                   showInputDialog(title:
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
//                   showInputDialog(title:
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
//                   showInputDialog(title:
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
                final result = await ChannelTalk.hasStoredPushNotification();

                showSnackBar('Result: $result');
              } on PlatformException catch (error) {
                showSnackBar('PlatformException: ${error.message}');
              } catch (err) {
                showSnackBar(err.toString());
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
                  showSnackBar('openStoredPushNotification success');
                } else {
                  showSnackBar('openStoredPushNotification fail');
                }
              } on PlatformException catch (error) {
                showSnackBar('PlatformException: ${error.message}');
              } catch (err) {
                showSnackBar(err.toString());
              }
            },
            child: const Text('openStoredPushNotification'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final bool? result = await ChannelTalk.isBooted();

                if (result!) {
                  showSnackBar('isBooted success');
                } else {
                  showSnackBar('isBooted fail');
                }
              } on PlatformException catch (error) {
                showSnackBar('PlatformException: ${error.message}');
              } catch (err) {
                showSnackBar(err.toString());
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
                title: 'initPushToken payload',
                onOk: () async {
                  Map args = json.decode(content);

                  try {
                    final result =
                        await ChannelTalk.setDebugMode(flag: args['flag']);

                    showSnackBar('Result: $result');
                  } on PlatformException catch (error) {
                    showSnackBar('PlatformException: ${error.message}');
                  } catch (err) {
                    showSnackBar(err.toString());
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
  "page": "Custom Value"
}
              ''';

              showInputDialog(
                title: 'page payload',
                onOk: () async {
                  Map args = json.decode(content);

                  try {
                    final result =
                        await ChannelTalk.setPage(page: args['page']);

                    showSnackBar('Result: $result');
                  } on PlatformException catch (error) {
                    showSnackBar('PlatformException: ${error.message}');
                  } catch (err) {
                    showSnackBar(err.toString());
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

                showSnackBar('Result: $result');
              } on PlatformException catch (error) {
                showSnackBar('PlatformException: ${error.message}');
              } catch (err) {
                showSnackBar(err.toString());
              }
            },
            child: const Text('resetPage'),
          ),
        ],
      ),
    );
  }
}
