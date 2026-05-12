import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/edenred_repository.dart';
import 'data/repositories/preferences_repository.dart';
import 'data/services/oauth_callback.dart';
import 'data/services/pkce.dart';
import 'l10n/app_localizations.dart';
import 'ui/core/theme.dart';
import 'ui/features/app_shell/app_view_model.dart';
import 'ui/features/app_shell/views/syncing_account_screen.dart';
import 'ui/features/auth/views/login_screen.dart';
import 'ui/features/auth/views/login_webview_screen.dart';
import 'ui/features/dashboard/views/dashboard_screen.dart';
import 'ui/features/products/views/product_picker_screen.dart';

class Edenred55App extends StatefulWidget {
  const Edenred55App({
    required this.authService,
    required this.edenredRepository,
    required this.preferences,
    super.key,
  });

  final AuthRepository authService;
  final EdenredRepository edenredRepository;
  final PreferencesRepository preferences;

  @override
  State<Edenred55App> createState() => _Edenred55AppState();
}

class _Edenred55AppState extends State<Edenred55App> {
  late final AppViewModel _controller;
  PkcePair? _activePkce;
  String? _activeState;

  @override
  void initState() {
    super.initState();
    _controller = AppViewModel(
      auth: widget.authService,
      edenred: widget.edenredRepository,
      preferences: widget.preferences,
    )..bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppViewModel>.value(
      value: _controller,
      child: MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: EdenredTheme.light(),
        home: Consumer<AppViewModel>(
          builder: (context, controller, _) {
            final localizations = AppLocalizations.of(context);
            return switch (controller.status) {
              AppStatus.loading => const SyncingAccountScreen(),
              AppStatus.unauthenticated => LoginScreen(
                onLogin: () => _startLogin(context),
              ),
              AppStatus.needsProductSelection => ProductPickerScreen(
                controller: controller,
              ),
              AppStatus.ready => DashboardScreen(controller: controller),
              AppStatus.error => Scaffold(
                appBar: AppBar(title: Text(localizations.appTitle)),
                body: Center(
                  child: Text(
                    controller.errorMessage ?? localizations.unexpectedError,
                  ),
                ),
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
    await widget.authService.exchangeCode(
      code: callback.code,
      verifier: pkce.verifier,
    );
    if (context.mounted) {
      Navigator.of(context).pop();
    }
    await _controller.onLoginCompleted();
  }
}
