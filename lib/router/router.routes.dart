import 'package:flutter/material.dart';
import 'package:tigua_birthday/views/auth/screen.login.dart';
import 'package:tigua_birthday/views/common/screen.user.dart';
import 'package:tigua_birthday/views/congregation/screen.congregation.dart';
import 'package:tigua_birthday/views/home/screen.home.dart';
import 'package:tigua_birthday/views/search/screen.cargosFiltering.dart';
import 'package:tigua_birthday/views/settings/screen.settings.dart';

enum RouteNames { home, user, settings, login, filterCargo, congregation }

Map<String, Widget Function(BuildContext)> buildRoutes() => {
      RouteNames.home.toString(): (_) => const HomeScreen(),
      RouteNames.user.toString(): (_) => const UserScreen(),
      RouteNames.settings.toString(): (_) => const SettingsPage(),
      RouteNames.login.toString(): (_) => LoginScreen(),
      RouteNames.filterCargo.toString(): (_) => const CargosFiltering(),
      RouteNames.congregation.toString(): (_) => const CongregationScreen()
    };
