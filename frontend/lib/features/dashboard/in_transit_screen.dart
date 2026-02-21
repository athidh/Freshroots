import 'dart:async';
import 'dart:convert' show jsonDecode;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../profile/trip_summary_screen.dart';

// ── Top-level functions for Isolate via compute() ──────────────────────

/// Decodes a Google-encoded polyline string in a background isolate.
/// Returns List<List<double>> because LatLng can't cross isolate boundaries.
List<List<double>> decodePolylineIsolate(String encoded) {
  List<List<double>> points = [];
  int index = 0, lat = 0, lng = 0;
  while (index < encoded.length) {
    int shift = 0, result = 0, b;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
    points.add([lat / 1e5, lng / 1e5]);
  }
  return points;
}

/// Computes the bounding box of a list of points in a background isolate.
/// Returns [south, west, north, east].
List<double> computeBoundsIsolate(List<List<double>> pts) {
  double s = pts.first[0], n = s, w = pts.first[1], e = w;
  for (final p in pts) {
    if (p[0] < s) s = p[0];
    if (p[0] > n) n = p[0];
    if (p[1] < w) w = p[1];
    if (p[1] > e) e = p[1];
  }
  return [s, w, n, e];
}

/// Parses the Directions API JSON response in a background isolate.
/// Returns a Map with 'encoded' polyline, 'eta', 'distance'.
Map<String, String> parseDirectionsJsonIsolate(String responseBody) {
  final data = jsonDecode(responseBody);
  if ((data['routes'] as List).isEmpty) return {};
  final route = data['routes'][0];
  final leg = route['legs'][0];
  return {
    'encoded': route['overview_polyline']['points'] as String,
    'eta': leg['duration']['text'] as String,
    'distance': leg['distance']['text'] as String,
  };
}

/// Parses weather JSON in a background isolate.
Map<String, String> parseWeatherJsonIsolate(String responseBody) {
  final d = jsonDecode(responseBody);
  return {
    'temp': d['temp']?.toString() ?? '',
    'description': d['description']?.toString() ?? '',
  };
}

class InTransitScreen extends StatefulWidget {
  final String produce;
  final String? tripId;
  final double originLat;
  final double originLng;
  final double destLat;
  final double destLng;
  final String destName;

  const InTransitScreen({
    super.key,
    required this.produce,
    this.tripId,
    this.originLat = 13.0827,
    this.originLng = 80.2707,
    this.destLat = 13.0694,
    this.destLng = 80.1948,
    this.destName = 'Koyambedu Market',
  });

  @override
  State<InTransitScreen> createState() => _InTransitScreenState();
}

