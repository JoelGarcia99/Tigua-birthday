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

                    return Card(
                      elevation: 2.0,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios_outlined),
                                onPressed: ()=>Navigator.of(context).pushNamed(RouteNames.user.toString(), arguments: data[index]),
                              ),
                              title: Text("${data[index]["apellidos"]}"),
                              subtitle: Text("${data[index]["fnacimiento"]}"),
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