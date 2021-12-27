import 'package:flutter/material.dart';
import 'package:tigua_birthday/api/api.dart';
import 'package:tigua_birthday/router/router.routes.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({ Key? key }) : super(key: key);

  @override
  State<BirthdayScreen> createState() => _BirthdayScreenState();
}

class _BirthdayScreenState extends State<BirthdayScreen> {

  late String selectedFilters;

  @override
  void initState() {
    selectedFilters = '';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: API().queryCumpleaneros(selectedFilters),
        builder: (context, snapshot) {

          if(!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(),);
          }


          final data = snapshot.data!;
          data.sort((a, b){

            final ca = DateTime.parse(a['fnacimiento']);
            final cb = DateTime.parse(b['fnacimiento']);

            // I compare months and add a year if it's higher than current month just
            // to sort dates easier.
            final ya = ca.month > DateTime.now().year? DateTime.now().year + 1:ca.month;
            final yb = cb.month > DateTime.now().year? DateTime.now().year + 1:cb.month;

            return DateTime(ya, ca.month, ca.day).
              compareTo(DateTime(yb, cb.month, cb.day));
          });

          final todayUsers = List<Map<String, dynamic>>.from(data.where(
            (user) {
              return DateTime.parse(user["fnacimiento"]).day == DateTime.now().day;
            }
          ));

          // removing today birthday users from the next week ones
          final nextBirthdays = List<Map<String, dynamic>>.from(data);
          nextBirthdays.removeWhere((user) => DateTime.parse(user["fnacimiento"]).day == DateTime.now().day);
          
          // how many is the height of the card in percent (%)
          const double cardSizeProp = 0.3;


          return RefreshIndicator(
            onRefresh: ()async{
              setState(() {});
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const ListTile(
                  title: Text("Filtros"),
                  leading: Icon(Icons.legend_toggle),
                ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  direction: Axis.horizontal,
                  children: [
                    _getFilterTag("Pastor", const Color(0xff110066)),
                    const SizedBox(width: 10.0,),
                    _getFilterTag("Esposa", const Color(0xff8C0327)),
                    const SizedBox(width: 10.0,),
                    _getFilterTag("Hijo", const Color(0xffFFD432)),
                  ],
                ),
                ListTile(
                  title: Text("Cumpleaños de hoy (${todayUsers.length})"),
                  leading: const Icon(Icons.cake),
                ),
                SizedBox(
                  height: size.height * cardSizeProp,
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    controller: PageController(
                      initialPage: 0,
                      keepPage: true,
                      viewportFraction: 0.5
                    ),
                    children: todayUsers.isEmpty?
                      const [Center(child: Text("Nadie cumple años hoy."),)]:
                      List<Widget>.from(todayUsers.map((user){
                        return _getBirthdayCard(size, context, user, true);
                      }))
                  ),
                ),
                const ListTile(
                  title: Text("Cumpleaños siguientes"),
                  leading: Icon(Icons.cake),
                ),
                SizedBox(
                  height: size.height * cardSizeProp,
                  child: PageView(
                    scrollDirection: Axis.horizontal,
                    controller: PageController(
                      initialPage: 0,
                      keepPage: true,
                      viewportFraction: 0.5
                    ),
                    children: nextBirthdays.isEmpty?
                      const [Center(child: Text("No hay más cumpleaños en estos días"),)]:
                      List<Widget>.from(nextBirthdays.map((user){
                        return _getBirthdayCard(size, context, user);
                      }))
                  ),
                )
              ],
            ),
          );
        }
      ),
    );
  }

  Widget _getFilterTag(String title, Color color) {

    return GestureDetector(
      onTap: () {
        selectedFilters = title[0] == selectedFilters? '':title[0];
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.only(right: 8.0),
        decoration: !(selectedFilters == title[0])? null:BoxDecoration(
          border: Border.all(
            color: color,
            width: 2.0
          ),
          borderRadius: BorderRadius.circular(15.0)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              margin: const EdgeInsets.all(8.0),
              color: color,
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  Widget _getBirthdayCard(Size size, BuildContext context, Map<String, dynamic> user, [bool today = false]) {

    String? photoUrl;

    late Color background;
    late Color foreground;
    
    DateTime date = DateTime.parse(user["fnacimiento"] ?? "0000-00-00");
    DateTime currDate = DateTime(DateTime.now().year,DateTime.now().month,DateTime.now().day);
    
    int years = currDate.difference(today? date:date.add(const Duration(days: 365))).inDays ~/ 365;
          
    if(user.containsKey("id")) {
      switch((user['tipo'] as String).trim().toUpperCase()) {
        case "E":
          background = const Color(0xff8C0327);
          foreground = Colors.white;
          String photoID = (user['foto'] ?? "sin_foto.jpg").split('/').last;
          photoUrl = "https://oficial.cedeieanjesus.org/uploads/foto_esposa_pastor/$photoID";
          break;
        case "P":
          background = const Color(0xff110066);
          foreground = Colors.white;
          String photoID = (user['foto'] ?? "sin_foto.jpg").split('/').last;
          photoUrl = "https://oficial.cedeieanjesus.org/uploads/foto_pastor/$photoID";
          break;
        case "H":
        default:
          background = const Color(0xffFFD432);
          foreground = Colors.black;
          String photoID = ("sin_foto.jpg").split('/').last;
          photoUrl = "https://oficial.cedeieanjesus.org/uploads/foto_pastor/$photoID";
          break;
      }
    }else {
      String photoID = (user['foto'] ?? "sin_foto.jpg").split('/').last;
      photoUrl = "https://oficial.cedeieanjesus.org/uploads/foto_pastor/$photoID";
    }

    return GestureDetector(
      onTap: ()=>Navigator.of(context).pushNamed(RouteNames.user.toString(), arguments: user),
      child: Container(
        margin: const EdgeInsets.only(right: 10.0, bottom: 10.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: background,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              user["apellidos"] ?? "No name", 
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: foreground
              ),
            ),
            SizedBox(
              width: size.width * 0.3,
              height: size.width * 0.3,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: FadeInImage.assetNetwork(
                  image: photoUrl,
                  imageErrorBuilder: (_, __, ___) {
                    return const Icon(Icons.image_not_supported_rounded);
                  },
                  alignment: Alignment.center,
                  fit: BoxFit.cover,
                  placeholder: "assets/loader.gif",
                ),
              ),
            ),
            Text(
              "${(user['fnacimiento'] ?? "").split('-')[2]} de ${getMonth((user['fnacimiento'] ?? "").split('-')[1])}",
              style: TextStyle(
                color: foreground
              )
            ),
            Text(
              "Cumple $years años",
              style: TextStyle(
                color: foreground
              )
            )
          ],
        ),
      ),
    );
  }

  String getMonth(String monthNumber) {

    int month = int.parse(monthNumber);

    const months = [
      "enero", "febrero", "marzo", "abril", "mayo", 
      "junio", "julio", "agosto", "septiembre", 
      "octubre", "noviembre", "diciembre"];

    return months[month - 1];
  }
}