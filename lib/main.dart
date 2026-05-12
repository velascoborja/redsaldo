import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'src/app.dart';
import 'src/auth/auth_service.dart';
import 'src/auth/token_store.dart';
import 'src/edenred/edenred_api.dart';
import 'src/storage/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();

  final httpClient = http.Client();
  final preferences = await SharedPreferences.getInstance();
  final tokenStore = TokenStore(FlutterSecureTokenBackend());

  runApp(
    Edenred55App(
      authService: EdenredAuthService(httpClient, tokenStore),
      edenredApi: EdenredApi(httpClient),
      preferences: AppPreferences(preferences),
    ),
  );
}