class _InTransitScreenState extends State<InTransitScreen>
    with TickerProviderStateMixin {
  // Use Completer for safe async map access
  final Completer<GoogleMapController> _mapCompleter = Completer<GoogleMapController>();
  final Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  bool _showWarning = false;
  double _freshness = 0.94;
  String _temperature = '28°C';
  String _spoilageRisk = 'Low';
  String _eta = 'Calculating...';
  String _distanceLeft = '...';
  Timer? _pollTimer;
  Timer? _simTimer;
  double _truckProgress = 0.0;
  late AnimationController _truckController;

  // Speed control
  int _speedMultiplier = 1;
  static const _baseDuration = 300; // 5 minutes

  // Custom icons
  BitmapDescriptor? _truckIcon;
  BitmapDescriptor? _marketIcon;

  // Weather
  String _originWeather = '';
  String _destWeather = '';

  // ── Performance controls ──────────────────────────────────────────
  DateTime _lastCameraUpdate = DateTime(2000);
  DateTime _lastSetState = DateTime(2000);
  bool _userDragging = false;
  LatLng? _latestTruckPos; // Internal tracking (updated every frame)

  @override
  void initState() {
    super.initState();
    _truckController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _baseDuration),
    );
    _truckController.addListener(_onTruckUpdate);

    // Defer all heavy work to after first frame renders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAsync();
    });
  }

  /// All async initialization — called after first frame
  Future<void> _initializeAsync() async {
    // Create marker icons
    await _createCustomMarkers();

    // Setup endpoint markers
    _setupEndpoints();

    // Start parallel async work
    _fetchDirections();
    _fetchWeather();

    // Trip status polling
    if (widget.tripId != null) {
      _fetchTripStatus();
      _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchTripStatus());
    } else {
      _simulateJourney();
    }
  }

  @override
  void dispose() {
    // ── Explicit cleanup of every subscription / timer / controller ──
    _truckController.removeListener(_onTruckUpdate);
    _truckController.dispose();
    _pollTimer?.cancel();
    _simTimer?.cancel();
    // Properly dispose map controller
    if (_mapCompleter.isCompleted) {
      _mapCompleter.future.then((c) => c.dispose());
    }
    super.dispose();
  }

  void _onTruckUpdate() {
    if (!mounted) return;
    _truckProgress = _truckController.value;
    _updateTruckPosition();
  }

  Future<void> _createCustomMarkers() async {
    _truckIcon = await _createIcon('🚛', Colors.blue.shade700);
    _marketIcon = await _createIcon('🏪', Colors.green.shade700);
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

  Future<void> _fetchWeather() async {
    try {
      final oRes = await http.get(Uri.parse(
          'http://10.0.2.127:5000/api/weather?lat=${widget.originLat}&lon=${widget.originLng}'))
          .timeout(const Duration(seconds: 5));
      if (oRes.statusCode == 200 && mounted) {
        final d = await compute(parseWeatherJsonIsolate, oRes.body);
        setState(() => _originWeather = '${d['temp']} ${d['description']}');
      }
    } catch (_) {}
    try {
      final dRes = await http.get(Uri.parse(
          'http://10.0.2.127:5000/api/weather?lat=${widget.destLat}&lon=${widget.destLng}'))
          .timeout(const Duration(seconds: 5));
      if (dRes.statusCode == 200 && mounted) {
        final d = await compute(parseWeatherJsonIsolate, dRes.body);
        setState(() {
          _destWeather = '${d['temp']} ${d['description']}';
          _temperature = d['temp'] ?? '28°C';
        });
      }
    } catch (_) {}
  }

  void _setupEndpoints() {
    _markers.add(Marker(
      markerId: const MarkerId('origin'),
      position: LatLng(widget.originLat, widget.originLng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      infoWindow: const InfoWindow(title: '🚛 Start Point'),
    ));
    _markers.add(Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(widget.destLat, widget.destLng),
      icon: _marketIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(title: '🏪 ${widget.destName}'),
    ));
    if (mounted) setState(() {});
  }

  void _cycleSpeed() {
    setState(() {
      if (_speedMultiplier == 1) _speedMultiplier = 2;
      else if (_speedMultiplier == 2) _speedMultiplier = 5;
      else if (_speedMultiplier == 5) _speedMultiplier = 10;
      else _speedMultiplier = 1;
    });
    final currentProgress = _truckController.value;
    _truckController.stop();
    final remainingFraction = 1.0 - currentProgress;
    final remainingSeconds = (_baseDuration * remainingFraction / _speedMultiplier).toInt().clamp(1, _baseDuration);
    _truckController.duration = Duration(seconds: remainingSeconds);
    _truckController.forward(from: currentProgress);
  }

  Future<void> _fetchDirections() async {
    try {
      final url = 'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${widget.originLat},${widget.originLng}'
          '&destination=${widget.destLat},${widget.destLng}'
          '&key=AIzaSyCZb9hp1XXwVnFm_cWBpHpQzw4J-FQUcOE&mode=driving&traffic_model=best_guess&departure_time=now';
      final res = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        // Parse JSON in background isolate
        final parsed = await compute(parseDirectionsJsonIsolate, res.body);
        if (parsed.isNotEmpty) {
          // Decode polyline in background isolate
          final rawPoints = await compute(decodePolylineIsolate, parsed['encoded']!);
          final decodedPoints = rawPoints.map((p) => LatLng(p[0], p[1])).toList();

          // Build polyline fully before updating state
          final newPolyline = Polyline(
            polylineId: const PolylineId('route'),
            points: decodedPoints,
            color: AppTheme.forestGreen,
            width: 5,
          );

          if (mounted) {
            setState(() {
              _routePoints = decodedPoints;
              _eta = parsed['eta']!;
              _distanceLeft = parsed['distance']!;
              _polylines = {newPolyline};
            });
            // Animate camera after state is set
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (_mapCompleter.isCompleted && _routePoints.isNotEmpty) {
                final controller = await _mapCompleter.future;
                // Compute bounds in background isolate
                final rawBounds = await compute(
                  computeBoundsIsolate,
                  _routePoints.map((p) => [p.latitude, p.longitude]).toList(),
                );
                final bounds = LatLngBounds(
                  southwest: LatLng(rawBounds[0], rawBounds[1]),
                  northeast: LatLng(rawBounds[2], rawBounds[3]),
                );
                controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
              }
              _truckController.forward();
            });
          }
          return;
        }
      }
    } catch (_) {}

    // Fallback
    final fallbackPoints = [LatLng(widget.originLat, widget.originLng), LatLng(widget.destLat, widget.destLng)];
    final fallbackPolyline = Polyline(polylineId: const PolylineId('route'), points: fallbackPoints, color: AppTheme.forestGreen, width: 5);
    if (mounted) {
      setState(() {
        _routePoints = fallbackPoints;
        _eta = '~30 min';
        _distanceLeft = '~20 km';
        _polylines = {fallbackPolyline};
      });
      _truckController.forward();
    }
  }

  void _updateTruckPosition() {
    if (_routePoints.isEmpty || !mounted) return;
    final total = _routePoints.length;
    final exact = _truckProgress * (total - 1);
    final idx = exact.floor().clamp(0, total - 2);
    final t = exact - idx;
    final lat = _routePoints[idx].latitude + (_routePoints[idx + 1].latitude - _routePoints[idx].latitude) * t;
    final lng = _routePoints[idx].longitude + (_routePoints[idx + 1].longitude - _routePoints[idx].longitude) * t;
    final truckPos = LatLng(lat, lng);

    // Always track latest position internally (zero cost, no rebuild)
    _latestTruckPos = truckPos;

    // ── Throttled setState: rebuild UI at most once every 3 seconds ──
    final now = DateTime.now();
    if (now.difference(_lastSetState).inSeconds >= 3) {
      _lastSetState = now;
      _markers.removeWhere((m) => m.markerId.value == 'truck');
      _markers.add(Marker(
        markerId: const MarkerId('truck'),
        position: truckPos,
        icon: _truckIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: '🚛 ${widget.produce}', snippet: '${(_freshness * 100).toInt()}% fresh • ${_speedMultiplier}x'),
      ));
      setState(() {});
    }

    // ── Throttled camera follow (3-second debounce) ──────────────────
    if (_userDragging || !_mapCompleter.isCompleted) return;
    if (now.difference(_lastCameraUpdate).inSeconds >= 3) {
      _lastCameraUpdate = now;
      _mapCompleter.future.then((c) => c.animateCamera(CameraUpdate.newLatLng(truckPos)));
    }
  }

  /// Re-center the camera on the truck and resume auto-follow.
  void _recenterOnTruck() {
    setState(() => _userDragging = false);
    if (_routePoints.isEmpty || !_mapCompleter.isCompleted) return;
    final total = _routePoints.length;
    final exact = _truckProgress * (total - 1);
    final idx = exact.floor().clamp(0, total - 2);
    final t = exact - idx;
    final lat = _routePoints[idx].latitude + (_routePoints[idx + 1].latitude - _routePoints[idx].latitude) * t;
    final lng = _routePoints[idx].longitude + (_routePoints[idx + 1].longitude - _routePoints[idx].longitude) * t;
    _lastCameraUpdate = DateTime.now();
    _mapCompleter.future.then((c) => c.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng))));
  }

  Future<void> _fetchTripStatus() async {
    try {
      final auth = context.read<AuthProvider>();
      final st = await auth.api.getTripStatus(widget.tripId!);
      final ls = st['live_status'] as Map<String, dynamic>? ?? {};
      final f = (ls['freshness_percentage'] as String? ?? '94%').replaceAll('%', '');
      if (mounted) setState(() {
        _freshness = (double.tryParse(f) ?? 94) / 100;
        _temperature = ls['ambient_temperature'] as String? ?? '28°C';
        _spoilageRisk = ls['spoilage_risk'] as String? ?? 'Low';
        if (_spoilageRisk.contains('High')) _showWarning = true;
      });
    } catch (_) {}
  }

  /// Simulation via cancellable Timer — no dangling async loops.
  void _simulateJourney() {
    int tick = 0;
    _simTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) { timer.cancel(); return; }
      tick++;
      if (tick == 2) {
        setState(() { _spoilageRisk = 'Medium'; _showWarning = true; });
      } else if (tick > 2 && tick <= 22) {
        setState(() => _freshness -= 0.005);
      } else if (tick > 22) {
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          // MAP — Expanded fills screen
          Expanded(
            child: Stack(
              children: [
                // ── RepaintBoundary isolates map rendering from UI overlays ──
                RepaintBoundary(
                  child: SizedBox.expand(
                    child: GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng((widget.originLat + widget.destLat) / 2, (widget.originLng + widget.destLng) / 2),
                        zoom: 12),
                      mapType: MapType.normal,
                      markers: _markers,
                      polylines: _polylines,
                      trafficEnabled: true,
                      onMapCreated: (c) {
                        if (!_mapCompleter.isCompleted) _mapCompleter.complete(c);
                      },
                      // ── Drag detection: stop auto-follow when user pans ──
                      onCameraMoveStarted: () {
                        if (!_userDragging) setState(() => _userDragging = true);
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
                    ),
                  ),
                ),

                // Top bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(children: [
                      _pill(Icons.arrow_back_rounded, null, () => Navigator.pop(context)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24),
                          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
                        child: Row(children: [
                          Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          const Text('LIVE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.red)),
                          const SizedBox(width: 8),
                          Text(widget.produce, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                          const SizedBox(width: 8),
                          Text(_temperature, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.sunsetOrange, fontSize: 11)),
                        ]),
                      ),
                    ]),
                  ),
                ),

                // Re-center button (visible when user is manually dragging)
                if (_userDragging)
                  Positioned(right: 16, bottom: 60, child: GestureDetector(
                    onTap: _recenterOnTruck,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.forestGreen,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
                      child: const Icon(Icons.my_location_rounded, size: 20, color: Colors.white),
                    ),
                  )),

                // Speed button (floating bottom-right)
                Positioned(right: 16, bottom: 16, child: GestureDetector(
                  onTap: _cycleSpeed,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _speedMultiplier > 1 ? AppTheme.sunsetOrange : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.fast_forward_rounded, size: 18,
                          color: _speedMultiplier > 1 ? Colors.white : Colors.black87),
                      const SizedBox(width: 4),
                      Text('${_speedMultiplier}x', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13,
                          color: _speedMultiplier > 1 ? Colors.white : Colors.black87)),
                    ]),
                  ),
                )),

                // Warning
                if (_showWarning)
                  Positioned(top: MediaQuery.of(context).padding.top + 56, left: 16, right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(color: AppTheme.warningAmber, borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text('🌡️ $_temperature • Risk: ${_spoilageRisk.toUpperCase()}',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))),
                        GestureDetector(onTap: () => setState(() => _showWarning = false),
                            child: const Icon(Icons.close, color: Colors.white70, size: 16)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),

          // BOTTOM PANEL
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            decoration: const BoxDecoration(color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))]),
            child: SafeArea(top: false, child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppTheme.forestGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.local_shipping_rounded, color: AppTheme.forestGreen, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(widget.destName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${l.eta}: $_eta • $_distanceLeft', style: const TextStyle(fontSize: 12, color: AppTheme.forestGreen, fontWeight: FontWeight.w600)),
                ])),
              ]),
              if (_destWeather.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: AppTheme.infoBlue.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.cloud, color: AppTheme.infoBlue, size: 14),
                    const SizedBox(width: 6),
                    if (_originWeather.isNotEmpty) Text('${l.weather_start}: $_originWeather', style: const TextStyle(fontSize: 10, color: AppTheme.infoBlue)),
                    if (_originWeather.isNotEmpty) const Text(' → ', style: TextStyle(fontSize: 10, color: AppTheme.infoBlue)),
                    Expanded(child: Text('${l.weather_dest}: $_destWeather', style: const TextStyle(fontSize: 10, color: AppTheme.infoBlue, fontWeight: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              ],
              const SizedBox(height: 6),
              Row(children: [
                Expanded(child: _stat('🌡️', _temperature)),
                const SizedBox(width: 8),
                Expanded(child: _stat('🥬', '${(_freshness * 100).toInt()}%')),
                const SizedBox(width: 8),
                Expanded(child: _stat(_spoilageRisk == 'Low' ? '🟢' : '🟡', _spoilageRisk.toUpperCase())),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: SizedBox(height: 44, child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(l.sos, style: const TextStyle(fontWeight: FontWeight.w800)),
                ))),
                const SizedBox(width: 10),
                Expanded(flex: 2, child: SizedBox(height: 44, child: ElevatedButton(
                  onPressed: () => Navigator.pushReplacement(context, PageRouteBuilder(
                    pageBuilder: (_, __, ___) => TripSummaryScreen(produce: widget.produce, freshness: _freshness),
                    transitionDuration: const Duration(milliseconds: 400),
                    transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
                  )),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.forestGreen,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: Text(l.arrived, style: const TextStyle(fontWeight: FontWeight.w800, color: Colors.white, fontSize: 14)),
                ))),
              ]),
            ])),
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, Color? color, VoidCallback onTap) {
    return GestureDetector(onTap: onTap, child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
      child: Icon(icon, size: 20, color: color ?? Colors.black87),
    ));
  }

  Widget _stat(String emoji, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
      ]),
    );
  }
}
