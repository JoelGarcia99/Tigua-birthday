import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tigua_birthday/api/api.dart';
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
      body: FutureBuilder<Map<String, dynamic>>(
        future: API().queryUserByID(user['id'], user['tipo']),
        builder: (context, snapshot) {

          if(!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(),);
          }

          final userData = snapshot.data!;

          String? photoUrl;
          
          switch((user['tipo'] as String).trim().toUpperCase()) {
            case "E":
              String photoID = (userData['foto_esposa'] ?? "sin_foto.jpg").split('/').last;
              photoUrl = "https://oficial.cedeieanjesus.org/uploads/foto_esposa_pastor/$photoID";
              break;
            case "P":
              String photoID = (userData['foto_pastor'] ?? "sin_foto.jpg").split('/').last;
              photoUrl = "https://oficial.cedeieanjesus.org/uploads/foto_pastor/$photoID";
              break;
            case "H":
            default:
              String photoID = ("sin_foto.jpg").split('/').last;
              photoUrl = "https://oficial.cedeieanjesus.org/uploads/foto_pastor/$photoID";
              break;
          }

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: size.width * 0.4,
                      height: size.width * 0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: FadeInImage.assetNetwork(
                          image: photoUrl,
                          imageErrorBuilder: (_, __, ___) {
                            return const Icon(Icons.image_not_supported_rounded);
                          },
                          alignment: Alignment.center,
                          fit: BoxFit.cover,
                          placeholder: "assets/loader.gif",
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        "${userData["apellidos"] ?? userData["nombre_pastor"]} ${userData["apellidos"] != null? userData["nombres"] ?? "":userData["apellido_pastor"]}",
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text("Cédula"),
                subtitle: Text("${userData["cedula"]}"),
              ),
              ListTile(
                leading: const Icon(Icons.flag),
                title: const Text("Nacionalidad"),
                subtitle: Text("${userData["nacionalidad"] ?? "No disponible"}"),
              ),
      
              if(userData.containsKey("foto_hijo")) ...loadPastorHijoData(userData),
              if(userData.containsKey("foto_esposa")) ...loadPastorEsposaData(userData),
              if(userData.containsKey("foto_pastor")) ...loadPastorData(size, userData),
              
            ],
          );
        }
      ),
    );
  }

  List<Widget> loadPastorData(Size size, Map<String, dynamic> user) {
    return <Widget>[
      ListTile(
        leading: const Icon(Icons.indeterminate_check_box_sharp),
        title: const Text("Licencia"),
        subtitle: Text("${user["licencia"]}"),
      ),
      ListTile(
        leading: const Icon(Icons.smartphone),
        title: const Text("Número de teléfono"),
        subtitle: Text("${(user["celular"] ?? "").trim().isNotEmpty? user["celular"]:"No disponible"}"),
        trailing: SizedBox(
          width: size.width * 0.3,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: ()async{
                  SmartDialog.showLoading();
                  // final link = WhatsAppUnilink(
                  //   phoneNumber: ,
                  //   text: "Felicidades! Disfruta este día.",
                  // );

                  await launch('tel:${user["celular"]}');
                  SmartDialog.dismiss();
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble),
                onPressed: ()async{
                  SmartDialog.showLoading();
                  final link = WhatsAppUnilink(
                    phoneNumber: user["celular"],
                    text: "Felicidades! Disfruta este día.",
                  );

                  await launch('$link');
                  SmartDialog.dismiss();
                },
              ),
            ],
          ),
        ),
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