import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../auth/splash_screen.dart';

class TripSummaryScreen extends StatefulWidget {
  const TripSummaryScreen({super.key});

  @override
  State<TripSummaryScreen> createState() => _TripSummaryScreenState();
}

class _TripSummaryScreenState extends State<TripSummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Celebration particles
          AnimatedBuilder(
            animation: _celebrationController,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _CelebrationPainter(
                  progress: _celebrationController.value,
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Success icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                      )
                      .fadeIn(),

                  const SizedBox(height: 24),

                  Text(
                    'Delivery Successful!',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ).animate().fadeIn(delay: 300.ms).moveY(begin: 10, end: 0),

                  const SizedBox(height: 4),

                  const Text(
                    'AI optimized your route for maximum value',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 36),

                  // Freshness Score Card
                  _buildScoreCard(),

                  const SizedBox(height: 24),

                  // Stats Grid
                  _buildStatGrid(),

                  const Spacer(),

                  // Action buttons
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.forestGreen.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SplashScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Back to Dashboard',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      foregroundColor: AppTheme.forestGreen,
                      side: BorderSide(
                        color: AppTheme.forestGreen.withValues(alpha: 0.2),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Share Report',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.forestGreen.withValues(alpha: 0.06),
            AppTheme.sunsetOrange.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.forestGreen.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'FINAL FRESHNESS SCORE',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              letterSpacing: 2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppTheme.forestGreen, AppTheme.forestGreenLight],
            ).createShader(bounds),
            child: const Text(
              '89%',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 14),
                SizedBox(width: 4),
                Text(
                  'EXCELLENT',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildStatGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildSmallStat(
          'Time Saved',
          '22 min',
          Icons.access_time_rounded,
          AppTheme.infoBlue,
        ),
        _buildSmallStat(
          'Revenue Boost',
          '₹1,240',
          Icons.trending_up_rounded,
          AppTheme.sunsetOrange,
        ),
        _buildSmallStat(
          'Quality Index',
          'Tier 1',
          Icons.workspace_premium_rounded,
          AppTheme.forestGreen,
        ),
        _buildSmallStat(
          'Distance',
          '142 km',
          Icons.route_rounded,
          AppTheme.textSecondary,
        ),
      ],
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildSmallStat(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _CelebrationPainter extends CustomPainter {
  final double progress;
  final Random _random = Random(42); // Fixed seed for consistent particles

  _CelebrationPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress < 0.1) return;

    final colors = [
      AppTheme.forestGreen,
      AppTheme.sunsetOrange,
      AppTheme.sunsetOrangeLight,
      AppTheme.forestGreenLight,
      AppTheme.infoBlue,
    ];

    for (int i = 0; i < 30; i++) {
      final startX = _random.nextDouble() * size.width;
      final startY = -20.0;
      final endY = size.height * (0.3 + _random.nextDouble() * 0.7);

      final currentY = startY + (endY - startY) * progress;
      final wobble = sin(progress * 6 + i) * 20;

      final opacity = (1.0 - progress).clamp(0.0, 0.6);

      final paint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      final particleSize = 3.0 + _random.nextDouble() * 4;
      canvas.drawCircle(
        Offset(startX + wobble, currentY),
        particleSize,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CelebrationPainter oldDelegate) => true;
}
