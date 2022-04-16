import 'package:flutter/material.dart';
import 'package:tigua_birthday/router/router.routes.dart';

class UserCardComponent extends StatelessWidget {

  final Map<String, dynamic> userData;
  final bool showIglesia;
  final bool showOrdenacion;

  const UserCardComponent({
    Key? key,
    required this.userData,
    this.showOrdenacion = true,
    this.showIglesia = true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _getCard(context, userData);
  }

  Card _getCard(BuildContext context, Map<String, dynamic> data) {

    final size = MediaQuery.of(context).size;
          
    String photoID = (data['foto_pastor'] ?? "sin_foto.jpg").split('/').last;
    
    String photoUrl = "https://oficial.cedeieanjesus.org/uploads/foto_pastor/$photoID";

    return Card(
      elevation: 2.0,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading:  SizedBox(
                width: size.width * 0.15,
                height: size.width * 0.15,
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
              onTap: ()=>Navigator.of(context).pushNamed(
                RouteNames.user.toString(), 
                arguments: {
                  'id': data['id'],
                  'apellidos': data['apellido_pastor'],
                  'tipo': 'P'

                }
              ),
              title: Text("${data["apellidos"]?? (data['apellido_pastor'] + " " + data['nombre_pastor'])}"),
              subtitle: Text.rich(
                TextSpan(
                  children: [
                    if(showIglesia) 
		      const TextSpan(text: "Iglesia: ", style: TextStyle(fontWeight: FontWeight.bold)),
		    if( showIglesia)
		      TextSpan(text: "${data["nombre_iglesia"]}"),
                    TextSpan(
		      text: showOrdenacion? "\nLicencia: ":"Licencia",
		      style: const TextStyle(fontWeight: FontWeight.bold)
		    ),
                    TextSpan(text: "${data["licencia"]}"),
                  ]
                )
              )
            ),
          ),
        ],
      )
    );
  }
}
