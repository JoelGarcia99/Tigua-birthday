import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic> user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Usuarios",
        ),
        foregroundColor: Colors.black,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: Hero(
                tag: user["cedula"],
                child: SizedBox(
                  width: size.width * 0.2,
                  height: size.width * 0.3,
                  child: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                ),
              ),
              title: const Text("Nombres y apellidos"),
              subtitle: Text("${user["apellidos"] ?? user["nombre_pastor"]} ${user["apellidos"] != null? user["nombres"] ?? "":user["apellido_pastor"]}"),
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("Cédula"),
            subtitle: Text("${user["cedula"]}"),
          ),
          ListTile(
            leading: const Icon(Icons.flag),
            title: const Text("Nacionalidad"),
            subtitle: Text("${user["nacionalidad"] ?? "No disponible"}"),
          ),

          if(user.containsKey("foto_hijo")) ...loadPastorHijoData(user),
          if(user.containsKey("foto_esposa")) ...loadPastorEsposaData(user),
          if(user.containsKey("foto_pastor")) ...loadPastorData(user),
          
        ],
      ),
    );
  }

  List<Widget> loadPastorData(Map<String, dynamic> user) {
    return <Widget>[
      ListTile(
        leading: const Icon(Icons.indeterminate_check_box_sharp),
        title: const Text("Licencia"),
        subtitle: Text("${user["licencia"]}"),
      ),
      ListTile(
        leading: const Icon(Icons.smartphone),
        title: const Text("Número de teléfono"),
        subtitle: Text("${(user["celular"] as String).trim().isNotEmpty? user["celular"]:"No disponible"}"),
        trailing: const Icon(Icons.call),
        onTap: () async {
          SmartDialog.showLoading();
          // final link = WhatsAppUnilink(
          //   phoneNumber: ,
          //   text: "Felicidades! Disfruta este día.",
          // );

          await launch('tel:${user["celular"]}');
          SmartDialog.dismiss();
        },
      ),
      ListTile(
        leading: const Icon(Icons.baby_changing_station),
        title: const Text("Fecha de nacimiento"),
        subtitle: Text("${user["fcha_nac"]}"),
      ),
      ListTile(
        leading: const Icon(Icons.house),
        title: const Text("Igelsia"),
        subtitle: Text("${user["nombre_iglesia"]}"),
      ),
      ListTile(
        leading: const Icon(Icons.remove_red_eye),
        title: const Text("Observación"),
        subtitle: Text("${user["observacion"]}"),
      ),
    ];
  }

  List<Widget> loadPastorEsposaData(Map<String, dynamic> user) {
    return <Widget>[
      ListTile(
        leading: const Icon(Icons.smartphone),
        title: const Text("Número de teléfono"),
        subtitle: Text("${(user["telefono"] as String).trim().isNotEmpty? user["telefono"]:"No disponible"}"),
      ),
      ListTile(
        leading: const Icon(Icons.baby_changing_station),
        title: const Text("Fecha de nacimiento"),
        subtitle: Text("${user["fnacimiento"]}"),
      ),
      ListTile(
        leading: const Icon(Icons.engineering),
        title: const Text("Instrucción"),
        subtitle: Text("${user["instruccion"]}"),
      ),
      ListTile(
        leading: const Icon(Icons.handyman),
        title: const Text("Especialidad"),
        subtitle: Text("${user["especialidad"]}"),
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text("Pastor"),
        subtitle: Text("${user['nombre_pastor']} ${user['apellido_pastor']}"),
      )
    ];
  }

  List<Widget> loadPastorHijoData(Map<String, dynamic> user) {
    return <Widget>[
      ListTile(
        leading: const Icon(Icons.smartphone),
        title: const Text("Número de teléfono"),
        subtitle: Text("${(user["telefono"] as String).trim().isNotEmpty? user["telefono"]:"No disponible"}"),
      ),
      ListTile(
        leading: const Icon(Icons.smartphone),
        title: const Text("Correo"),
        subtitle: Text("${(user["correo"] as String).trim().isNotEmpty? user["correo"]:"No disponible"}"),
      ),
      ListTile(
        leading: const Icon(Icons.baby_changing_station),
        title: const Text("Fecha de nacimiento"),
        subtitle: Text("${user["fnac"]}"),
      ),
      ListTile(
        leading: const Icon(Icons.engineering),
        title: const Text("Instrucción"),
        subtitle: Text("${user["estudios"]}"),
      ),
      ListTile(
        leading: const Icon(Icons.person),
        title: const Text("Pastor"),
        subtitle: Text("${user['nombre_pastor']} ${user['apellido_pastor']}"),
      )
    ];
  }
}