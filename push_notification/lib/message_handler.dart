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
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {});
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: handleMessage,
      onLaunch: handleLaunchAndResume,
      onResume: handleLaunchAndResume,
      onBackgroundMessage: handleBackground,
    );
  }

  Future<dynamic> handleMessage(Map<String, dynamic> message) async {
    print("message payload: $message");
    var notification = NotificationBody.fromJson(message);

    final snackBar = SnackBar(
      duration: Duration(seconds: 5),
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

    Scaffold.of(context).showSnackBar(snackBar);
  }

  Future<dynamic> handleLaunchAndResume(Map<String, dynamic> message) async {
    print("message payload: $message");
    var notification = NotificationBody.fromJson(message);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            color: Colors.grey[850],
            textColor: Colors.white,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(bottom: 70),
              child: Text(
                "Tópico: TopicNotification",
                style: Theme.of(context).textTheme.headline5,
              )),
          FlatButton(
            child: Text(
              'Realizar Inscrição',
            ),
            color: Colors.grey[850],
            textColor: Colors.white,
            onPressed: () => _fcm.subscribeToTopic('TopicNotification'),
          ),
          FlatButton(
            child: Text(
              'Cancelar Inscrição',
            ),
            color: Colors.grey[850],
            textColor: Colors.white,
            onPressed: () => _fcm.unsubscribeFromTopic('TopicNotification'),
          ),
        ],
      ),
    );
  }
}

Future<dynamic> handleBackground(Map<String, dynamic> message) async {
  print("message payload: $message");
}
