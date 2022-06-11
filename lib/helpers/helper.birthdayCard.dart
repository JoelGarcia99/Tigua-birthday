import 'package:flutter/material.dart';
import 'package:tigua_birthday/ui/constants.dart';

/// Basic user type
enum UserType { wife, pastor, son }

extension UserTypeName on UserType {
  String get name {
    switch (this) {
      case UserType.wife:
        return 'Esposa';
      case UserType.pastor:
        return 'Pastor';
      case UserType.son:
        return 'Hijo/a';
    }
  }
}

/// A helper for birthday operations such as birthday format or
/// age extraction
class BirthdayHelper {
  static const monthNames = [
    "enero",
    "febrero",
    "marzo",
    "abril",
    "mayo",
    "junio",
    "julio",
    "agosto",
    "septiembre",
    "octubre",
    "noviembre",
    "diciembre"
  ];

  /// Returns the month name for the given month number.
  /// @param {String} month The month number.
  /// @return {String} The month name.
  static String getMonth(String monthNumber) {
    int month = int.parse(monthNumber);

    return monthNames[month - 1];
  }

  /// Returns how many years old the user is
  /// @param {DateTime} birthday - The user's birthday
  /// @return {int} - The user's age
  static int getAge(DateTime birthday) {
    DateTime now = DateTime.now();
    int age = now.year - birthday.year;
    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }
    return age;
  }

  /// Returns the card color for the user given a type
  static Color getCardBackgroundColor(UserType type) {
    switch (type) {
      case UserType.wife:
        return UIConstatnts.wifeColor;
      case UserType.pastor:
        return UIConstatnts.pastorColor;
      case UserType.son:
      default:
        return UIConstatnts.sonColor;
    }
  }

  /// Returns the card foreground for the given user type
  static Color getCardForegroundColor(UserType type) {
    //TODO: create constants
    switch (type) {
      case UserType.wife:
        return Colors.white;
      case UserType.pastor:
        return Colors.white;
      case UserType.son:
      default:
        return Colors.black;
    }
  }

  /// Parse a string type to a UserType. The [userType] can
  /// only be 'E', 'P' or 'H'. Default value is 'H'.
  static UserType parseUserStringToEnum(String userType) {
    switch (userType.toUpperCase()) {
      case 'E':
        return UserType.wife;
      case 'P':
        return UserType.pastor;
      case 'H':
		return UserType.son;
      default:
        return UserType.pastor;
    }
  }

  /// Gets the main Url for a given user
  static String extractMainPhotoUrlForUser(
      UserType type, Map<String, dynamic> user) {
    // The id of the user photo
    String? photoId;

    switch (type) {
      case UserType.wife:
        photoId = (user['fotosolopastor'] ?? "sin_foto.jpg").split('/').last;
        break;
      case UserType.pastor:
        photoId = (user['foto'] ?? user['foto_pastor']  ?? "sin_foto.jpg").split('/').last;
        break;
      case UserType.son:
      default:
        photoId = ("sin_foto.jpg").split('/').last;
        break;
    }

    return "https://oficial.cedeieanjesus.org/uploads/foto_pastor/$photoId";
  }

  // Gets the secondary Url for a given user
  static String? extractSecondaryPhotoUrlForUser( UserType type, Map<String, dynamic> user) {
    switch (type) {
      case UserType.wife:
        String secondaryPhotoID =
            (user['foto'] ?? "sin_foto.jpg").split('/').last;
        return "https://oficial.cedeieanjesus.org/uploads/"
            "foto_esposa_pastor/$secondaryPhotoID";
      case UserType.pastor:
        return null;
      case UserType.son:
      default:
        String secondaryPhotoID = ("sin_foto.jpg").split('/').last;
        return "https://oficial.cedeieanjesus.org/uploads/foto_pastor/$secondaryPhotoID";
    }
  }

  static String parseBirthdayToString(DateTime birthday) {
    return '${birthday.day} de ${getMonth(birthday.month.toString())}';
  }
}
