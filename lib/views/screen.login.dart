import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:tigua_birthday/api/auth.dart';
import 'package:tigua_birthday/router/router.routes.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();


  LoginScreen({Key? key}) : super(key: key);



  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;


    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SizedBox(
	    height: size.height,
          child: SingleChildScrollView(
	    physics: const BouncingScrollPhysics(),
            child: Column(
	      mainAxisSize: MainAxisSize.max,
	      crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Image.asset('assets/ieanjesus.png', width: size.width * 0.8),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 15.0),
                  child: Column(
                    children: const [
                      Text(
                        "¡BIENVENIDO!",
                        style:
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 40),
                      ),
                      Text("Inicie sesión",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Form(
		      key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _usernameCtrl,
                          autocorrect: false,
                          decoration: const InputDecoration(
                              hintText: "Ingrese su usuario",
                              icon: Icon(Icons.person)),
                          validator: (text) {
                            if ((text ?? "").trim().length < 2) {
                              return "Usuario no válido";
                            }

                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordCtrl,
                          autocorrect: false,
                          obscureText: true,
                          decoration: const InputDecoration(
                              hintText: "Su contraseña",
                              icon: Icon(Icons.security)),
                          validator: (text) {
                            if ((text ?? "").trim().length < 8) {
                              return "Contraseña no válida";
                            }

                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
	      const SizedBox(height: 20),
	      TextButton.icon(
		  onPressed: () async {
		    SmartDialog.showLoading();
		    if(formKey.currentState?.validate() ?? false) {
		      final response = await Auth().login(
			  _usernameCtrl.text,
			  _passwordCtrl.text
		      );

		      if(response.isEmpty) {
			SmartDialog.dismiss();
			SmartDialog.showToast('No se pudo iniciar sesión. Credenciales incorrectas');
			return;
		      }

		      // storing values
		      final cache = await SharedPreferences.getInstance();
		      cache.setString('login.token', response['contra']);
		      cache.setString('user.data', const JsonEncoder().convert(response));

		      Navigator.restorablePopAndPushNamed(context, RouteNames.home.toString());
		    }

		    SmartDialog.dismiss();
		  },
		  style: ButtonStyle(

			     backgroundColor: MaterialStateProperty.all(Colors.indigo),
			     foregroundColor: MaterialStateProperty.all(Colors.white)),
		  label: const Text("Ingresar"),
		  icon: const Icon(Icons.input_outlined)
	      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
