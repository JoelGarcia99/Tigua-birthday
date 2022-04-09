import 'package:flutter/material.dart';
import 'package:tigua_birthday/router/router.routes.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _usernameCtrl = TextEditingController();
    final _passwordCtrl = TextEditingController();

    final size = MediaQuery.of(context).size;
    final formKey = GlobalKey<FormState>();


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
		  onPressed: (){
		    if(formKey.currentState?.validate() ?? false) {
		      //TODO: save here
		    }
		    //TODO: Remove it later
		    Navigator.pushReplacementNamed(context, RouteNames.home.toString());
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
