
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class Notifications {
  static Notifications? _instance;

  factory Notifications() {
    _instance ??= Notifications._();

    return _instance!;
  }

  Notifications._();


  Future<void> init() async {

    AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/ic_launcher',
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white
        ),
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
          channelGroupkey: 'basic_channel_group',
          channelGroupName: 'Basic group'
        )
      ],
      debug: true
    );

    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> show(String title, String body, [String payload = ""]) async {
      
      await Notifications().init();

      AwesomeNotifications(). createNotification(
        content: NotificationContent(
            id: Random().nextInt(3000),
            channelKey: 'basic_channel',
            title: title,
            body: body
        )
      );
  }
}