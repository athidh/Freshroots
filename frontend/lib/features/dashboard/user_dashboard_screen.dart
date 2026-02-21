import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../../core/services/auth_provider.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/app_settings.dart';
import '../../l10n/app_localizations.dart';
import '../trip/loading_trip_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  String? selectedProduce;
  bool _isLoading = true;
  bool _isStarting = false;
  int _selectedCategoryIndex = 0;

  List<Map<String, dynamic>> products = [];
  int _activeTrips = 0;

  final TextEditingController _quantityController = TextEditingController();

  // Emoji map for produce names
  static const _produceEmoji = {
    'Apple': '🍎', 'Banana': '🍌', 'Strawberry': '🍓',
    'Mango': '🥭', 'Grapes': '🍇', 'Spinach': '🥬',
    'Tomato': '🍅', 'Broccoli': '🥦', 'Carrot': '🥕', 'Potato': '🥔',
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final auth = context.read<AuthProvider>();
    try {
      final produceData = await auth.api.getProduceList();
      final fruits = (produceData['fruits'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final vegs = (produceData['vegetables'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final allProduce = [...fruits, ...vegs];

      int trips = 0;
      if (auth.isLoggedIn) {
        try {
          final tripData = await auth.api.getUserTrips();
          final tripList = tripData['trips'] as List? ?? [];
          trips = tripList.where((t) => t['status'] == 'IN_TRANSIT').length;
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          products = allProduce.map((p) {
            final name = p['name'] as String;
            return {
              'name': name,
              'icon': _produceEmoji[name] ?? '🌿',
              'decay': p['decay_constant'],
              'category': fruits.contains(p) ? 0 : 1,
            };
          }).toList();
          _activeTrips = trips;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  String _getGreeting(AppLocalizations l) {
    final hour = DateTime.now().hour;
    if (hour < 12) return l.good_morning;
    if (hour < 17) return l.good_afternoon;
    return l.good_evening;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final settings = context.watch<AppSettings>();
    final isDark = settings.isDarkMode;
    final String currentTime = DateFormat('HH:mm, MMM d').format(DateTime.now());
    final String greeting = _getGreeting(l);
    final auth = context.watch<AuthProvider>();
    final username = auth.isLoggedIn ? auth.username : 'Farmer';
    final filteredProducts = products
        .where((p) => p['category'] == _selectedCategoryIndex)
        .toList();

    // Localised category names
    final categories = [l.fruits, l.vegetables];

    // Dark mode adaptive colors
    final bgColor = isDark ? const Color(0xFF1E1E2C) : Colors.white;
    final cardBg = isDark ? const Color(0xFF2A2A3C) : Theme.of(context).cardTheme.color;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          _buildPremiumAppBar(greeting, username, l, settings),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildQuickStats(l).animate().fadeIn(delay: 200.ms).moveY(begin: 10, end: 0),
                const SizedBox(height: 24),
                _buildCategoryChips(categories, isDark),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(child: Text(l.available_produce,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700, color: textColor),
                        maxLines: 2, overflow: TextOverflow.ellipsis)),
                      TextButton(
                        onPressed: () {},
                        child: Text(l.view_all,
                          style: const TextStyle(color: AppTheme.sunsetOrange, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildProductGrid(filteredProducts, l, isDark, cardBg),
                const SizedBox(height: 32),

                // New Load Entry
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Divider(color: isDark ? Colors.white24 : null),
                      const SizedBox(height: 24),
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(gradient: AppTheme.accentGradient, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(l.new_load_entry,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800, color: textColor),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                          Text(l.record_harvest,
                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        ])),
                      ]).animate().fadeIn(delay: 300.ms).moveX(begin: -10, end: 0),
                      const SizedBox(height: 24),
                      _buildAutoFillBanner(currentTime, l, isDark),
                      const SizedBox(height: 24),
                      Text(l.what_transporting,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700, color: textColor)),
                      const SizedBox(height: 10),
                      _buildProduceDropdown(l, isDark),
                      const SizedBox(height: 20),
                      Text(l.quantity_label,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700, color: textColor)),
                      const SizedBox(height: 10),
                      _buildQuantityField(),
                      const SizedBox(height: 24),
                      _buildDestinationCard(l, isDark, cardBg, textColor),
                      const SizedBox(height: 32),
                      _buildStartButton(l),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar with dark mode toggle ────────────────────────────

  Widget _buildPremiumAppBar(String greeting, String username, AppLocalizations l, AppSettings settings) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.forestGreen,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
          child: Stack(children: [
            Positioned(right: -30, top: -20, child: Icon(Icons.eco_rounded, size: 200, color: Colors.white.withValues(alpha: 0.05))),
            Positioned(left: -20, bottom: 20, child: Icon(Icons.route_rounded, size: 100, color: Colors.white.withValues(alpha: 0.04))),
            Positioned(bottom: 50, left: 20, right: 20, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(l.hi_user(username), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              ],
            )),
          ]),
        ),
      ),
      actions: [
        // ── Dark mode toggle ──
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              settings.isDarkMode ? Icons.wb_sunny_rounded : Icons.nightlight_round,
              color: settings.isDarkMode ? AppTheme.sunsetOrangeLight : Colors.white,
              size: 18,
            ),
            onPressed: () => settings.toggleTheme(),
            tooltip: l.dark_mode,
          ),
        ),
        // ── Weather pill ──
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.wb_sunny_rounded, color: AppTheme.sunsetOrangeLight, size: 16),
            const SizedBox(width: 6),
            const Text('28°C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
      ],
    );
  }

  // ── Quick Stats ──────────────────────────────────────────────

  Widget _buildQuickStats(AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(children: [
        Expanded(child: _buildStatChip(Icons.local_shipping_rounded, l.active_trips, '$_activeTrips', AppTheme.forestGreen)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatChip(Icons.trending_up_rounded, l.revenue, '₹12.4K', AppTheme.sunsetOrange)),
        const SizedBox(width: 10),
        Expanded(child: _buildStatChip(Icons.eco_rounded, l.freshness, '94%', AppTheme.successGreen)),
      ]),
    );
  }

  Widget _buildStatChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          maxLines: 2, overflow: TextOverflow.ellipsis),
      ]),
    );
  }

  // ── Category Chips ───────────────────────────────────────────

  Widget _buildCategoryChips(List<String> categories, bool isDark) {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategoryIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : (isDark ? Colors.white10 : Colors.grey.withValues(alpha: 0.08)),
                  borderRadius: BorderRadius.circular(12)),
                child: Text(categories[index],
                  style: TextStyle(color: isSelected ? Colors.white : AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Product Grid ─────────────────────────────────────────────

  Widget _buildProductGrid(List<Map<String, dynamic>> filteredProducts, AppLocalizations l, bool isDark, Color? cardBg) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          if (_isLoading) {
            return const Padding(padding: EdgeInsets.only(right: 12), child: ShimmerProductCard());
          }
          final product = filteredProducts[index];
          final isSelected = selectedProduce == product['name'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => selectedProduce = product['name'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 140, padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.forestGreen.withValues(alpha: 0.08) : cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppTheme.forestGreen.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
                    width: isSelected ? 2 : 1),
                  boxShadow: isSelected ? [BoxShadow(color: AppTheme.forestGreen.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))] : [],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: double.infinity, height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.forestGreen.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(product['icon'] as String, style: const TextStyle(fontSize: 32))),
                  ),
                  const SizedBox(height: 10),
                  Text(product['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(l.decay_label('${product['decay']}'),
                    style: const TextStyle(color: AppTheme.sunsetOrange, fontWeight: FontWeight.w600, fontSize: 11)),
                ]),
              ).animate().fadeIn(delay: (100 * index).ms).moveY(begin: 10, end: 0),
            ),
          );
        },
      ),
    );
  }

  // ── Auto-fill Banner ─────────────────────────────────────────

  Widget _buildAutoFillBanner(String time, AppLocalizations l, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : AppTheme.forestGreen.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.forestGreen.withValues(alpha: 0.1))),
      child: Column(children: [
        _buildInfoRow(Icons.location_on_rounded, l.origin_point, 'Nashik Farm Cluster #4', AppTheme.forestGreen),
        Padding(padding: const EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: AppTheme.forestGreen.withValues(alpha: 0.08))),
        _buildInfoRow(Icons.access_time_rounded, l.timestamp, time, AppTheme.sunsetOrange),
      ]),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 16, color: color)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
          maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          maxLines: 1, overflow: TextOverflow.ellipsis),
      ])),
    ]);
  }

  // ── Produce Dropdown ─────────────────────────────────────────

  Widget _buildProduceDropdown(AppLocalizations l, bool isDark) {
    return DropdownButtonFormField<String>(
      initialValue: selectedProduce,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.inventory_2_outlined, color: AppTheme.forestGreen),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : AppTheme.forestGreen.withValues(alpha: 0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.forestGreen.withValues(alpha: 0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.forestGreen.withValues(alpha: 0.1))),
      ),
      hint: Text(l.select_produce),
      isExpanded: true,
      items: products.map((p) => DropdownMenuItem(
        value: p['name'] as String,
        child: Row(children: [
          Text(p['icon'] as String),
          const SizedBox(width: 8),
          Expanded(child: Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600),
            maxLines: 1, overflow: TextOverflow.ellipsis)),
        ]),
      )).toList(),
      onChanged: (val) => setState(() => selectedProduce = val),
    );
  }

  // ── Quantity Field ───────────────────────────────────────────

  Widget _buildQuantityField() {
    return TextField(
      controller: _quantityController,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.monitor_weight_outlined, color: AppTheme.sunsetOrange),
        suffixText: 'kg',
        suffixStyle: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.sunsetOrange),
        hintText: '0.00',
        filled: true,
        fillColor: AppTheme.sunsetOrange.withValues(alpha: 0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.sunsetOrange.withValues(alpha: 0.1))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppTheme.sunsetOrange.withValues(alpha: 0.1))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.sunsetOrange, width: 2)),
      ),
    );
  }

  // ── Destination Card ─────────────────────────────────────────

  Widget _buildDestinationCard(AppLocalizations l, bool isDark, Color? cardBg, Color textColor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(l.destination,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: textColor)),
      const SizedBox(height: 10),
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardBg, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.infoBlue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.navigation_outlined, color: AppTheme.infoBlue, size: 18)),
          const SizedBox(width: 14),
          const Expanded(child: Text('Mumbai APMC Market Terminal 2',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
          Icon(Icons.edit_location_alt_rounded, size: 18, color: AppTheme.textSecondary),
        ]),
      ),
    ]);
  }

  // ── Start Button ─────────────────────────────────────────────

  Widget _buildStartButton(AppLocalizations l) {
    final bool isReady = selectedProduce != null && !_isStarting;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity, height: 60,
      decoration: BoxDecoration(
        gradient: isReady ? AppTheme.primaryGradient : null,
        color: isReady ? null : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isReady ? [BoxShadow(color: AppTheme.forestGreen.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))] : [],
      ),
      child: ElevatedButton(
        onPressed: !isReady ? null : () async {
          final auth = context.read<AuthProvider>();
          final quantity = double.tryParse(_quantityController.text) ?? 10;
          if (auth.isLoggedIn) {
            setState(() => _isStarting = true);
            try {
              final result = await auth.api.startTrip(selectedProduce!, quantity, 'GPS Location');
              final tripId = result['tripId'] as String;
              if (mounted) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => LoadingTripScreen(produce: selectedProduce!, tripId: tripId)));
              }
            } on ApiException catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.message), backgroundColor: AppTheme.errorRed));
            } catch (e) {
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l.trip_failed), backgroundColor: AppTheme.errorRed));
            } finally {
              if (mounted) setState(() => _isStarting = false);
            }
          } else {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => LoadingTripScreen(produce: selectedProduce!, tripId: null)));
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
        child: _isStarting
            ? const SizedBox(width: 22, height: 22,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
            : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.play_circle_filled_rounded, color: isReady ? Colors.white : Colors.grey, size: 24),
                const SizedBox(width: 10),
                Flexible(child: Text(l.start_new_trip, style: TextStyle(
                  color: isReady ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w800, letterSpacing: 1, fontSize: 15),
                  maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
      ),
    );
  }
}
