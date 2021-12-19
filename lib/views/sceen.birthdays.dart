import 'package:flutter/material.dart';
import 'package:tigua_birthday/router/router.routes.dart';

class BirthdayScreen extends StatelessWidget {
  const BirthdayScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cumpleañeros",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black,),
            onPressed: ()=>Navigator.of(context).pushNamed(RouteNames.settings.toString())
          )
        ],
      ),
      body: ListView(
        children: [
          const ListTile(
            title: Text("Cumpleaños de hoy"),
            leading: Icon(Icons.cake),
          ),
          SizedBox(
            height: size.height * 0.25,
            child: PageView(
              scrollDirection: Axis.horizontal,
              controller: PageController(
                initialPage: 0,
                keepPage: true,
                viewportFraction: 0.4
              ),
              children: [
                _getBirthdayCard(size, context),
                _getBirthdayCard(size, context),
                _getBirthdayCard(size, context),
              ],
            ),
          ),
          const ListTile(
            title: Text("Cumpleaños siguientes"),
            leading: Icon(Icons.cake),
          ),
          SizedBox(
            height: size.height * 0.25,
            child: PageView(
              scrollDirection: Axis.horizontal,
              controller: PageController(
                initialPage: 0,
                keepPage: true,
                viewportFraction: 0.4
              ),
              children: [
                _getBirthdayCard(size, context),
                _getBirthdayCard(size, context),
                _getBirthdayCard(size, context),
              ],
            ),
          )
        ],
      ),
    );
  }

  Container _getBirthdayCard(Size size, BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border.all(color: Colors.grey[400]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[300]!,
            offset: const Offset(3, 3),
            blurRadius: 2.0,
            spreadRadius: 3.0
          )
        ]
      ),
      child: Column(
        children: [
          const Text("Joel García"),
          const Icon(Icons.cake_rounded, size: 100,),
          const Text("22 años")
        ],
      ),
    );
  }
}