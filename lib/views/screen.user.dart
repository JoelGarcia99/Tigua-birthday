import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tigua_birthday/api/api.dart';
import 'package:tigua_birthday/router/router.routes.dart';
import 'package:tigua_birthday/ui/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatsapp_unilink/whatsapp_unilink.dart';

class UserScreen extends StatelessWidget {

  const UserScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final Map<String, dynamic> params = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // if [params] does not have a key named 'user' then the while object of [params]
    // is going to be threated as the user object
    final Map<String, dynamic> user =  params.containsKey("user")? params['user']:params;
    final isBirthday = params['is_birthday'] ?? false;

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Detalles ${isBirthday? "del cumpleañero":"de usuario"}",
        ),
        foregroundColor: UIConstatnts.backgroundColor,
        backgroundColor: UIConstatnts.accentColor,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: !user.containsKey('id')?
          Future.value([user]):API().queryUserByID([user['id']], user['tipo']),
        builder: (context, snapshot) {

          if(!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(),);
          }

	  if(snapshot.data!.isEmpty) {
	    return const Center(child: Text("No encontrado. Intente más tarde"));
	  }

          final userData = snapshot.data!.last;


          if(userData.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  Icon(Icons.person_search_rounded, size: 50.0,),
                  Text("Usuario no encontrado", style: TextStyle(fontSize: 20.0),),
                ],
              ),
            );
          }

          String? photoUrl;
          
          if(user.containsKey("id")) {
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
          }else {
            String photoID = (userData['foto_pastor'] ?? "sin_foto.jpg").split('/').last;
            photoUrl = "https://oficial.cedeieanjesus.org/uploads/foto_pastor/$photoID";
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
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
                    const SizedBox(height: 20,),
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
      
              if(userData.containsKey("foto_hijo")) ...loadPastorHijoData(context, userData),
              if(userData.containsKey("foto_esposa")) ...loadPastorEsposaData(context, userData),
              if(userData.containsKey("foto_pastor")) ...loadPastorData(size, userData),
              
            ],
          );
        }
      ),
    );
  }

  List<Widget> loadPastorData(Size size, Map<String, dynamic> user) {

    String telefono = user["celular"] ?? "";

    if(telefono.length == 10) {
      telefono = telefono.replaceFirst('0', '');
    }
    if(telefono.length > 8) {
      telefono = "+593 $telefono";
    }

    return <Widget>[
      ListTile(
        leading: const Icon(Icons.indeterminate_check_box_sharp),
        title: const Text("Licencia"),
        subtitle: Text("${user["licencia"]}"),
      ),
      if(telefono.trim().isNotEmpty) ListTile(
        leading: const Icon(Icons.smartphone),
        title: const Text("Número de teléfono"),
        subtitle: Text(telefono.trim().isNotEmpty?telefono:"No disponible"),
        trailing: SizedBox(
          width: size.width * 0.3,
          child: Row(
            children: [
              IconButton(
                icon: Image.asset(
		    "assets/icons/phone.png",
		    width: 24
		),
                onPressed: ()async{
                  SmartDialog.showLoading();
                  await launch('tel:$telefono');
                  SmartDialog.dismiss();
                },
              ),
              IconButton(
                icon: Image.asset('assets/icons/whatsapp.png'),
                onPressed: ()async{
                  SmartDialog.showLoading();
                  final link = WhatsAppUnilink(
                    phoneNumber: telefono,
                    text: "Felicidades! Dios le bendiga",
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

  List<Widget> loadPastorEsposaData(BuildContext context, Map<String, dynamic> user) {
    
    final size = MediaQuery.of(context).size;

    String telefono = user["telefono"] ?? "";

    if(telefono.length == 10) {
      telefono = telefono.replaceFirst('0', '');
    }
    if(telefono.length > 8) {
      telefono = "+593 $telefono";
    }
    
    return <Widget>[
      ListTile(
        trailing: const Icon(Icons.arrow_forward_ios),
        leading: const Icon(Icons.person),
        title: const Text("Pastor responsable"),
        subtitle: Text("${user['nombre_pastor']} ${user['apellido_pastor']}"),
        onTap: (){
          Navigator.of(context).pushNamed(
            RouteNames.user.toString(), 
            arguments: {
              'id': user['id_pastor'],
              'apellidos': user['apellido_pastor'],
              'tipo': 'P'
            }
          );
        },
      ),
      if(telefono.trim().isNotEmpty) ListTile(
        leading: const Icon(Icons.smartphone),
        title: const Text("Número de teléfono"),
        subtitle: Text(telefono),
        trailing: SizedBox(
          width: size.width * 0.3,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: ()async{
                  SmartDialog.showLoading();
                  await launch('tel:$telefono');
                  SmartDialog.dismiss();
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble),
                onPressed: ()async{
                  SmartDialog.showLoading();
                  final link = WhatsAppUnilink(
                    phoneNumber: telefono,
                    text: "Felicidades! Dios le bendiga",
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
    ];
  }

  List<Widget> loadPastorHijoData(BuildContext context, Map<String, dynamic> user) {
    
    final size = MediaQuery.of(context).size;
    String telefono = user["telefono"] ?? "";

    if(telefono.length == 10) {
      telefono = telefono.replaceFirst('0', '');
    }
    if(telefono.length > 8) {
      telefono = "+593 $telefono";
    }
    
    return <Widget>[
      ListTile(
        trailing: const Icon(Icons.arrow_forward_ios),
        leading: const Icon(Icons.person),
        title: const Text("Pastor responsable"),
        subtitle: Text("${user['nombre_pastor']} ${user['apellido_pastor']}"),
        onTap: (){
          Navigator.of(context).pushNamed(
            RouteNames.user.toString(), 
            arguments: {
              'id': user['id_pastor'],
              'apellidos': user['apellido_pastor'],
              'tipo': 'P'
            }
          );
        },
      ),

      if(telefono.trim().isNotEmpty) ListTile(
        leading: const Icon(Icons.smartphone),
        title: const Text("Número de teléfono"),
        subtitle: Text(telefono),
        trailing: SizedBox(
          width: size.width * 0.3,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.phone),
                onPressed: ()async{
                  SmartDialog.showLoading();
                  await launch('tel:$telefono');
                  SmartDialog.dismiss();
                },
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble),
                onPressed: ()async{
                  SmartDialog.showLoading();
                  final link = WhatsAppUnilink(
                    phoneNumber: telefono,
                    text: "Felicidades! Dios le bendiga",
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
    ];
  }
}
