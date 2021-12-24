import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tigua_birthday/api/api.dart';
import 'package:tigua_birthday/helpers/notifications.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {

  Workmanager().executeTask((task, inputData) async {

    print(inputData?['title']);
    print(inputData?['content']);
    Notifications().show(
      inputData?['title'] ?? "Tienes notificaciones nuevas", 
      inputData?['content'] ?? "Abra la app para ver los detalles"
    );

    // type could be:
    // 1. sync
    // 2. reminder - when someone is in birthday
    final String type = inputData!["type"];

    final connectivityResult = await (Connectivity().checkConnectivity());

    // Cannot auto synchronize without wifi connection
    if(connectivityResult != ConnectivityResult.wifi) {
      return Future.value(true);
    }

    switch(type) {
      case "sync": 
        final status = await Permission.storage.status;

        // Removing old birthday reminders
        List<Map<String, dynamic>> birthdayList = await API().queryCumpleaneros();

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


        // birthdayList = List<Map<String, dynamic>>.from(birthdayList.where((element) {
        //   return DateTime.parse(element["fnacimiento"]).day == DateTime.now().day;
        // }));

        final jsonEncoded = json.encode(List<Map<String, dynamic>>.from(birthdayList));

        if(!status.isDenied) {
          try {
            await WritterHelper().writeFileJson(jsonEncoded);
          }catch(_) {
            // If there is any error do nothing
          }
        }

        final todayUsers = List<Map<String, dynamic>>.from(birthdayList.where(
          (user) {
            // I only check the day because the month is filtered in the request
            return DateTime.parse(user["fnacimiento"]).day == DateTime.now().day;
          }
        ));

        if(todayUsers.isNotEmpty) {
          // It has a delay of 7 hours 'cause it's created at 00h00
          await Workmanager().registerOneOffTask(
            "birthdays",
            "Recordatorio de cumpleaños",
            initialDelay: const Duration(hours: 7),
            inputData: {
              "type": "reminder",
              "title": "Hoy cumplen años ${todayUsers.length} personas",
              "content": "Entra en la app y deséales lo mejor!"
            }
          );
        }
        break;
    }
    
    return Future.value(true);
  });
}

/// This class will be the one that write in your internal storage
/// in order to sync files later with backend. The format of file
/// will be json, the same json you'll get from backend requests and
/// will be use to notify users even if they have no internet access
class WritterHelper {

  Future<void> writeFileJson(String data) async {
    final directory = Directory("${(await getApplicationDocumentsDirectory()).path}/temp");

    // if not exits then create a new one
    if(!(await directory.exists())) {
      await directory.create(recursive: true);
    }

    final file = File("${directory.path}/birthday_data.json");
    await file.writeAsString(data);
  }


  Future<bool> checkPermission() async {

    final status = await Permission.storage.status;

    if(status.isDenied) {
      SmartDialog.show(
        widget: AlertDialog(
          title: const Text("Sin permisos para sincronizar"),
          content: const Text("La aplicación necesita permisos de escritura para almacenar datos que serán usados cuando no tenga acceso a internet. Por favor, acepte los permisos e intente de nuevo."),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text("Ok"),
              onPressed: () async {
                SmartDialog.dismiss();
                await Permission.storage.request();
              },
            )
          ],
        )
      );
    }

    return (await Permission.storage.status).isGranted;
  }

}