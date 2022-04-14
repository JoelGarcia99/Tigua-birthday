import 'dart:async';
import 'dart:convert';

import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:http/http.dart' as http;

/// Singleton backend connection Auth
class Auth {
  static Auth? _instance;

  factory Auth() {
    _instance ??= Auth._();

    return _instance!;
  }

  Auth._();

  static const String host = "http://ieanjesus.portomamey.com/public/Home";

  Future<Map<String, dynamic>> login(String user, String pass) async {
    const targetUrl = '/iniciosesion';

    final url = Uri.parse(host+targetUrl);

    final response = await http.post(url, body: {
      'username': user,
      'contra': pass
    });

    print("$user $pass");
    print(response.body);
    if(response.statusCode != 200) {
      return {};
    }

    return jsonDecode(response.body);
  }
}
