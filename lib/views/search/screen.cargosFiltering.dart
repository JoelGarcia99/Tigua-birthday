import 'package:flutter/material.dart';
import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:tigua_birthday/api/api.dart';
import 'package:tigua_birthday/router/router.routes.dart';

class CargosFiltering extends StatelessWidget {
  const CargosFiltering({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Búsqueda por cargos",
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          foregroundColor: Colors.black,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.black,
                ),
                onPressed: () => Navigator.of(context)
                    .pushNamed(RouteNames.settings.toString()))
          ],
        ),
        backgroundColor: Colors.grey[200]!,
        body: SingleChildScrollView(
            child: FutureBuilder<Map<String, dynamic>>(
                future: API().fetchCargos(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

		  List<Map<String, dynamic>> pastoresNames = snapshot.data!['pastores_names'];
		  (snapshot.data! as Map).remove('pastores_names');

                  return TreeView(
		      treeController: TreeController(
			  allNodesExpanded: false
		      ),
		      indent: 15,
                      nodes: decodeStrangeJsonProvidedByTigua(context, pastoresNames, snapshot.data!));
                })));
  }

  /// Ok dear future developer, at the time I developed this module there was a
  /// JSON provided by Tigua, where you needed to iterate in the tree built by that
  /// JSON and render those options as ExpansionTiles or Cards if you're already
  /// on a leaf, so don't put the blame on my if you feel a little bit frustrated,
  /// remember that as animals, stress in necessary in our life.
  List<TreeNode> decodeStrangeJsonProvidedByTigua(BuildContext context, dynamic pastoresNames, dynamic json) {
    // For some reason this line of code is not detecting Map<String, dynamic> properly
    // and is detected as _InternarLinkedHashMap<String, dynamic> which in theory should
    // be the same but in practice it isn't... Life is hard, bro :'(
    switch (json.runtimeType) {

      /// If [json] is a list then it means it is the leaf of the tree, so I should
      /// return a component different to ExpansionTile.
      case List<Map<String, dynamic>>: 
	continue listCase;
      listCase: case List:

	// If it is a list it means there are only users
        return List<TreeNode>.from((json as List).map((pastorID) {

	  // If it cannot be parsed into a Map, then... yes, it means it is not a Map :)
	  try {
	    return decodeStrangeJsonProvidedByTigua(context, pastoresNames, Map<String, dynamic>.from(pastorID ));
	  }
	  // ignore: empty_catches
	  catch(e) {}


	  // final _pastorName = <String, dynamic>{};
	  final _pastorName = pastoresNames.firstWhere(
	      (item) {
	       return item['id']?.toString() == pastorID?.toString();
	     },
	     orElse: ()=><String, dynamic>{}
	 );

	  // If it is null then it means the user does not exist
	  if((_pastorName as Map).isEmpty) {
	    return TreeNode();
	  }

          return TreeNode(
	    content: Expanded(
		child: GestureDetector(
		    onTap: ()=>Navigator.pushNamed(
			context,
			RouteNames.user.toString(), 
			arguments: {
			  'id': _pastorName['id'],
			  'apellidos': _pastorName['apellido_pastor'],
			  'tipo': 'P'
			}
		    ),
	        child: Container(
		  decoration: BoxDecoration(
		      borderRadius: BorderRadius.circular(8.0),
		      color: Colors.indigo,
		      boxShadow:  [
			BoxShadow(
			    color:  Colors.grey[400]!,
			    offset:  const Offset(3.0, 3.0),
			    blurRadius:  2.0,
			    spreadRadius: 2.0
			)
		      ]
		  ),
		  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 15.0),
		  margin: const EdgeInsets.only(right: 8.0, bottom: 10.0),
		  child: Text(
		      "${_pastorName['apellido_pastor']} ${_pastorName['nombre_pastor']}",
		      style: const TextStyle(
			  fontWeight: FontWeight.bold,
			  color:  Colors.white
		      )
		  )
	        ),
	      ),
	    )
	  );
        }));

      // Before you start saying I'm doing it wrong assuming that the default case is
      // always a Map... Yes, I'm doing it wrong, but danger in life is necessary!
      default:
        return List<TreeNode>.from((json as Map).keys.map((key) {
          return TreeNode(
              content: Row(
                children: [
		  const Icon(Icons.label_outlined),
		  const SizedBox(width: 8.0),
                  Text(key.toString()),
                ],
              ),
              children: decodeStrangeJsonProvidedByTigua(context, pastoresNames ?? [], json[key] ?? []));
        }));
    }
  }
}
