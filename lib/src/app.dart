import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth/auth_service.dart';
import 'auth/oauth_callback.dart';
import 'auth/pkce.dart';
import 'edenred/edenred_api.dart';
import 'state/app_controller.dart';
import 'storage/app_preferences.dart';
import 'ui/dashboard_screen.dart';
import 'ui/login_screen.dart';
import 'ui/login_webview_screen.dart';
import 'ui/product_picker_screen.dart';
import 'ui/theme.dart';

class Edenred55App extends StatefulWidget {
  const Edenred55App({
    required this.authService,
    required this.edenredApi,
    required this.preferences,
    super.key,
  });

  final EdenredAuthService authService;
  final EdenredApi edenredApi;
  final AppPreferences preferences;

  @override
  State<Edenred55App> createState() => _Edenred55AppState();
}

class _Edenred55AppState extends State<Edenred55App> {
  late final AppController _controller;
  PkcePair? _activePkce;
  String? _activeState;

  @override
  void initState() {
    super.initState();
    _controller = AppController(
      auth: widget.authService,
      api: widget.edenredApi,
      preferences: widget.preferences,
    )..bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppController>.value(
      value: _controller,
      child: MaterialApp(
        title: 'Edenred 55',
        theme: EdenredTheme.light(),
        home: Consumer<AppController>(
          builder: (context, controller, _) {
            return switch (controller.status) {
              AppStatus.loading => const Scaffold(body: Center(child: CircularProgressIndicator())),
              AppStatus.unauthenticated => LoginScreen(onLogin: () => _startLogin(context)),
              AppStatus.needsProductSelection => ProductPickerScreen(controller: controller),
              AppStatus.ready => DashboardScreen(controller: controller),
              AppStatus.error => Scaffold(
                  appBar: AppBar(title: const Text('Edenred 55')),
                  body: Center(child: Text(controller.errorMessage ?? 'Unexpected error')),
                ),
            };
          },
        ),
      ),
    );
  }

  Future<void> _startLogin(BuildContext context) async {
    final pkce = PkcePair.generate();
    final state = PkcePair.createState();
    _activePkce = pkce;
    _activeState = state;
    final authorizeUrl = PkcePair.buildAuthorizeUrl(state, pkce.challenge);

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LoginWebViewScreen(
          authorizeUrl: authorizeUrl,
          onCallback: (callbackUrl) => _completeLogin(context, callbackUrl),
        ),
      ),
    );
  }

  Future<void> _completeLogin(BuildContext context, String callbackUrl) async {
    final pkce = _activePkce;
    final state = _activeState;
    if (pkce == null || state == null) {
      return;
    }

    final callback = OAuthCallback.parse(callbackUrl, state);
    await widget.authService.exchangeCode(code: callback.code, verifier: pkce.verifier);
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    await _controller.onLoginCompleted();
  }
}
