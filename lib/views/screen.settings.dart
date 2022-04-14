import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tigua_birthday/router/router.routes.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Opciones",
          style: TextStyle(color: Colors.black),
        ),
        foregroundColor: Colors.black,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        children: [
          FutureBuilder(
            future: PackageInfo.fromPlatform(),
            builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
              if(!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator(),);
              }

              return Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text("Versión de la aplicación"),
                    subtitle: Text(snapshot.data!.version),
                  ),
                  ListTile(
                    leading: const Icon(Icons.compass_calibration),
                    title: const Text("Número de compilación"),
                    subtitle: Text(snapshot.data!.buildNumber),
                  ),
		  const Divider(),
		  ListTile(
		      leading: const Icon(Icons.exit_to_app),
		      title: const Text("Salir de la app"),
		      onTap: () async {
			SmartDialog.showLoading();
			final cache = await SharedPreferences.getInstance();

			cache.remove('login.token');
			cache.remove('login.user');

			Navigator.of(context).pushReplacementNamed(RouteNames.login.toString());
			SmartDialog.dismiss();
		      }
		  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
