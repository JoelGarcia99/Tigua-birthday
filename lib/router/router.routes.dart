import 'package:flutter/material.dart';
import 'package:tigua_birthday/views/screen.home.dart';
import 'package:tigua_birthday/views/screen.settings.dart';
import 'package:tigua_birthday/views/screen.user.dart';

enum RouteNames{
  home, user, settings
}

Map<String, Widget Function(BuildContext)> buildRoutes() => {
  RouteNames.home.toString(): (_)=> const HomeScreen(),
  RouteNames.user.toString(): (_)=> const UserScreen(),
  RouteNames.settings.toString(): (_)=> const SettingsPage()
};