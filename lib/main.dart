import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tigua_birthday/helpers/helper.writter.dart';
import 'package:tigua_birthday/helpers/notifications.dart';
import 'package:tigua_birthday/router/router.routes.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Notifications().init();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  final cacheInstance = await SharedPreferences.getInstance();

  // if it's the first time then delete everything if exists (old installations)
  // and create new workers
  if(cacheInstance.getBool("first_time") ?? true) {
    cacheInstance.setBool("first_time", false);
    await Workmanager().cancelAll();

    final currentTime = DateTime.now();
    final targetTime = DateTime.parse("${currentTime.year}-${currentTime.month}-${currentTime.day} 00:00:00").add(const Duration(days: 1));

    // reapeat this every single day
    await Workmanager().registerPeriodicTask(
      "birthday_sync", 
      "Birthday sinchronization",
      initialDelay: Duration(seconds: targetTime.difference(currentTime).inSeconds),
      frequency: const Duration(days: 1),
      inputData: {
        "type": "sync",
        "title": "Datos sincronizados",
        "content": "Se han sincronizado los datos de nuevos cumpleañeros"
      }
    );
    
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      title: 'IEAN Jesús | Agenda pastoral',
      initialRoute: RouteNames.home.toString(),
      routes: buildRoutes(),
    );
  }
}