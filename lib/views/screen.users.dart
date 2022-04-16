import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tigua_birthday/api/api.dart';
import 'package:tigua_birthday/router/router.routes.dart';
import 'package:tigua_birthday/views/components/user_card.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({ Key? key }) : super(key: key);

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {

  late String licenceType; // this variable will filter licence types
  late final TextEditingController textController;

  @override
  void initState() {
    licenceType = "CUALQUIERA";
    textController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    
    // fetching new initial data.
    API().queryUsersByFilter(licenceType, textController.text, true);

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
          MaterialButton(
            color: Colors.indigo,
            textColor: Colors.white,
            child: const Text("Buscar"),
            onPressed: ()async{
              
              textController.text = textController.text.trim();

              SmartDialog.showLoading();
              await API().queryUsersByFilter(licenceType, textController.text);
              SmartDialog.dismiss();

            }
          ),
          ListTile(
            leading: const Icon(Icons.filter),
            title: const Text("Tipo de licencias"),
            trailing: DropdownButton<String>(
              value: licenceType,
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
                  licenceType = selected ?? "CUALQUIERA";
                });
              }
            ),
          ),
	  ListTile(
	      title: const Text("Búsqueda por cargos"),
	      subtitle: const Text("Iniciar búsqueda avanzada"),
	      leading: const Icon(Icons.work_outline),
	      trailing: MaterialButton(
		color: Colors.indigo,
		textColor: Colors.white,
		child: const Text("Empezar"),
		onPressed: ()async{
		  Navigator.of(context).pushNamed(RouteNames.filterCargo.toString());
		}
	      ),
	  ),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: API().dataStream.stream,
            builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if(!snapshot.hasData || ((snapshot.data?.isEmpty ?? true) && API().isLoading)) {
                return const Center(child: CircularProgressIndicator(),);
              }

              final List<Map<String, dynamic>> data = snapshot.data!;

              if(data.isEmpty) {
                return Expanded(
                  child: RefreshIndicator(
                    onRefresh: ()async{
                      // This will purge all the elements by default
                      setState(() {});
                    },
                    child: ListView(
                      children: const [
                        Center(
                          child: Text("No hay elementos"),
                        )
                      ],
                    ),
                  ),
                );
              }

              final scrollController = ScrollController();

              scrollController.addListener(() {
                if(scrollController.offset >= scrollController.position.maxScrollExtent * 0.7
                  && scrollController.position.maxScrollExtent > size.height
                ) {
                  API().queryUsersByFilter(licenceType, textController.text);
                }
              });

              return Expanded(
                child: RefreshIndicator(
                  onRefresh: ()async{
                    // This will purge all the elements by default
                    setState(() {});
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: scrollController,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                
                      return UserCardComponent(userData: data[index]);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


}
