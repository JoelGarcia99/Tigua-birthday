
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tigua_birthday/api/api.dart';


void callbackDispatcher() {
  // For God don't even think about removing this fucking line of code. If you're me
  // or you have a decent flutter knowledge you'll know why this is important, but if
  // you don't just don't touch it
  WidgetsFlutterBinding.ensureInitialized();

  
  API().queryCumpleaneros('').then((List<Map<String, dynamic>> birthdayList) async {

    
    final cacheInstance = await SharedPreferences.getInstance();

    // idk why but this thing is showing notifications every 10 minutes even when I
    // set it up to 24 hours -.- so to handle this problem I'm gonna dismiss all
    // notifications before the first one is showed, until the next day
    final int? lastDay = cacheInstance.getInt("last_notification_day");

    if(lastDay != null && lastDay == DateTime.now().day) {
      return;
    }

    birthdayList.sort((a, b){

      final ca = DateTime.parse(a['fnacimiento']);
      final cb = DateTime.parse(b['fnacimiento']);

      // I compare months and add a year if it's higher than current month just
      // to sort dates easier.
      final ya = ca.month > DateTime.now().year? DateTime.now().year + 1:ca.month;
      final yb = cb.month > DateTime.now().year? DateTime.now().year + 1:cb.month;

      return DateTime(ya, ca.month, ca.day).
        compareTo(DateTime(yb, cb.month, cb.day));
    });

    final todayUsers = List<Map<String, dynamic>>.from(birthdayList.where(
      (user) {
        // I only check the day because the month is filtered in the request
        return DateTime.parse(user["fnacimiento"]).day == DateTime.now().day;
      }
    ));

    if(todayUsers.isNotEmpty) {
      // Setting this day as notified, so no more notifications will be showed
      // after 24 hrs
      cacheInstance.setInt("last_notification_day", DateTime.now().day);
      Notifications().show(
        "Tienes ${todayUsers.length} cumpleaños el día de hoy.", 
        "${todayUsers.where((element) => element['tipo'] == "P").length} pastores cumplen años."
      );
    }
    
  });
}

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
            channelKey: 'priority_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests'
        ),
      ],
      debug: false
    );

    final isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  Future<void> show(String title, String body, [String payload = ""]) async {
      
      await Notifications().init();

      AwesomeNotifications(). createNotification(
        content: NotificationContent(
            id: Random().nextInt(3000),
            channelKey: 'priority_channel',
            displayOnForeground: true,
            displayOnBackground: true,
            title: title,
            body: body
        )
      );
  }
}