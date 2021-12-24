import 'package:flutter/material.dart';
import 'package:tigua_birthday/views/sceen.birthdays.dart';
import 'package:tigua_birthday/views/screen.users.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({ Key? key }) : super(key: key);
  final pages = const[
    BirthdayScreen(),
    UsersScreen(),
  ];

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late int pageIndex;

  @override
  void initState() {
    pageIndex = 0;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: widget.pages[pageIndex],
      bottomNavigationBar: _bottomMenu()
    );
    
  }

  BottomNavigationBar _bottomMenu() {
    return BottomNavigationBar(
      currentIndex: pageIndex,
      onTap: (index) {
        setState((){
          pageIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.celebration_outlined),
          activeIcon: Icon(Icons.celebration),
          label: "Cumpleaños",
          tooltip: "Lista de cumpleaños"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: "Pastores",
          tooltip: "Lista de pastores"
        ),
      ],
    );
  }
}