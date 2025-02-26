import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:rocket_chat_connector_flutter/exceptions/exception.dart';
import 'package:rocket_chat_connector_flutter/models/authentication.dart';
import 'package:rocket_chat_connector_flutter/models/user.dart';
import 'package:rocket_chat_connector_flutter/services/http_service.dart';
import 'package:uuid/uuid.dart';

class AuthenticationService {
  HttpService _httpService;

  AuthenticationService(this._httpService);

  Future<Authentication> login(String user, String password) async {
    int timezoneOffset = DateTime.now().timeZoneOffset.inHours;
    Map<String, dynamic> body = {
      "username": user,
      "password": password,
      "tz-offset": timezoneOffset,
      "app-id": Uuid().v4().toString()
      // "code":,
    };
    http.Response response = await _httpService.post(
      '/api/v1/login',
      jsonEncode(body),
      null,
    );

    if (response.statusCode == 200 && response.body.isNotEmpty == true) {
      return Authentication.fromMap(jsonDecode(response.body));
    }
    throw RocketChatException(response.body);
  }

  Future<User> me(Authentication authentication) async {
    http.Response response = await _httpService.get(
      '/api/v1/me',
      authentication,
    );

    if (response.statusCode == 200) {
      if (response.body.isNotEmpty == true) {
        return User.fromMap(jsonDecode(response.body));
      } else {
        return User();
      }
    }
    throw RocketChatException(response.body);
  }
}
