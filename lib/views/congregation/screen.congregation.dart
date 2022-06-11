import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:tigua_birthday/api/api.dart';
import 'package:tigua_birthday/components/component.specialCard.dart';
import 'package:tigua_birthday/ui/constants.dart';

class CongregationScreen extends StatelessWidget {
  static const expandedHeight = 300.0;

  const CongregationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String congregationID =
        ModalRoute.of(context)!.settings.arguments as String;

    // Base url for the image
    String imageUrl = "https://ieanjesusoficial.org/uploads/fotos_panoramicas/";

    return Scaffold(
        body: FutureBuilder<Map<String, dynamic>>(
            future: API().fetchCongregationData(congregationID),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.arrow_back),
                      onTap: () => Navigator.pop(context),
                    ),
                    const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ],
                );
              }

              final congregation = snapshot.data!;

              return CustomScrollView(
                slivers: [
                  _getAppBar(congregation, imageUrl, context),
                  _getBody(context, congregation)
                ],
              );
            }));
  }

  SliverAppBar _getAppBar(Map<String, dynamic> congregation, String imageUrl,
      BuildContext context) {
    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      flexibleSpace: Stack(
        children: [
          FlexibleSpaceBar(
              title: null,
              background: FadeInImage.assetNetwork(
                placeholder: 'assets/loader.gif',
                image: congregation['panoramica_exterior'] != null
                    ? "$imageUrl/${congregation['panoramica_exterior']}"
                    : "https://img.rawpixel.com/s3fs-private/rawpixel_images/website_content/rm424-a08-mockup.jpg?w=800&dpr=1&fit=default&crop=default&q=65&vib=3&con=3&usm=15&bg=F4F4F3&ixlib=js-2.2.1&s=154b81b7f4331203d5766362d7af507b",
                fit: BoxFit.cover,
              )),
          Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Colors.black.withOpacity(0.9),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.5),
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.05),
                  Colors.black.withOpacity(0.025),
                  Colors.black.withOpacity(0.01),
                  Colors.black.withOpacity(0.005),
                  Colors.black.withOpacity(0.001),
                ])),
          )
        ],
      ),
    );
  }

  Widget _getBody(BuildContext context, Map<String, dynamic> congregation) {
    final size = MediaQuery.of(context).size;

    return SliverToBoxAdapter(
        child: Column(children: [
      Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 10.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SizedBox(
              width: size.width * 0.8,
              child: Text(
                congregation['nombre_iglesia'],
                maxLines: 3,
                style: const TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Expanded(
              child: CircleAvatar(radius: 50.0, child: Icon(Icons.church)),
            )
          ])),
      _getMapinfo(congregation),
      SpecialTextCard(
        title: "Fundación",
        description: congregation['fcha_fundacion'],
      ),
      SpecialTextCard(
        title: "Observaciones",
        description: congregation['observaciones']?.isEmpty
            ? "No hay observaciones"
            : congregation['observaciones'],
      ),
    ]));
  }

  Widget _getMapinfo(Map<String, dynamic> congregation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SpecialTextCard(
          title: "Dirección",
          description: congregation['direccion'],
        ),
        GestureDetector(
			onTap: ()async{
				final availableMaps = await MapLauncher.installedMaps;

				if(availableMaps.isNotEmpty) {
					await availableMaps.first.showDirections(
						destination: Coords(
							double.parse(congregation['latitud'] ?? "0.0"),
							double.parse(congregation['longitud'] ?? "0.0"),
						),
					);
				}
			},
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 5.0,
                  offset: const Offset(0.0, 5.0),
                )
              ],
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  "Abrir en el mapa",
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8.0),
                Icon(Icons.map, color: Colors.white),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Returns a card with the information of the congregation
  /// @param icon The icon of the card
  /// @param title The title of the card
  /// @param value The value of the card
  /// @param color The color of the card
  Widget _getInfoCard(IconData icon, String title, String value, Color color) {
    return Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                  color: Colors.black12, blurRadius: 10, offset: Offset(0, 10))
            ]),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(icon, size: 14, color: Colors.white),
                ),
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ));
  }
}
