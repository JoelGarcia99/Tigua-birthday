import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// This class will be the one that write in your internal storage
/// in order to sync files later with backend. The format of file
/// will be json, the same json you'll get from backend requests and
/// will be use to notify users even if they have no internet access
class WritterHelper {

  Future<void> writeFileJson(String data) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/temp/birthday_data.json');
    file.writeAsString(data);
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