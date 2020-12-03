import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'model/notification.dart';


class MessageHandler extends StatefulWidget {
  @override
  _MessageHandlerState createState() => _MessageHandlerState();
}

class _MessageHandlerState extends State<MessageHandler> {
  //final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  StreamSubscription iosSubscription;

  _MessageHandlerState() {
    _getDeviceToken();
  }

  _getDeviceToken() async {
    String token = await _fcm.getToken();
    print("FirebaseMessaging token: $token");
  }

  @override
  initState() {
    super.initState();

    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("message payload: $message");
        var notification = NotificationBody.fromJson(message);
        print(notification);

        final snackBar = SnackBar(
          duration: Duration(seconds: 3),
          content: Text(
            notification.title,
            style: TextStyle(
              fontSize: 18,
            ),
          ),
          action: SnackBarAction(
            label: "Close",
            onPressed: () {
              Scaffold.of(context).hideCurrentSnackBar();
            },
          ),
        );

        Scaffold.of(context)
            .
        showSnackBar
          (
            snackBar
        );
      },
      onLaunch: handleLaunchAndResume,
      onResume: handleLaunchAndResume,
      onBackgroundMessage: handleBackground,
    );
  }

  Future<dynamic> handleLaunchAndResume(Map<String, dynamic> message) async {
    print("message payload: $message");
    var notification = NotificationBody.fromJson(message);
    print(notification);
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            content: ListTile(
              title: Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 23,
                  ),
                ),
              ),
              subtitle: Text(
                notification.body,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            actions: [
              FlatButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return
      Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FlatButton(
              child: Text('O taz é gente boa.'),
              onPressed: () => _fcm.subscribeToTopic('likeTaz'),
            ),
            FlatButton(
              child: Text('Na real eu nem gosto dele.'),
              onPressed: () => _fcm.unsubscribeFromTopic('likeTaz'),
            ),
          ],
        ),
      );
  }
}

Future<dynamic> handleBackground(Map<String, dynamic> message) async {
  print("message payload: $message");
}
