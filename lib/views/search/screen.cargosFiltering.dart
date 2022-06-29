import 'package:flutter/material.dart';

import 'package:flutter_simple_treeview/flutter_simple_treeview.dart';
import 'package:tigua_birthday/api/api.dart';
import 'package:tigua_birthday/router/router.routes.dart';
import 'package:tigua_birthday/ui/constants.dart';
import 'package:tigua_birthday/views/components/user_card.dart';

class CargosFiltering extends StatelessWidget {
	final List<MaterialColor> colors = [
		Colors.blue,
		Colors.blueGrey,
		Colors.lightBlue,
		Colors.cyan,
		Colors.indigo
	];

  CargosFiltering({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Búsqueda por cargos",
            style: TextStyle(color: UIConstatnts.backgroundColor, fontSize: 18),
          ),
          foregroundColor: UIConstatnts.backgroundColor,
          backgroundColor: UIConstatnts.accentColor,
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: UIConstatnts.backgroundColor,
                ),
                onPressed: () => Navigator.of(context)
                    .pushNamed(RouteNames.settings.toString()))
          ],
        ),
        backgroundColor: Colors.grey[200]!,
        body: FutureBuilder<Map<String, dynamic>>(
            future: API().fetchCargos(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final data = snapshot.data!;
              final pastoresNames = data['pastores_names'];
              data.remove('pastores_names');

              // return DynamicTable(data: data, pastoresNames: pastoresNames);
              return SingleChildScrollView(
                  child: TreeView(
					  indent: 10,
					  treeController: TreeController(
						  allNodesExpanded: false
					  ),
                      nodes: decodeStrangeJsonProvidedByTigua(context,
                          pastoresNames, snapshot.data!, 0)));
            }));
  }

  /// Ok dear future developer, at the time I developed this module there was a
  /// JSON provided by Tigua, where you needed to iterate in the tree built by that
  /// JSON and render those options as ExpansionTiles or Cards if you're already
  /// on a leaf, so don't put the blame on my if you feel a little bit frustrated,
  /// remember that as animals, stress in necessary in our life.
  List<TreeNode> decodeStrangeJsonProvidedByTigua(BuildContext context,
      dynamic pastoresNames, dynamic json, int colorIndex) {
    // For some reason this line of code is not detecting Map<String, dynamic> properly
    // and is detected as _InternarLinkedHashMap<String, dynamic> which in theory should
    // be the same but in practice it isn't... Life is hard, bro :'(
    switch (json.runtimeType) {

      /// If [json] is a list then it means it is the leaf of the tree, so I should
      /// return a component different to ExpansionTile.
      case List<Map<String, dynamic>>:
        continue listCase;
      listCase:
      case List:

        // If it is a list it means there are only users
        return List<TreeNode>.from((json as List).map((pastorID) {
          // If it cannot be parsed into a Map, then... yes, it means it is not a Map :)
          try {
            return decodeStrangeJsonProvidedByTigua(
                context,
                pastoresNames,
                Map<String, dynamic>.from(pastorID),
                colorIndex + 1);
          }
          // ignore: empty_catches
          catch (e) {}

          // final _pastorName = <String, dynamic>{};
          final _pastorName = pastoresNames.firstWhere((item) {
            return item['id']?.toString() == pastorID?.toString();
          }, orElse: () => <String, dynamic>{});

          // If it is null then it means the user does not exist
          if ((_pastorName as Map).isEmpty) {
            return TreeNode();
          }

          return TreeNode(
            content: Expanded(
                child: UserCardComponent(
                    userData: _pastorName as Map<String, dynamic>,
                    showIglesia: false,
                    showOrdenacion: false)),
          );
        }));

      // Before you start saying I'm doing it wrong assuming that the default case is
      // always a Map... Yes, I'm doing it wrong, but danger in life is necessary!
      default:
        final size = MediaQuery.of(context).size;

        return List<TreeNode>.from((json as Map).keys.map((key) {
          return TreeNode(
              content: Container(
                width: size.width * 0.8,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: colors[colorIndex],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(key.toString(),
                    style: const TextStyle(color: UIConstatnts.backgroundColor),
                    textAlign: TextAlign.center),
              ),
              children: decodeStrangeJsonProvidedByTigua(
                  context,
                  pastoresNames ?? [],
                  json[key] ?? [],
				  colorIndex + 1));
        }));
    }
  }
}
