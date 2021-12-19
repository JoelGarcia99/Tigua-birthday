import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tigua_birthday/api/api.dart';
import 'package:tigua_birthday/helpers/helper.writter.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Opciones",
          style: TextStyle(color: Colors.black),
        ),
        foregroundColor: Colors.black,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.sync),
            title: const Text("Sincronizar datos"),
            subtitle: const Text("Guardar datos localmente para usarlos offline. Este proceso es realizado de forma automática a las 00h00 cuando está conectado a una red wifi."),
            onTap: () async {
              SmartDialog.showLoading();
              if(await WritterHelper().checkPermission()) {
                 try {
                  final birthdayList = await API().queryCumpleaneros();
                  final jsonEncoded = json.encode(birthdayList);
                  
                  await WritterHelper().writeFileJson(jsonEncoded);
                  SmartDialog.showToast("Datos sincronizados con éxito");
                }catch(e) {
                  print(e);
                  SmartDialog.showToast("Error sincronizando, intente más tarde", 
                    time: const Duration(seconds: 2)
                  );
                }
              }
              SmartDialog.dismiss();
            },
          )
        ],
      ),
    );
  }
}