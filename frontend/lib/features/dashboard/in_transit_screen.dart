import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/app_settings.dart';
import '../../core/overlays/weather_overlay.dart';
import '../profile/trip_summary_screen.dart';

class InTransitScreen extends StatefulWidget {
  final String produce;
  const InTransitScreen({super.key, required this.produce});

  @override
  State<InTransitScreen> createState() => _InTransitScreenState();
}

class _InTransitScreenState extends State<InTransitScreen>
    with TickerProviderStateMixin {
  bool _showWarning = false;
  double _freshness = 0.94;
  Color _routeColor = AppTheme.forestGreen;
  bool _isRoutePulsing = false;
  double _truckProgress = 0.0;
  late AnimationController _truckController;
  bool _showProfitSheet = false;

  @override
  void initState() {
    super.initState();
    _truckController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..forward();
    _truckController.addListener(() {
      if (mounted) {
        setState(() {
          _truckProgress = _truckController.value;
        });
      }
    });
    _simulateJourney();
  }

  void _simulateJourney() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      context.read<AppSettings>().setWeather(WeatherState.rainy);
    }

    await Future.delayed(const Duration(seconds: 4));
    if (mounted) {
      setState(() {
        _routeColor = AppTheme.errorRed;
        _isRoutePulsing = true;
        _showWarning = true;
      });
    }

    await Future.delayed(const Duration(seconds: 5));
    if (mounted) {
      context.read<AppSettings>().setWeather(WeatherState.hot);
    }

    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) setState(() => _freshness -= 0.005);
    }
  }

  @override
  void dispose() {
    _truckController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();

    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
          _buildMapLayer(settings),

          // Weather Overlay
          WeatherOverlay(state: settings.weatherState),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Theme toggle
                  _buildCircleButton(
                    icon: settings.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                    color: settings.isDarkMode ? Colors.blue : AppTheme.sunsetOrange,
                    onTap: () => settings.toggleTheme(),
                    isDark: settings.isDarkMode,
                  ),
                  const Spacer(),
                  // Produce badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _freshness > 0.85
                                ? AppTheme.successGreen
                                : AppTheme.sunsetOrange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.produce,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Profit optimization toggle
                  _buildCircleButton(
                    icon: Icons.analytics_rounded,
                    color: AppTheme.sunsetOrange,
                    onTap: () =>
                        setState(() => _showProfitSheet = !_showProfitSheet),
                    isDark: true,
                  ),
                ],
              ),
            ),
          ),

          // Warning Banner
          if (_showWarning)
            Positioned(
              top: MediaQuery.of(context).padding.top + 56,
              left: 16,
              right: 16,
              child: _buildWarningBanner(),
            ),

          // Stats Panel (Bottom)
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildStatsPanel(context, settings),
          ),

          // Profit Optimization Sheet
          if (_showProfitSheet)
            Positioned(
              right: 16,
              top: MediaQuery.of(context).padding.top + 56,
              child: _buildProfitSheet(),
            ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 20)
            .animate(key: ValueKey(icon))
            .rotate(begin: -0.5, end: 0, duration: 400.ms),
      ),
    );
  }

  Widget _buildMapLayer(AppSettings settings) {
    return Container(
      color: settings.isDarkMode
          ? const Color(0xFF0A0F0A)
          : const Color(0xFFE8EDE8),
      child: CustomPaint(
        size: Size.infinite,
        painter: _PremiumPathPainter(
          routeColor: _routeColor,
          isPulsing: _isRoutePulsing,
          truckProgress: _truckProgress,
          isDark: settings.isDarkMode,
        ),
      ),
    );
  }

  Widget _buildWarningBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.errorRed,
            AppTheme.errorRed.withValues(alpha: 0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorRed.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20)
              .animate(onPlay: (c) => c.repeat())
              .shake(duration: 600.ms),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'SPOILAGE RISK HIGH — Rerouting Suggested',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _showWarning = false),
            child: const Icon(Icons.close_rounded,
                color: Colors.white70, size: 18),
          ),
        ],
      ),
    ).animate().slideY(begin: -1, end: 0, duration: 400.ms);
  }

  Widget _buildProfitSheet() {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_rounded,
                  color: AppTheme.sunsetOrange, size: 16),
              SizedBox(width: 8),
              Text(
                'Profit Optimizer',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildProfitRow('Current Route', '₹38/kg', false),
          _buildProfitRow('Alt Route A', '₹42/kg', true),
          _buildProfitRow('Alt Route B', '₹40/kg', false),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.forestGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.lightbulb_rounded,
                    color: AppTheme.sunsetOrange, size: 14),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Switch to Alt A for +₹400 revenue',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1, 1),
          duration: 300.ms,
        );
  }

  Widget _buildProfitRow(String route, String price, bool isBest) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            route,
            style: TextStyle(
              color: isBest ? AppTheme.sunsetOrangeLight : Colors.white54,
              fontSize: 12,
              fontWeight: isBest ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Text(
                price,
                style: TextStyle(
                  color: isBest ? AppTheme.sunsetOrangeLight : Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (isBest) ...[
                const SizedBox(width: 4),
                const Icon(Icons.arrow_upward_rounded,
                    color: AppTheme.successGreen, size: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(BuildContext context, AppSettings settings) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildGlanceStat(
                  'ETA',
                  '14:42',
                  Icons.access_time_rounded,
                  AppTheme.infoBlue,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.withValues(alpha: 0.15),
              ),
              Expanded(
                child: _buildGlanceStat(
                  'FRESHNESS',
                  '${(_freshness * 100).toInt()}%',
                  Icons.eco_rounded,
                  _freshness > 0.85
                      ? AppTheme.forestGreen
                      : _freshness > 0.6
                          ? AppTheme.sunsetOrange
                          : AppTheme.errorRed,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.withValues(alpha: 0.15),
              ),
              Expanded(
                child: _buildGlanceStat(
                  'DISTANCE',
                  '87 km',
                  Icons.straighten_rounded,
                  AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_showWarning) ...[
            _buildRerouteAction(),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.errorRed.withValues(alpha: 0.3),
                    ),
                  ),
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorRed,
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emergency_rounded, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'SOS',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.forestGreen.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TripSummaryScreen(),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'ARRIVED',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlanceStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildRerouteAction() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.infoBlue.withValues(alpha: 0.08),
            AppTheme.infoBlue.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.infoBlue.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.alt_route_rounded,
              color: AppTheme.infoBlue, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alternative Route Available',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  '+₹400 Value • Saves 8% freshness',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.infoBlue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => setState(() {
                  _showWarning = false;
                  _isRoutePulsing = false;
                  _routeColor = AppTheme.forestGreen;
                }),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: Text(
                    'ACCEPT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        );
  }
}

class _PremiumPathPainter extends CustomPainter {
  final Color routeColor;
  final bool isPulsing;
  final double truckProgress;
  final bool isDark;

  _PremiumPathPainter({
    required this.routeColor,
    required this.isPulsing,
    required this.truckProgress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Grid pattern
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white : AppTheme.forestGreen)
          .withValues(alpha: 0.04)
      ..strokeWidth = 0.5;

    const spacing = 35.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Route glow
    final glowPaint = Paint()
      ..color = routeColor.withValues(alpha: isPulsing ? 0.15 : 0.08)
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.75)
      ..cubicTo(
        size.width * 0.3, size.height * 0.6,
        size.width * 0.5, size.height * 0.55,
        size.width * 0.6, size.height * 0.45,
      )
      ..cubicTo(
        size.width * 0.7, size.height * 0.35,
        size.width * 0.75, size.height * 0.28,
        size.width * 0.85, size.height * 0.2,
      );

    canvas.drawPath(path, glowPaint);

    // Route line
    final routePaint = Paint()
      ..color = routeColor.withValues(alpha: isPulsing ? 0.7 : 0.5)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, routePaint);

    // Origin circle
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.75),
      8,
      Paint()..color = AppTheme.sunsetOrange,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.75),
      4,
      Paint()..color = Colors.white,
    );

    // Destination circle
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      8,
      Paint()..color = AppTheme.forestGreen,
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      4,
      Paint()..color = Colors.white,
    );

    // Truck position (interpolated along path)
    final pathMetrics = path.computeMetrics().first;
    final truckPosition = pathMetrics.getTangentForOffset(
      pathMetrics.length * truckProgress,
    );

    if (truckPosition != null) {
      // Truck glow
      canvas.drawCircle(
        truckPosition.position,
        18,
        Paint()
          ..color = AppTheme.infoBlue.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );

      // Truck body
      canvas.drawCircle(
        truckPosition.position,
        10,
        Paint()..color = AppTheme.infoBlue,
      );

      // Truck icon (small white circle as "window")
      canvas.drawCircle(
        truckPosition.position,
        4,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumPathPainter oldDelegate) => true;
}
