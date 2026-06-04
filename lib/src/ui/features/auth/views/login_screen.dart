import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../l10n/app_localizations.dart';

const _heroImageAsset = 'assets/images/login_hero.webp';

const _navyDark = Color(0xFF0F172A);
const _navyMedium = Color(0xFF1E293B);
const _redAlert = Color(0xFFF72717);
const _slateLight = Color(0xFF94A3B8);

void loginScreenPreviewLoginCallback() {}

@Preview(name: 'Login screen - English', group: 'Auth', size: Size(390, 844))
Widget loginScreenEnglishPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale('en'),
    home: LoginScreen(onLogin: loginScreenPreviewLoginCallback),
  );
}

@Preview(name: 'Login screen - Spanish', group: 'Auth', size: Size(390, 844))
Widget loginScreenSpanishPreview() {
  return const MaterialApp(
    debugShowCheckedModeBanner: false,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: Locale('es'),
    home: LoginScreen(onLogin: loginScreenPreviewLoginCallback),
  );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({required this.onLogin, super.key});

  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: _navyDark,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              _heroImageAsset,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: _navyMedium);
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: screenHeight * 0.45,
            child: Container(
              decoration: const BoxDecoration(
                color: _navyDark,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 28),
                        Center(
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: _navyMedium,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 36,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          localizations.loginBrand,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          localizations.loginSubtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: _slateLight,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 58,
                          child: ElevatedButton.icon(
                            onPressed: onLogin,
                            icon: const Icon(
                              Icons.login_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            label: Text(
                              localizations.loginButton,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _redAlert,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _navyMedium,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.shield_outlined,
                                size: 20,
                                color: _slateLight,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  localizations.loginSecurityNote,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: _slateLight,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
