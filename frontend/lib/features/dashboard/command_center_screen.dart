import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_theme.dart';
import '../../core/widgets/freshness_gauge.dart';
import '../../core/services/auth_provider.dart';
import 'in_transit_screen.dart';

class CommandCenterScreen extends StatefulWidget {
  final String produce;
  final String? tripId;
  const CommandCenterScreen({super.key, required this.produce, this.tripId});

  @override
  State<CommandCenterScreen> createState() => _CommandCenterScreenState();
}

class _CommandCenterScreenState extends State<CommandCenterScreen> {
  // Use Completer for safe async map access
  final Completer<GoogleMapController> _mapCompleter = Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  LatLng? _userLocation;
  bool _locationLoading = true;
  double _freshness = 0.94;
  String _temperature = '28°C';
  Map<String, dynamic>? _selectedMarket;
  final Map<String, Map<String, String>> _weatherCache = {};
  BitmapDescriptor? _marketIcon;
  BitmapDescriptor? _truckIcon;

  static const List<Map<String, dynamic>> _southIndiaMarkets = [
    {'name': 'Koyambedu Market, Chennai', 'lat': 13.0694, 'lon': 80.1948, 'distance': '12 km', 'demand': 'High', 'price': '₹35/kg'},
    {'name': 'Madurai Mango Market', 'lat': 9.9252, 'lon': 78.1198, 'distance': '45 km', 'demand': 'Medium', 'price': '₹30/kg'},
    {'name': 'Ernakulam Market, Kochi', 'lat': 9.9816, 'lon': 76.2999, 'distance': '30 km', 'demand': 'High', 'price': '₹38/kg'},
    {'name': 'Mysore APMC Yard', 'lat': 12.2958, 'lon': 76.6394, 'distance': '55 km', 'demand': 'Low', 'price': '₹28/kg'},
    {'name': 'Vizag Rythu Bazaar', 'lat': 17.6868, 'lon': 83.2185, 'distance': '70 km', 'demand': 'High', 'price': '₹42/kg'},
  ];

