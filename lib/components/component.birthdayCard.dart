import 'package:flutter/material.dart';
import 'package:tigua_birthday/components/doubleFotoComponent.dart';
import 'package:tigua_birthday/helpers/helper.birthdayCard.dart';
import 'package:tigua_birthday/router/router.routes.dart';

/// A card widget to show birthdays in a custom format
class BirthdayCardWidget extends StatelessWidget {
  final Size size;
  final Map<String, dynamic> user;
  final bool isPastor;

  /// @param {Size} size - The size of the screen
  /// @param {Map<String, dynamic>} user - The user data
  /// @param {bool} isPastor - Whether the user is a pastor or not. If true then the JSON
  /// coming from the backend will be treated as a pastor.
  const BirthdayCardWidget(
      {Key? key, required this.size, required this.user, this.isPastor = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // using enums instead of plain text
    final userType = BirthdayHelper.parseUserStringToEnum(user['tipo'] ?? "P");

    // user birthday
    DateTime birthday = DateTime.parse(user["fnacimiento"] ??
        user["fingminis"] ??
        user["fmatrimonio"] ??
        "0000-00-00");

    String relationship = userType.name;
    Color background = BirthdayHelper.getCardBackgroundColor(userType);
    Color foreground = BirthdayHelper.getCardForegroundColor(userType);
    String dateOfBirthday = BirthdayHelper.parseBirthdayToString(birthday);
    int age = BirthdayHelper.getAge(birthday);

    String? photoUrl;
    String? secondaryPhotoUrl; // the smaller one

    if (!user.containsKey("foto")) {
      photoUrl = BirthdayHelper.extractMainPhotoUrlForUser(
          userType, user); // the bigger photo
      secondaryPhotoUrl = BirthdayHelper.extractSecondaryPhotoUrlForUser(
          userType, user); // the smaller photo
    } else {
      String photoID = (user['foto'] ?? "sin_foto.jpg").split('/').last;
      photoUrl =
          "https://oficial.cedeieanjesus.org/uploads/foto_pastor/$photoID";
    }

    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(RouteNames.user.toString(),
          arguments: {"user": user, "is_birthday": true, "is_pastor": isPastor}),
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
                  spreadRadius: 3.0)
            ]),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
                user['apellido_pastor'] != null
                    ? (user['apellido_pastor'] + " " + user['nombre_pastor'])
                    : user["apellidos"] ?? "No name",
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: foreground),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
            SizedBox(
                width: size.width * 0.3,
                height: size.width * 0.3,
                child: DoublePhotoComponent(
                    photoUrl: photoUrl, secondaryPhotoUrl: secondaryPhotoUrl)),
            Text("$relationship cumple $age años el $dateOfBirthday",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground,
                )),
          ],
        ),
      ),
    );
  }
}
