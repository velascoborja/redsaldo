import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';

const _heroImageUrl =
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBdQXQnQxxTM9AHc_PF0NgBUK9lq6Ze6IIGFy2Cl5-fibJqROl355sJ0FNLtjTRH2G5IdgEO6ilAklQ4EuIIdrk9GL2YEPrUVWnD_-KTPWEz7jwr_07JYl4ofScA_jY0dBRUVa-vvOJjFzDgSBIDzu8sxgExm9QN2uu_k0YkmlTI4yLUSEWYydpVBRR44mSrHzW3n02Qh3PuDzbuJB8w5CNZYYsrBAykjaeabu98FqXjybjW3duO9rgYExv2Gr1gslNdi_1JtHQEfU';

const _navyDark = Color(0xFF0F172A);
const _navyMedium = Color(0xFF1E293B);
const _redAlert = Color(0xFFF72717);
const _slateLight = Color(0xFF94A3B8);

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
            child: Image.network(
              _heroImageUrl,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(color: _navyMedium);
              },
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