  @override
  void initState() {
    super.initState();
    // Defer heavy work to after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createCustomMarkers();
      _getCurrentLocation();
      _fetchAllMarketWeather();
      _fetchTripData();
    });
  }

  @override
  void dispose() {
    // Properly dispose the map controller
    _mapCompleter.future.then((c) => c.dispose());
    super.dispose();
  }

  Future<void> _createCustomMarkers() async {
    _marketIcon = await _createIcon('🏪', Colors.green.shade700);
    _truckIcon = await _createIcon('🚛', Colors.blue.shade700);
    if (mounted) setState(() {});
  }

  Future<BitmapDescriptor> _createIcon(String emoji, Color bgColor) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 100.0;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2, Paint()..color = bgColor);
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 2,
        Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 4);
    final tp = TextPainter(
      text: TextSpan(text: emoji, style: const TextStyle(fontSize: 48)),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, Offset((size - tp.width) / 2, (size - tp.height) / 2));
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List(), width: 48, height: 48);
  }

  Future<void> _fetchAllMarketWeather() async {
    for (final m in _southIndiaMarkets) {
      if (!mounted) return;
      await _fetchWeatherFor(m['name'] as String, m['lat'] as double, m['lon'] as double);
    }
  }

  Future<void> _fetchWeatherFor(String name, double lat, double lon) async {
    try {
      final res = await http.get(Uri.parse('http://10.0.2.127:5000/api/weather?lat=$lat&lon=$lon'))
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200 && mounted) {
        final data = json.decode(res.body);
        setState(() {
          _weatherCache[name] = {
            'temp': data['temp'] as String,
            'desc': data['description'] as String,
            'wind': data['wind'] as String,
            'humidity': '${data['humidity']}%',
          };
        });
        _refreshMarkers();
      }
    } catch (_) {}
  }

  Future<void> _getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { _useFallback(); return; }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) { _useFallback(); return; }
      }
      if (permission == LocationPermission.deniedForever) { _useFallback(); return; }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 0),
      ).timeout(const Duration(seconds: 15), onTimeout: () { throw TimeoutException('timeout'); });
      if (mounted) {
        setState(() { _userLocation = LatLng(position.latitude, position.longitude); _locationLoading = false; });
        _refreshMarkers();
        _animateCameraToUser();
        _fetchWeatherFor('_user', position.latitude, position.longitude);
      }
    } catch (_) {
      try {
        final last = await Geolocator.getLastKnownPosition();
        if (last != null && mounted) {
          setState(() { _userLocation = LatLng(last.latitude, last.longitude); _locationLoading = false; });
          _refreshMarkers();
          return;
        }
      } catch (_) {}
      _useFallback();
    }
  }

  Future<void> _animateCameraToUser() async {
    if (_userLocation == null) return;
    final controller = await _mapCompleter.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: _userLocation!, zoom: 12)));
  }

  void _useFallback() {
    if (mounted) {
      setState(() { _userLocation = const LatLng(13.0827, 80.2707); _locationLoading = false; });
      _refreshMarkers();
    }
  }

  void _refreshMarkers() {
    _markers.clear();
    if (_userLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId('user'), position: _userLocation!,
        icon: _truckIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: '🚛 You are here'),
      ));
    }
    for (int i = 0; i < _southIndiaMarkets.length; i++) {
      final m = _southIndiaMarkets[i];
      final w = _weatherCache[m['name'] as String];
      _markers.add(Marker(
        markerId: MarkerId('market_$i'),
        position: LatLng(m['lat'] as double, m['lon'] as double),
        icon: _marketIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: '🏪 ${m['name']}',
          snippet: w != null ? '${m['price']} • ${w['temp']} ${w['desc']}' : '${m['price']} • ${m['demand']} demand',
        ),
        onTap: () => _selectMarket(m),
      ));
    }
    if (mounted) setState(() {});
  }

  void _selectMarket(Map<String, dynamic> market) {
    setState(() => _selectedMarket = market);
    final name = market['name'] as String;
    if (!_weatherCache.containsKey(name)) {
      _fetchWeatherFor(name, market['lat'] as double, market['lon'] as double);
    }
    _mapCompleter.future.then((c) => c.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(market['lat'] as double, market['lon'] as double), 13)));
  }

  Future<void> _fetchTripData() async {
    if (widget.tripId == null) return;
    try {
      final auth = context.read<AuthProvider>();
      final st = await auth.api.getTripStatus(widget.tripId!);
      final ls = st['live_status'] as Map<String, dynamic>? ?? {};
      final f = (ls['freshness_percentage'] as String? ?? '94%').replaceAll('%', '');
      if (mounted) setState(() {
        _freshness = (double.tryParse(f) ?? 94) / 100;
        _temperature = ls['ambient_temperature'] as String? ?? '28°C';
      });
    } catch (_) {}
  }

  /// Navigate with fade transition to give map engine time to reset
  void _navigateToTransit(Map<String, dynamic> market) {
    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => InTransitScreen(
        produce: widget.produce, tripId: widget.tripId,
        originLat: _userLocation?.latitude ?? 13.0827,
        originLng: _userLocation?.longitude ?? 80.2707,
        destLat: market['lat'] as double, destLng: market['lon'] as double,
        destName: market['name'] as String,
      ),
      transitionDuration: const Duration(milliseconds: 500),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                SizedBox.expand(
                  child: _locationLoading
                      ? Container(color: Colors.grey.shade100,
                          child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            CircularProgressIndicator(color: AppTheme.forestGreen),
                            SizedBox(height: 12),
                            Text('Getting your location...', style: TextStyle(color: AppTheme.textSecondary)),
                          ])))
                      : GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _userLocation ?? const LatLng(13.0827, 80.2707), zoom: 12),
                          mapType: MapType.normal,
                          markers: _markers,
                          trafficEnabled: true,
                          onMapCreated: (c) {
                            if (!_mapCompleter.isCompleted) _mapCompleter.complete(c);
                            _animateCameraToUser();
                          },
                          myLocationEnabled: true,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          compassEnabled: true,
                          rotateGesturesEnabled: true,
                          scrollGesturesEnabled: true,
                          tiltGesturesEnabled: true,
                          zoomGesturesEnabled: true,
                          minMaxZoomPreference: MinMaxZoomPreference.unbounded,
                          onTap: (latLng) {
                            setState(() {
                              _selectedMarket = {
                                'name': 'Custom Location', 'lat': latLng.latitude, 'lon': latLng.longitude,
                                'distance': 'Custom', 'demand': 'Unknown', 'price': 'Market Rate',
                              };
                              _markers.removeWhere((m) => m.markerId.value == 'custom');
                              _markers.add(Marker(
                                markerId: const MarkerId('custom'), position: latLng,
                                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                                infoWindow: const InfoWindow(title: 'Custom Destination'),
                              ));
                            });
                            _fetchWeatherFor('Custom Location', latLng.latitude, latLng.longitude);
                          },
                        ),
                ),
                // Top bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(children: [
                      _circleBtn(Icons.arrow_back_rounded, Colors.black87, () => Navigator.pop(context)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
                        child: Row(children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.forestGreen, shape: BoxShape.circle)),
                          const SizedBox(width: 8),
                          Text(widget.produce, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                          if (_weatherCache.containsKey('_user')) ...[
                            const SizedBox(width: 8),
                            Text(_weatherCache['_user']!['temp']!, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.sunsetOrange, fontSize: 12)),
                          ],
                        ]),
                      ),
                      const SizedBox(width: 8),
                      _circleBtn(Icons.my_location_rounded, AppTheme.infoBlue, _getCurrentLocation),
                    ]),
                  ),
                ),
                if (!_locationLoading)
                  Positioned(left: 16, bottom: 16, child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
                    child: FreshnessGauge(freshness: _freshness, size: 50, strokeWidth: 4),
                  )),
              ],
            ),
          ),
          _selectedMarket != null ? _buildSelectedSheet() : _buildMarketListSheet(),
        ],
      ),
    );
  }

  Widget _circleBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
      child: Icon(icon, size: 20, color: color),
    ));
  }

  Widget _buildMarketListSheet() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))]),
      child: SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 8),
        const Row(children: [
          Icon(Icons.store_mall_directory_rounded, color: AppTheme.forestGreen, size: 18),
          SizedBox(width: 8),
          Text('Select Market Destination', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
        ]),
        const SizedBox(height: 8),
        SizedBox(
          height: 72,
          child: ListView.builder(
            scrollDirection: Axis.horizontal, physics: const BouncingScrollPhysics(),
            itemCount: _southIndiaMarkets.length,
            itemBuilder: (context, i) {
              final m = _southIndiaMarkets[i];
              final w = _weatherCache[m['name'] as String];
              return GestureDetector(
                onTap: () => _selectMarket(m),
                child: Container(
                  width: 175, margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.forestGreen.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.forestGreen.withValues(alpha: 0.12))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(m['name'] as String, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Row(children: [
                      Text(m['price'] as String, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.forestGreen)),
                      const SizedBox(width: 4),
                      Text('• ${m['distance']}', style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                    ]),
                    if (w != null)
                      Text('${w['temp']} • ${w['desc']}', style: const TextStyle(fontSize: 9, color: AppTheme.infoBlue, fontWeight: FontWeight.w600),
                          maxLines: 1, overflow: TextOverflow.ellipsis),
                  ]),
                ),
              );
            },
          ),
        ),
      ])),
    );
  }

  Widget _buildSelectedSheet() {
    final m = _selectedMarket!;
    final w = _weatherCache[m['name'] as String];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: const BoxDecoration(color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))]),
      child: SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
        const SizedBox(height: 8),
        Row(children: [
          Container(padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.store_rounded, color: Colors.white, size: 18)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m['name'] as String, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${m['price']} • ${m['distance']}', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ])),
          GestureDetector(onTap: () => setState(() => _selectedMarket = null),
            child: const Icon(Icons.close_rounded, color: AppTheme.textSecondary, size: 20)),
        ]),
        if (w != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppTheme.infoBlue.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.infoBlue.withValues(alpha: 0.1))),
            child: Row(children: [
              const Icon(Icons.cloud_rounded, color: AppTheme.infoBlue, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text('${w['temp']} • ${w['desc']} • Wind: ${w['wind']} • Humidity: ${w['humidity']}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.infoBlue))),
            ]),
          ),
        ],
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, height: 48, child: ElevatedButton(
          onPressed: () => _navigateToTransit(m),
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.forestGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.navigation_rounded, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text('START TRANSIT TO ${(m['name'] as String).split(',').first.toUpperCase()}',
                style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5, fontSize: 12, color: Colors.white)),
          ]),
        )),
        const SizedBox(height: 4),
        TextButton(onPressed: () => setState(() => _selectedMarket = null),
          child: const Text('Choose Different', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600, fontSize: 12))),
      ])),
    );
  }
}
