import 'package:flutter/material.dart';
import 'package:tigua_birthday/api/api.dart';
import 'package:tigua_birthday/router/router.routes.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({ Key? key }) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {

  late String value;

  @override
  void initState() {
    value = "pastor";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    
    // fetching new initial data.
    API().queryUsersByFilter(value);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Usuarios",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      backgroundColor: Colors.grey[200]!,
      body: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.filter),
            subtitle: const Text("Le permite filtrar por tipo de usuario"),
            title: const Text("Filtro aplicado"),
            trailing: DropdownButton<String>(
              value: value,
              items: const [
                DropdownMenuItem(
                  value: "pastor",
                  child: Text("Pastor"),
                ),
                DropdownMenuItem(
                  value: "esposa",
                  child: Text("Esposas"),
                ),
                DropdownMenuItem(
                  value: "hijos",
                  child:  Text("Hijos"),
                ),
              ], 
              onChanged: (selected) {
                setState(() {
                  value = selected ?? "pastor";
                });
              }
            ),
          ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: API().dataStream.stream,
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(),);
              }

              final List<Map<String, dynamic>> data = snapshot.data!;

              final scrollController = ScrollController();

              scrollController.addListener(() {
                if(scrollController.offset >= scrollController.position.maxScrollExtent * 0.8
                  && scrollController.position.maxScrollExtent > size.height
                ) {
                  API().queryUsersByFilter(value);
                }
              });

              return Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: data.length,
                  itemBuilder: (context, index) {

                    String? photoUrl;

                    switch(value) {
                      case "pastor": 
                        String photoID = (data[index]['foto_pastor'] ?? "").split('/').last;
                        photoUrl = "https://oficial.cedeieanjesus.org/uploads/foto_pastor/$photoID";
                        break;
                      case "esposa":
                        String photoID = (data[index]['foto_esposa'] ?? "").split('/').last;
                        photoUrl = "https://oficial.cedeieanjesus.org/uploads/foto_esposa_pastor/$photoID";
                        break;
                    }

                    return Card(
                      elevation: 2.0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: Hero(
                                tag: data[index]["cedula"],
                                child: SizedBox(
                                  width: size.width * 0.15,
                                  height: size.width * 0.15,
                                  child: photoUrl == null?
                                    const Icon(Icons.person):
                                    ClipRRect(
                                      // clipBehavior: Clip.hardEdge,
                                      borderRadius: BorderRadius.circular(50),
                                      child: FadeInImage.assetNetwork(
                                        image: photoUrl,
                                        imageErrorBuilder: (_, __, ___) {
                                          return const Icon(Icons.image_not_supported_rounded);
                                        },
                                        alignment: Alignment.center,
                                        // width: size.width * 0.1,
                                        // height: size.width * 0.1,
                                        fit: BoxFit.cover,
                                        placeholder: "assets/loader.gif",
                                      ),
                                    ),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios_outlined),
                                onPressed: ()=>Navigator.of(context).pushNamed(RouteNames.user.toString(), arguments: data[index]),
                              ),
                              title: Text("${data[index]["apellidos"] ?? data[index]["nombre_pastor"]} ${data[index]["apellidos"] != null? data[index]["nombres"] ?? "":data[index]["apellido_pastor"]}"),
                              subtitle: Text("${data[index]["cedula"]}"),
                            ),
                          ),
                        ],
                      )
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}