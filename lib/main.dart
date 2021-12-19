import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tigua_birthday/api/api.dart';
import 'package:tigua_birthday/helpers/helper.writter.dart';
import 'package:tigua_birthday/router/router.routes.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {

    // type could be:
    // 1. sync
    // 2. reminder - when someone is in birthday
    final String type = inputData!["type"];

    switch(type) {
      case "sync": 
        final status = await Permission.storage.status;

        if(!status.isDenied) {
          
          try {
            final birthdayList = await API().queryCumpleaneros();
            final jsonEncoded = json.encode(birthdayList);
            
            await WritterHelper().writeFileJson(jsonEncoded);
          }catch(_) {
            // If there is any error do nothing
          }
        }
        break;
      case "reminder":
    }

    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  // await Workmanager().cancelAll();
  // await Workmanager().registerPeriodicTask(
  //   "1", 
  //   "simpleTask",
  //   frequency: const Duration(seconds: 60),
  //   inputData: {"Name": "Joel"}
  // );
  // await Workmanager().registerOneOffTask(
  //   "sdfsdf", "fddd",
  //   initialDelay: Duration(seconds: 15),
  //   inputData: {"Hi": "Joel"}
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      title: 'Material App',
      initialRoute: RouteNames.home.toString(),
      routes: buildRoutes(),
    );
  }
}