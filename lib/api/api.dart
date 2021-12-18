import 'dart:async';
import 'dart:convert';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:http/http.dart' as http;

/// Singleton backend connection API
class API {

  static API? _instance;

  factory API() {
    _instance ??= API._();

    return _instance!;
  }

  API._();

  static const String host = "http://ieanjesus.portomamey.com/public/Home";

  int page = 0;
  String lastFilter = "";
  bool isLoading = false;
  List<Map<String, dynamic>> elements = [];

  final dataStream = StreamController<List<Map<String, dynamic>>>.broadcast();

  Future<List<Map<String, dynamic>>> queryUsersByFilter(String filter) async {

    // If it's loading do not fetch new data
    if(isLoading) return elements;

    if(!isLoading) isLoading = true;

    late String target;
    
    // If the filter changes then I should fetch new data of a new
    // group, so the data in [elements] should be removed.
    if(lastFilter != filter) {
      lastFilter = filter;
      elements.clear();
      page = -1;
    }

    ++page;

    switch(filter) {
      case "esposa": target = "retornaresposa"; break;
      case "hijos": target = "retornahijopastor_byid"; break;
      case "pastor": target = "datatable_pastor"; break;
      default: target = "retornapastor"; break;
    }

    final uri = Uri.parse("$host/$target");

    final response = await http.post(uri, body: {
      "length": "20",
      "start": "${20 * page}",
      "draw": "1"
    });

    if(response.statusCode != 200) {
      SmartDialog.showToast(
        "No hay más datos para cargar", 
        time: const Duration(seconds: 2)
      );

      isLoading = false;
      return [];
    }

    final decodedJson = json.decode(response.body);

    elements.addAll(List<Map<String, dynamic>>.from(target == "datatable_pastor"? decodedJson["data"]:decodedJson));

    dataStream.sink.add(elements);

    isLoading = false;
    return elements;
  }

}