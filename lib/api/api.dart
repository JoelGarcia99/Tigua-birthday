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
  int searchedPage = 0;
  String lastFilter = "";
  String lastQuery = "";
  bool isLoading = false;

  List<Map<String, dynamic>> elements = [];
  List<Map<String, dynamic>> elementsSearched = [];

  final dataStream = StreamController<List<Map<String, dynamic>>>.broadcast();
  final dataSearchedStream =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  /// Fetchs a list of users that have birthday this week. If [useCache] is enable
  /// then this method will try to use the data stored in external storage, it's
  /// useful when you're offline.
  Future<List<Map<String, dynamic>>> queryCumpleaneros(String filter) async {
    isLoading = true;
    // If there is no file or if it's empty then fetch data from API
    final url = Uri.parse("$host/datatable_cumple");

    // birthdays within the next 7 days
    final currentWeek = DateTime.now();
    var endWeek = currentWeek.add(const Duration(days: 7));

    if (endWeek.year > currentWeek.year) {
      endWeek = DateTime(currentWeek.year, 12, 31);
    }

    final body = {
      "mesini": currentWeek.month.toString(),
      "mesfin": endWeek.month.toString(),
      "diaini": currentWeek.day.toString(),
      "diafin": endWeek.day.toString(),
    };

    body.addAll(filter.isEmpty ? {} : {"tipo": filter});

    final response = await http.post(url, body: body);

    if (response.statusCode != 200) {
      isLoading = false;
      return [];
    }

    elementsSearched.clear();
    final decodedJson = Map<String, dynamic>.from(json.decode(response.body));
    elementsSearched
        .addAll(List<Map<String, dynamic>>.from(decodedJson["data"]));

    isLoading = false;
    return elementsSearched;
  }

  Future<List<Map<String, dynamic>>> searchUser(String query,
      [bool newQuery = true]) async {
    // If there is no file or if it's empty then fetch data from API
    final url = Uri.parse("$host/datatable_cumple");

    final response = await http.post(url, body: {
      "search": query,
      // "start": 20 * searchedPage,
      // "length": 20
    });

    if (response.statusCode != 200) {
      return [];
    }

    final decodedJson = Map<String, dynamic>.from(json.decode(response.body));
    dataSearchedStream.sink
        .add(List<Map<String, dynamic>>.from(decodedJson["data"]));
    return List<Map<String, dynamic>>.from(decodedJson["data"]);
  }

  Future<List<Map<String, dynamic>>> queryUserByID(List ids, String type) async {
    late String filter;

    switch (type) {
      case "P":
        filter = "retornapastor";
        break;
      case "E":
        filter = "retornaresposa";
        break;
      case "H":
        filter = "retornahijopastor_byid";
        break;
      default:
        filter = "retornapastor";
        break;
    }

    final uri = Uri.parse("$host/$filter");

    final bodyIDs = <String, dynamic>{};

    if(filter == "retornapastor") {
      for (int i=0; i<ids.length; ++i) {
	bodyIDs.addAll(<String, dynamic>{"id[$i]": ids[i].toString()});
      }
    }
    else {
      bodyIDs.addAll({"id": ids.first});
    }

    final response = await http.post(
      uri,
      headers: {
	'content-Type':'application/x-www-form-urlencoded'
      },
      body: bodyIDs
    );

    if (response.statusCode != 200) {
      SmartDialog.showToast("No hay más datos para cargar",
          time: const Duration(seconds: 2));

      isLoading = false;
      return [];
    }

    final decodedJson =
        List<Map<String, dynamic>>.from(json.decode(response.body));

    return decodedJson.isNotEmpty ? decodedJson : [];
  }

  Future<List<Map<String, dynamic>>> queryUsersByFilter(String filter,
      [String? query, bool shouldPurgue = false]) async {
    // If it's loading do not fetch new data
    if (isLoading) return elements;

    if (!isLoading) isLoading = true;

    // If the filter changes then I should fetch new data of a new
    // group, so the data in [elements] should be removed.
    if (shouldPurgue || lastFilter != filter || lastQuery != query) {
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

    if (filter != "CUALQUIERA") {
      body.addAll({"licencia": filter});
    }

    final response = await http.post(uri, body: body);

    if (response.statusCode != 200) {
      SmartDialog.showToast("No hay más datos para cargar",
          time: const Duration(seconds: 2));

      isLoading = false;
      return [];
    }

    final decodedJson = json.decode(response.body);

    elements.addAll(List<Map<String, dynamic>>.from(decodedJson["data"]));

    dataStream.sink.add(elements);

    isLoading = false;

    return elements;
  }

  // This will fetch a JSON to query users according to some charge... and yes, I'm using an
  // Spanglish notation
  Future<Map<String, dynamic>> fetchCargos() async {
    // If there is no file or if it's empty then fetch data from API
    final url = Uri.parse("$host/cargos");

    final response = await http.post(url);

    if (response.statusCode != 200) {
      return {};
    }

    final decodedJson = Map<String, dynamic>.from(json.decode(response.body));
    final pastoresIDs = await extractPastoresIDs(decodedJson);

    // extracting IDs of 'pastores'
    final pastores = await queryUserByID(pastoresIDs.toList(), 'P');

    // Yep, Tigua did it again, my bro is a crack!
    decodedJson.addAll({'pastores_names': pastores});

    return decodedJson;
  }

  Future<Set> extractPastoresIDs(Map<String, dynamic> pastores) async {

    final ids = <dynamic>{};

    for(var pastor in pastores.keys) {
      // Looking for ids in leaf nodes
      switch(pastores[pastor].runtimeType) {
	case List<Map<String, dynamic>>:
	  ids.addAll(pastores[pastor]);
	  break;
	case List:
	  ids.addAll(pastores[pastor]);
	  break;
	default:
	  ids.addAll(await extractPastoresIDs(pastores[pastor]));
	  break;
      }
    }
    return ids;
  }
}
