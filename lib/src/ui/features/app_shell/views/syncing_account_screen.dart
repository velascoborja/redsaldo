import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme.dart';

class SyncingAccountScreen extends StatelessWidget {
  const SyncingAccountScreen({super.key});

  static const String title = 'Syncing your account';
  static const String status = 'Fetching your balance...';
  static const String description =
      'This should only take a moment. Securely connecting to your meal allowance provider.';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: EdenredColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            const Center(child: _AmbientGlow()),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Transform.translate(
                    offset: const Offset(0, -16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const _WalletProgressMark(),
                        const SizedBox(height: 40),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: EdenredColors.navyDark,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          status,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyLarge?.copyWith(
                            color: EdenredColors.navyDark,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: EdenredColors.navyDark.withValues(
                              alpha: 0.8,
                            ),
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletProgressMark extends StatefulWidget {
  const _WalletProgressMark();

  @override
  State<_WalletProgressMark> createState() => _WalletProgressMarkState();
}

class _WalletProgressMarkState extends State<_WalletProgressMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          RotationTransition(
            key: const ValueKey<String>('syncing-progress-ring-spinner'),
            turns: _controller,
            child: CustomPaint(
              key: const ValueKey<String>('syncing-progress-ring'),
              size: const Size.square(128),
              painter: const _RoundedProgressRingPainter(
                progress: 0.62,
                strokeWidth: 6,
              ),
            ),
          ),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: EdenredColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: EdenredColors.navyDark.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.account_balance_wallet,
              color: EdenredColors.navyDark,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundedProgressRingPainter extends CustomPainter {
  const _RoundedProgressRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  final double progress;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final bounds = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..color = EdenredColors.grayLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final progressPaint = Paint()
      ..color = EdenredColors.redAlert
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);
    canvas.drawArc(
      bounds,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_RoundedProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

class _AmbientGlow extends StatelessWidget {
  const _AmbientGlow();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: EdenredColors.redAlert.withValues(alpha: 0.05),
            blurRadius: 80,
            spreadRadius: 40,
          ),
        ],
      ),
    );
  }
}
