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

  Future<List<Map<String, dynamic>>> queryCumpleaneros() async {

    final url = Uri.parse("http://ieanjesus.portomamey.com/public/Home/datatable_cumple");

    // birthdays within the next 7 days
    final currentWeek = DateTime.now();
    final endWeek = currentWeek.add(const Duration(days: 7));

     final response = await http.post(url, body: {
      "mesini": currentWeek.month.toString(),
      "mesfin": endWeek.month.toString(),
      "diaini": currentWeek.day.toString(),
      "diafin": endWeek.day.toString()
    });

    if(response.statusCode != 200) {
      return [];
    }

    final decodedJson = Map<String, dynamic>.from(json.decode(response.body));
    return List<Map<String, dynamic>>.from(decodedJson["data"]);

  }

  Future<Map<String, dynamic>> queryUserByID(String id, String type) async {
    
    late String filter;

    switch(type) {
      case "P": filter = "retornapastor"; break;
      case "E": filter = "retornaresposa"; break;
      case "H": filter = "retornahijopastor_byid"; break;
      default: filter = "retornapastor"; break;
    }

    final uri = Uri.parse("$host/$filter");

    final response = await http.post(uri, body: {
      "id": id
    });

    if(response.statusCode != 200) {
      SmartDialog.showToast(
        "No hay más datos para cargar", 
        time: const Duration(seconds: 2)
      );

      isLoading = false;
      return {};
    }

    final decodedJson = List<Map<String, dynamic>>.from(json.decode(response.body));

    return decodedJson.isNotEmpty? decodedJson.last:{};
  }

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
      case "esposa": target = "E"; break;
      case "hijos": target = "H"; break;
      case "pastor": target = "P"; break;
      default: target = "P"; break;
    }

    final uri = Uri.parse("$host/datatable_cumple");

    final response = await http.post(uri, body: {
      "length": "20",
      "start": "${20 * page}",
      "draw": "1",
      "tipo": target
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

    elements.addAll(List<Map<String, dynamic>>.from(decodedJson["data"]));

    dataStream.sink.add(elements);

    isLoading = false;
    return elements;
  }

}