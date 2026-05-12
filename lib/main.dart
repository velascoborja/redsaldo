import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import 'src/app.dart';
import 'src/data/repositories/edenred_repository.dart';
import 'src/data/repositories/preferences_repository.dart';
import 'src/data/services/app_preferences_service.dart';
import 'src/data/services/auth_service.dart';
import 'src/data/services/edenred_api_service.dart';
import 'src/data/services/token_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tzdata.initializeTimeZones();

  final httpClient = http.Client();
  final preferences = await SharedPreferences.getInstance();
  final tokenStore = TokenStore(FlutterSecureTokenBackend());
  final authService = EdenredAuthService(httpClient, tokenStore);
  final edenredApi = EdenredApi(httpClient);
  final appPreferences = AppPreferences(preferences);

  runApp(
    Edenred55App(
      authService: authService,
      edenredRepository: EdenredRepositoryImpl(service: edenredApi),
      preferences: PreferencesRepositoryImpl(preferences: appPreferences),
    ),
  );
}
