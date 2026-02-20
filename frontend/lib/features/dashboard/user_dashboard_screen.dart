import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/shimmer_loading.dart';
import '../trip/loading_trip_screen.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  String? selectedProduce;
  bool _isLoading = true;
  int _selectedCategoryIndex = 0;

  final List<String> categories = [
    '🍎 Fruits',
    '🥬 Vegetables',
    '🌾 Grains',
    '🥛 Dairy',
    '🌿 Herbs',
  ];

  final List<Map<String, dynamic>> products = [
    {'name': 'Strawberries', 'icon': '🍓', 'price': '₹120/kg', 'freshness': 0.96},
    {'name': 'Carrots', 'icon': '🥕', 'price': '₹40/kg', 'freshness': 0.92},
    {'name': 'Tomatoes', 'icon': '🍅', 'price': '₹35/kg', 'freshness': 0.88},
    {'name': 'Leafy Greens', 'icon': '🥬', 'price': '₹60/kg', 'freshness': 0.78},
    {'name': 'Apples', 'icon': '🍎', 'price': '₹150/kg', 'freshness': 0.94},
    {'name': 'Grapes', 'icon': '🍇', 'price': '₹80/kg', 'freshness': 0.85},
  ];

  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Simulate loading delay for shimmer demo
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentTime = DateFormat('HH:mm, MMM d').format(DateTime.now());
    final String greeting = _getGreeting();

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          _buildPremiumAppBar(greeting),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Quick Stats Row
                _buildQuickStats()
                    .animate()
                    .fadeIn(delay: 200.ms)
                    .moveY(begin: 10, end: 0),
                const SizedBox(height: 24),

                // Category chips
                _buildCategoryChips(),
                const SizedBox(height: 20),

                // Product grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Available Produce',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: AppTheme.sunsetOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _buildProductGrid(),
                const SizedBox(height: 32),

                // New Load Entry Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: AppTheme.accentGradient,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_circle_outline_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New Load Entry',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              Text(
                                'Record harvest details for transit',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                          .animate()
                          .fadeIn(delay: 300.ms)
                          .moveX(begin: -10, end: 0),
                      const SizedBox(height: 24),
                      _buildAutoFillBanner(currentTime),
                      const SizedBox(height: 24),
                      Text(
                        'What are you transporting?',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      _buildProduceDropdown(),
                      const SizedBox(height: 20),
                      Text(
                        'Quantity (Total Load)',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 10),
                      _buildQuantityField(),
                      const SizedBox(height: 24),
                      _buildDestinationCard(),
                      const SizedBox(height: 32),
                      _buildStartButton(),
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

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Widget _buildPremiumAppBar(String greeting) {
    return SliverAppBar(
      expandedHeight: 180,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.forestGreen,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
          child: Stack(
            children: [
              // Decorative elements
              Positioned(
                right: -30,
                top: -20,
                child: Icon(
                  Icons.eco_rounded,
                  size: 200,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
              Positioned(
                left: -20,
                bottom: 20,
                child: Icon(
                  Icons.route_rounded,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
              // Content
              Positioned(
                bottom: 50,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Farmer Dashboard',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.wb_sunny_rounded,
                color: AppTheme.sunsetOrangeLight,
                size: 16,
              ),
              const SizedBox(width: 6),
              const Text(
                '28°C',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildStatChip(
              Icons.local_shipping_rounded,
              'Active Trips',
              '3',
              AppTheme.forestGreen,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatChip(
              Icons.trending_up_rounded,
              'Revenue',
              '₹12.4K',
              AppTheme.sunsetOrange,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildStatChip(
              Icons.eco_rounded,
              'Freshness',
              '94%',
              AppTheme.successGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: products.length,
        itemBuilder: (context, index) {
          if (_isLoading) {
            return const Padding(
              padding: EdgeInsets.only(right: 12),
              child: ShimmerProductCard(),
            );
          }
          final product = products[index];
          final isSelected = selectedProduce == product['name'];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () =>
                  setState(() => selectedProduce = product['name'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 140,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.forestGreen.withValues(alpha: 0.08)
                      : Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.forestGreen.withValues(alpha: 0.3)
                        : Colors.grey.withValues(alpha: 0.1),
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color:
                                AppTheme.forestGreen.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product emoji/icon
                    Container(
                      width: double.infinity,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreen.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          product['icon'] as String,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      product['name'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          product['price'] as String,
                          style: TextStyle(
                            color: AppTheme.sunsetOrange,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.successGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${((product['freshness'] as double) * 100).toInt()}%',
                            style: TextStyle(
                              color: AppTheme.successGreen,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
                  .animate()
                  .fadeIn(delay: (100 * index).ms)
                  .moveY(begin: 10, end: 0),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAutoFillBanner(String time) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.forestGreen.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.forestGreen.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.location_on_rounded,
            'Origin Point',
            'Nashik Farm Cluster #4',
            AppTheme.forestGreen,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Divider(
              height: 1,
              color: AppTheme.forestGreen.withValues(alpha: 0.08),
            ),
          ),
          _buildInfoRow(
            Icons.access_time_rounded,
            'Timestamp',
            time,
            AppTheme.sunsetOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProduceDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedProduce,
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.inventory_2_outlined,
          color: AppTheme.forestGreen,
        ),
        filled: true,
        fillColor: AppTheme.forestGreen.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppTheme.forestGreen.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppTheme.forestGreen.withValues(alpha: 0.1),
          ),
        ),
      ),
      hint: const Text('Select Produce Type'),
      items: products
          .map(
            (p) => DropdownMenuItem(
              value: p['name'] as String,
              child: Row(
                children: [
                  Text(p['icon'] as String),
                  const SizedBox(width: 8),
                  Text(
                    p['name'] as String,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (val) => setState(() => selectedProduce = val),
    );
  }

  Widget _buildQuantityField() {
    return TextField(
      controller: _quantityController,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.monitor_weight_outlined,
          color: AppTheme.sunsetOrange,
        ),
        suffixText: 'kg',
        suffixStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: AppTheme.sunsetOrange,
        ),
        hintText: '0.00',
        filled: true,
        fillColor: AppTheme.sunsetOrange.withValues(alpha: 0.04),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppTheme.sunsetOrange.withValues(alpha: 0.1),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppTheme.sunsetOrange.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppTheme.sunsetOrange,
            width: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Destination',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.infoBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.navigation_outlined,
                  color: AppTheme.infoBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Text(
                  'Mumbai APMC Market Terminal 2',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
              Icon(
                Icons.edit_location_alt_rounded,
                size: 18,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    final bool isReady = selectedProduce != null;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: isReady ? AppTheme.primaryGradient : null,
        color: isReady ? null : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(18),
        boxShadow: isReady
            ? [
                BoxShadow(
                  color: AppTheme.forestGreen.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: !isReady
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        LoadingTripScreen(produce: selectedProduce!),
                  ),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_filled_rounded,
              color: isReady ? Colors.white : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'START NEW TRIP',
              style: TextStyle(
                color: isReady ? Colors.white : Colors.grey,
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
