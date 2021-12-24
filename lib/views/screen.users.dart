import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tigua_birthday/api/api.dart';
import 'package:tigua_birthday/router/router.routes.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({ Key? key }) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {

  late String value;
  late final TextEditingController textController;

  @override
  void initState() {
    value = "CUALQUIERA";
    textController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    
    // fetching new initial data.
    API().queryUsersByFilter(value, textController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "IEAN Jesús | Agenda pastoral",
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black,),
            onPressed: ()=>Navigator.of(context).pushNamed(RouteNames.settings.toString())
          )
        ],
      ),
      backgroundColor: Colors.grey[200]!,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Container(
                padding: const EdgeInsets.symmetric( horizontal: 8.0),
                color: Colors.white,
                child: TextField(
                  controller: textController,
                  autocorrect: true,             
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    focusedBorder: InputBorder.none
                  ),
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.filter),
            title: const Text("Tipo de licencias"),
            trailing: DropdownButton<String>(
              value: value,
              items: const [
                DropdownMenuItem(
                  value: "CUALQUIERA",
                  child: Text("CUALQUIERA"),
                ),
                DropdownMenuItem(
                  value: "ORDENACIÓN",
                  child: Text("ORDENACIÓN"),
                ),
                DropdownMenuItem(
                  value: "LOCAL",
                  child: Text("LOCAL"),
                ),
                DropdownMenuItem(
                  value: "ASPIRANTE",
                  child:  Text("ASPIRANTE"),
                ),
                DropdownMenuItem(
                  value: "NACIONAL",
                  child:  Text("NACIONAL"),
                ),
              ], 
              onChanged: (selected) {
                setState(() {
                  value = selected ?? "CUALQUIERA";
                });
              }
            ),
          ),
          MaterialButton(
            color: Colors.indigo,
            textColor: Colors.white,
            child: const Text("Buscar"),
            onPressed: ()async{
              
              textController.text = textController.text.trim();

              if(textController.text.length < 4) {
                SmartDialog.showToast("Debe ingresar al menos 4 caracteres", time: const Duration(seconds: 2));
                return;
              }

              SmartDialog.showLoading();
              await API().queryUsersByFilter(value, textController.text);
              SmartDialog.dismiss();

            }
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: API().dataStream.stream,
            builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if(!snapshot.hasData || ((snapshot.data?.isEmpty ?? true) && API().isLoading)) {
                return const Center(child: CircularProgressIndicator(),);
              }

              final List<Map<String, dynamic>> data = snapshot.data!;

              if(data.isEmpty) {
                return const Center(
                  child: Text("No hay elementos"),
                );
              }

              final scrollController = ScrollController();

              scrollController.addListener(() {
                if(scrollController.offset >= scrollController.position.maxScrollExtent * 0.7
                  && scrollController.position.maxScrollExtent > size.height
                ) {
                  API().queryUsersByFilter(value, textController.text);
                }
              });

              return Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: data.length,
                  itemBuilder: (context, index) {

                    return _getCard(context, data[index]);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
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
                    const TextSpan(text: "Iglesia: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "${data["nombre_iglesia"]}"),
                    const TextSpan(text: "\nLicencia: ", style: TextStyle(fontWeight: FontWeight.bold)),
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