import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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
  int searchedPage = 0;
  String lastFilter = "";
  String lastQuery = "";
  bool isLoading = false;

  List<Map<String, dynamic>> elements = [];
  List<Map<String, dynamic>> elementsSearched = [];

  final dataStream = StreamController<List<Map<String, dynamic>>>.broadcast();
  final dataSearchedStream = StreamController<List<Map<String, dynamic>>>.broadcast();

  /// Fetchs a list of users that have birthday this week. If [useCache] is enable
  /// then this method will try to use the data stored in external storage, it's 
  /// useful when you're offline.
  Future<List<Map<String, dynamic>>> queryCumpleaneros([bool useCache = true]) async {

    if(useCache) {
      // Validating the directory exists
      final directory = await getApplicationDocumentsDirectory();
      final targetDir = Directory("${directory.path}/temp/birthday_data.json");

      // trying to read the stored file
      if(await targetDir.exists()) {
        final file = File(targetDir.path);

        final jsonReaded = List<Map<String, dynamic>>.from(json.decode(await file.readAsString()));

        if(jsonReaded.isEmpty) return jsonReaded;
      }
    }

    // If there is no file or if it's empty then fetch data from API
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

  Future<List<Map<String, dynamic>>> searchUser(String query, [bool newQuery = true]) async {

    // If there is no file or if it's empty then fetch data from API
    final url = Uri.parse("http://ieanjesus.portomamey.com/public/Home/datatable_cumple");

    final response = await http.post(url, body: {
      "search": query,
      // "start": 20 * searchedPage,
      // "length": 20
    });

    if(response.statusCode != 200) {
      return [];
    }

    final decodedJson = Map<String, dynamic>.from(json.decode(response.body));
    dataSearchedStream.sink.add(List<Map<String, dynamic>>.from(decodedJson["data"]));
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

  Future<List<Map<String, dynamic>>> queryUsersByFilter(String filter, [String? query]) async {
    print(query);
    // If it's loading do not fetch new data
    if(isLoading) return elements;

    if(!isLoading) isLoading = true;
    
    // If the filter changes then I should fetch new data of a new
    // group, so the data in [elements] should be removed.
    if(lastFilter != filter || lastQuery != query) {
      lastFilter = filter;
      lastQuery = query ?? "";
      elements.clear();
      page = -1;
    }

    ++page;

    final uri = Uri.parse("$host/datatable_pastor");

    final body = {
      "length": "20",
      "start": "${20 * page}",
      "draw": "1",
      "search": lastQuery
    };

    if(filter != "CUALQUIERA") {
      body.addAll({"licencia": filter});
    }
    
    final response = await http.post(uri, body: body);
    
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