import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_provider.dart';
import '../dashboard/command_center_screen.dart';

class LoadingTripScreen extends StatefulWidget {
  final String produce;
  final String? tripId;
  const LoadingTripScreen({super.key, required this.produce, this.tripId});

  @override
  State<LoadingTripScreen> createState() => _LoadingTripScreenState();
}

class _LoadingTripScreenState extends State<LoadingTripScreen>
    with TickerProviderStateMixin {
  int _step = 0;
  late AnimationController _orbitController;
  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _steps = [
    {'msg': 'Analyzing produce degradation rate...', 'icon': Icons.biotech_rounded},
    {'msg': 'Fetching real-time weather heatmap...', 'icon': Icons.cloud_rounded},
    {'msg': 'Optimizing route via traffic AI...', 'icon': Icons.route_rounded},
    {'msg': 'Syncing with market demand API...', 'icon': Icons.trending_up_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _startLoading();
  }

  void _startLoading() async {
    // If we have a tripId, verify the trip exists on the backend
    if (widget.tripId != null) {
      try {
        final auth = context.read<AuthProvider>();
        await auth.api.getTripStatus(widget.tripId!);
      } catch (_) {
        // Trip verification failed — continue anyway for demo
      }
    }

    for (int i = 0; i < _steps.length; i++) {
      await Future.delayed(const Duration(milliseconds: 1400));
      if (mounted) setState(() => _step = i + 1);
    }
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, a1, a2) =>
              CommandCenterScreen(produce: widget.produce, tripId: widget.tripId),
          transitionsBuilder: (context, animation, a2, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundLight,
              AppTheme.forestGreen.withValues(alpha: 0.03),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated orbital ring
                  SizedBox(
                    width: 160,
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer orbit ring
                        AnimatedBuilder(
                          animation: _orbitController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: _orbitController.value * 6.28,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.forestGreen
                                        .withValues(alpha: 0.15),
                                    width: 2,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: AppTheme.sunsetOrange,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.sunsetOrange
                                              .withValues(alpha: 0.5),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Inner orbit ring (counter-rotate)
                        AnimatedBuilder(
                          animation: _orbitController,
                          builder: (context, child) {
                            return Transform.rotate(
                              angle: -_orbitController.value * 6.28 * 0.7,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppTheme.sunsetOrange
                                        .withValues(alpha: 0.1),
                                    width: 1.5,
                                  ),
                                ),
                                child: Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: AppTheme.forestGreen,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.forestGreen
                                              .withValues(alpha: 0.5),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        // Center icon with pulse
                        AnimatedBuilder(
                          animation: _pulseController,
                          builder: (context, child) {
                            final scale =
                                1.0 + (_pulseController.value * 0.08);
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppTheme.forestGreen,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.forestGreen
                                          .withValues(alpha: 0.25),
                                      blurRadius: 20,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.psychology_rounded,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms)
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1, 1),
                      ),

                  const SizedBox(height: 48),

                  // Status label
                  Text(
                    'PREPARING ROUTE',
                    style: TextStyle(
                      letterSpacing: 4,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.forestGreen.withValues(alpha: 0.3),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Step message
                  SizedBox(
                    height: 50,
                    child: Text(
                      _step < _steps.length
                          ? _steps[_step]['msg'] as String
                          : 'Intelligence Ready ✓',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _step >= _steps.length
                            ? AppTheme.forestGreen
                            : AppTheme.textPrimary,
                      ),
                    ).animate(key: ValueKey(_step)).fadeIn().slideY(
                          begin: 0.15,
                          end: 0,
                        ),
                  ),

                  const SizedBox(height: 32),

                  // Progress steps with icons
                  _buildProgressSteps(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSteps() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (index) {
        final bool isActive = index < _step;
        final bool isCurrent = index == _step;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isCurrent ? 32 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: isActive
                  ? AppTheme.forestGreen
                  : isCurrent
                      ? AppTheme.sunsetOrange
                      : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(5),
              boxShadow: isActive || isCurrent
                  ? [
                      BoxShadow(
                        color: (isActive
                                ? AppTheme.forestGreen
                                : AppTheme.sunsetOrange)
                            .withValues(alpha: 0.3),
                        blurRadius: 6,
                      ),
                    ]
                  : [],
            ),
          ),
        );
      }),
    );
  }
}
