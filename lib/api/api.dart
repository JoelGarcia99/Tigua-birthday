import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:http/http.dart' as http;

class API {

  static const String host = "http://ieanjesus.portomamey.com/public/Home";

  Future<List<Map<String, dynamic>>> queryUsersByFilter(String filter) async {

    late String target;

    switch(filter) {
      case "esposa": target = "retornaresposa"; break;
      case "hijos": target = "retornahijopastor_byid"; break;
      case "pastor": target = "datatable_pastor"; break;
      default: target = "retornapastor"; break;
    }

    final uri = Uri.parse("$host/$target");

    final response = await http.post(uri);

    if(response.statusCode != 200) {
      SmartDialog.showToast(
        "Error de comunicación. Intente más tarde", 
        time: const Duration(seconds: 2)
      );
      return [];
    }

    final decodedJson = json.decode(response.body);

    return List<Map<String, dynamic>>.from(target == "datatable_pastor"? decodedJson["data"]:decodedJson);
  }

}