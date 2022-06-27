import 'package:flutter/material.dart';
import 'package:tigua_birthday/api/api.dart';
import 'package:tigua_birthday/components/component.birthdayCard.dart';
import 'package:tigua_birthday/components/component.carrousel.dart';
import 'package:tigua_birthday/router/router.routes.dart';
import 'package:tigua_birthday/ui/constants.dart';

class BirthdayScreen extends StatefulWidget {
  const BirthdayScreen({Key? key}) : super(key: key);

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
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
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
                  _getFilterTag("Pastor", UIConstatnts.pastorColor),
                  const SizedBox(
                    width: 10.0,
                  ),
                  _getFilterTag("Esposa", UIConstatnts.wifeColor),
                  const SizedBox(
                    width: 10.0,
                  ),
                  _getFilterTag("Hijo", UIConstatnts.sonColor)
                ],
              ),
              _getBirthdayCarrousels(size),
              _getMinisteryCarrousel(size),
              _getPastorAniversaryCarrousel(size),
            ],
          ),
        ),
      ),
    );
  }

  /// Returns a component with a normal list of birthdays
  FutureBuilder<List<Map<String, dynamic>>> _getBirthdayCarrousels(Size size) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: API().queryCumpleaneros(selectedFilters),
        builder: (context, snapshot) {
          if (!snapshot.hasData || API().isLoading) {
            return const Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // this is a list of pepople that have bithday today
          final data = snapshot.data!;
          data.sort((a, b) {
            final ca = DateTime.parse(a['fnacimiento']);
            final cb = DateTime.parse(b['fnacimiento']);

            // I compare months and add a year if it's higher than current month just
            // to sort dates easier.
            final ya = ca.month > DateTime.now().year
                ? DateTime.now().year + 1
                : ca.month;
            final yb = cb.month > DateTime.now().year
                ? DateTime.now().year + 1
                : cb.month;

            return DateTime(ya, ca.month, ca.day)
                .compareTo(DateTime(yb, cb.month, cb.day));
          });

          // Users that have birthday today
          final todayUsers = List<Map<String, dynamic>>.from(data.where((user) {
            return DateTime.parse(user["fnacimiento"]).day ==
                DateTime.now().day;
          }));

          // removing today birthday users from the next week ones
          final nextBirthdays = List<Map<String, dynamic>>.from(data);
          nextBirthdays.removeWhere((user) =>
              DateTime.parse(user["fnacimiento"]).day == DateTime.now().day);

          // how many is the height of the card in percent (%)
          late double cardSizeProp;

          // Avoiding overflow on small devices
          if (size.height < 700) {
            cardSizeProp = 0.4;
          } else {
            cardSizeProp = 0.3;
          }

          return Column(
            children: [
              CarrouselComponent(
                  title: "Cumpleaños de hoy (${todayUsers.length})",
                  emptyTag: "Nadie cumple años hoy",
                  prefixIcon: Icons.cake,
                  size: Size(size.width, size.height * cardSizeProp),
                  data: _buildBirthdayCards(todayUsers, size, context)),
			  // TODO: Yeah, I know Tigua could change his decision so just uncomment this partion of code
			  // if you wanna get back the "next birthdays" carrousel
              // CarrouselComponent(
              //     title: "Cumpleaños siguientes",
              //     emptyTag: "Nadie cumple años en la próxima semana",
              //     prefixIcon: Icons.cake,
              //     size: Size(size.width, size.height * cardSizeProp),
              //     data: _buildBirthdayCards(nextBirthdays, size, context)),
            ],
          );
        });
  }

  /// Returns a list of cards with the birthday data of the user
  /// @param {List<Map<String, dynamic>>} birthdayData - The data of the birthday
  /// @param {Size} size - The size of the card
  /// @param {BuildContext} context - The context of the widget
  List<Widget> _buildBirthdayCards(List<Map<String, dynamic>> birthdayData,
      Size size, BuildContext context) {
    return List<Widget>.from(birthdayData.map((user) {
      return BirthdayCardWidget(size: size, user: user);
    }));
  }

  /// Returns a set of filters to query birthdays (pastor, esposa, hijo/a)
  /// @param {String} title - The title of the filter
  /// @param {Color} color - The color of the filter
  Widget _getFilterTag(String title, Color color) {
    return GestureDetector(
      onTap: () {
        selectedFilters = title[0] == selectedFilters ? '' : title[0];
        setState(() {});
      },
      child: Container(
        padding: const EdgeInsets.only(right: 8.0),
        decoration: !(selectedFilters == title[0])
            ? null
            : BoxDecoration(
                border: Border.all(color: color, width: 2.0),
                borderRadius: BorderRadius.circular(15.0)),
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

  FutureBuilder _getMinisteryCarrousel(Size size) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: API().fetchMinisterialBirthdays(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final data = snapshot.data!;
          final heightProp = size.height < 700 ? 0.4 : 0.3;

          return Column(
            children: [
              CarrouselComponent(
                  title: "Cumpleaños Ministeriales (${data.length})",
                  emptyTag: "No hay cumpleaños ministeriales en estos días",
                  prefixIcon: Icons.celebration,
                  size: Size(size.width, size.height * heightProp),
                  data: _buildMinisterialCards(data, size, context)),
            ],
          );
        });
  }

  _buildMinisterialCards(data, Size size, BuildContext context) {
    return List<Widget>.from(data.map((user) {
      return BirthdayCardWidget(size: size, user: user, isPastor: true);
    }));
  }

  _getPastorAniversaryCarrousel(Size size) {
    return FutureBuilder<List<Map<String, dynamic>>>(
        future: API().fetchPastorAniversary(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (!snapshot.hasData) {
            return const Padding(
              padding: EdgeInsets.all(10.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final data = snapshot.data!;
          final heightProp = size.height < 700 ? 0.4 : 0.3;

          return Column(children: [
            CarrouselComponent(
                title: "Aniversarios Pastorales (${data.length})",
                emptyTag: "No hay aniversarios de pastores en estos días",
                prefixIcon: Icons.celebration,
                size: Size(size.width, size.height * heightProp),
                data: _buildPastorAniversaryCards(data, size, context)),
          ]);
        });
  }

  _buildPastorAniversaryCards(
      List<Map<String, dynamic>> data, Size size, BuildContext context) {
    return List<Widget>.from(data.map((user) {
      return BirthdayCardWidget(size: size, user: user, isPastor: true);
    }));
  }
}
