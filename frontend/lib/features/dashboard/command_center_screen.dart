import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/freshness_gauge.dart';
import 'in_transit_screen.dart';

class CommandCenterScreen extends StatelessWidget {
  final String produce;
  const CommandCenterScreen({super.key, required this.produce});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D120D),
      body: Stack(
        children: [
          // Map Layer
          Positioned.fill(
            bottom: MediaQuery.of(context).size.height * 0.48,
            child: _buildMapMockup(),
          ),

          // Data Command Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.56,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHeader(context),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(flex: 3, child: _buildFreshnessCard()),
                        const SizedBox(width: 14),
                        Expanded(flex: 4, child: _buildPriceCurve()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildMarketRecommendations(),
                    const SizedBox(height: 24),
                    _buildCommenceButton(context),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapMockup() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF0D120D),
            AppTheme.forestGreenDark.withValues(alpha: 0.5),
          ],
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: _MapGridPainter(),
          ),
          CustomPaint(
            size: Size.infinite,
            painter: _RoutePainter(),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.forestGreen.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.forestGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Icon(
                    Icons.navigation_rounded,
                    color: AppTheme.sunsetOrange,
                    size: 28,
                  ),
                )
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.1, 1.1),
                      duration: 1500.ms,
                    ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Route Preview Active',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.forestGreen.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                produce.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.forestGreen,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Route Intelligence',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.sunsetOrange.withValues(alpha: 0.15),
                AppTheme.sunsetOrange.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.sunsetOrange.withValues(alpha: 0.15),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.thermostat_rounded,
                  color: AppTheme.sunsetOrange, size: 16),
              SizedBox(width: 4),
              Text(
                '28°C',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.sunsetOrange,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(delay: 100.ms).moveY(begin: 5, end: 0);
  }

  Widget _buildFreshnessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: const Column(
        children: [
          Text(
            'Freshness',
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8),
          FreshnessGauge(
            freshness: 0.94,
            size: 90,
            strokeWidth: 8,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        );
  }

  Widget _buildPriceCurve() {
    return Container(
      height: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Market Value',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '₹42/kg',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.successGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 4),
                      FlSpot(0.5, 4.2),
                      FlSpot(1, 3.8),
                      FlSpot(1.5, 3.9),
                      FlSpot(2, 3.5),
                      FlSpot(2.5, 3.0),
                      FlSpot(3, 2.8),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [AppTheme.sunsetOrange, AppTheme.sunsetOrangeLight],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.sunsetOrange.withValues(alpha: 0.2),
                          AppTheme.sunsetOrange.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Now',
                  style: TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary)),
              Text('24h',
                  style: TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).scale(
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        );
  }

  Widget _buildMarketRecommendations() {
    final recommendations = [
      {
        'market': 'Vashi Terminal',
        'demand': 'HIGH',
        'price': '₹42/kg',
        'eta': '2h 15m',
        'recommended': true,
      },
      {
        'market': 'Navi Mumbai APMC',
        'demand': 'MEDIUM',
        'price': '₹38/kg',
        'eta': '1h 45m',
        'recommended': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.auto_awesome_rounded,
                color: AppTheme.sunsetOrange, size: 18),
            SizedBox(width: 8),
            Text(
              'AI Market Recommendations',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recommendations
            .asMap()
            .entries
            .map((entry) => _buildRecommendationTile(entry.value)),
      ],
    ).animate().fadeIn(delay: 400.ms).moveY(begin: 10, end: 0);
  }

  Widget _buildRecommendationTile(Map<String, dynamic> rec) {
    final isRecommended = rec['recommended'] as bool;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isRecommended
            ? AppTheme.forestGreen.withValues(alpha: 0.06)
            : Colors.grey.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isRecommended
              ? AppTheme.forestGreen.withValues(alpha: 0.15)
              : Colors.grey.withValues(alpha: 0.1),
          width: isRecommended ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isRecommended
                  ? AppTheme.forestGreen
                  : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isRecommended
                  ? Icons.star_rounded
                  : Icons.store_rounded,
              color: isRecommended ? Colors.white : Colors.grey.shade600,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      rec['market'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    if (isRecommended) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.sunsetOrange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'BEST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildMiniTag(
                        rec['demand'] as String,
                        rec['demand'] == 'HIGH'
                            ? AppTheme.successGreen
                            : AppTheme.warningAmber),
                    const SizedBox(width: 8),
                    Text(
                      '${rec['price']} • ETA ${rec['eta']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded,
              color: AppTheme.textSecondary, size: 20),
        ],
      ),
    );
  }

  Widget _buildMiniTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCommenceButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.infoBlue, Color(0xFF42A5F5)],
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.infoBlue.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InTransitScreen(produce: produce),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.navigation_rounded, size: 20),
            SizedBox(width: 10),
            Text(
              'COMMENCE TRANSIT',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.forestGreen.withValues(alpha: 0.06)
      ..strokeWidth = 0.5;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final routePaint = Paint()
      ..color = AppTheme.forestGreen.withValues(alpha: 0.4)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.15, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.5,
        size.width * 0.6,
        size.height * 0.45,
      )
      ..quadraticBezierTo(
        size.width * 0.8,
        size.height * 0.4,
        size.width * 0.85,
        size.height * 0.2,
      );

    canvas.drawPath(path, routePaint);

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.8),
      6,
      Paint()..color = AppTheme.sunsetOrange,
    );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.2),
      6,
      Paint()..color = AppTheme.forestGreen,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
