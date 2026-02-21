import 'dart:convert';
import 'package:http/http.dart' as http;

/// Centralized HTTP client for the FreshRoute backend API.
/// All protected endpoints automatically include the JWT Bearer token.
class ApiService {
  // Uses localhost — works with physical device via `adb reverse tcp:5000 tcp:5000`
  // For Android emulator, change to http://10.0.2.2:5000/api
  static const String _baseUrl = 'http://localhost:5000/api';

  String? _token;

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ──────────────── Auth ────────────────

  /// POST /api/auth/signup
  Future<Map<String, dynamic>> signup(
      String username, String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/signup'),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(res);
  }

  /// POST /api/auth/login → { token, username, role }
  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return _handleResponse(res);
  }

  // ──────────────── Produce ────────────────

  /// GET /api/produce → { fruits: [...], vegetables: [...] }
  Future<Map<String, dynamic>> getProduceList() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/produce'),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  // ──────────────── Trips ────────────────

  /// POST /api/trips/start → { message, tripId }
  Future<Map<String, dynamic>> startTrip(
      String produceName, double quantity, String startLocation) async {
    final res = await http.post(
      Uri.parse('$_baseUrl/trips/start'),
      headers: _headers,
      body: jsonEncode({
        'produce_name': produceName,
        'quantity': quantity,
        'start_location': startLocation,
      }),
    );
    return _handleResponse(res);
  }

  /// GET /api/trips/status/:id?lat=&lon= → { trip_id, produce, live_status }
  Future<Map<String, dynamic>> getTripStatus(String tripId,
      {double? lat, double? lon}) async {
    final queryParams = <String, String>{};
    if (lat != null) queryParams['lat'] = lat.toString();
    if (lon != null) queryParams['lon'] = lon.toString();

    final uri = Uri.parse('$_baseUrl/trips/status/$tripId')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final res = await http.get(uri, headers: _headers);
    return _handleResponse(res);
  }

  /// GET /api/trips/user → { trips: [...] }
  Future<Map<String, dynamic>> getUserTrips() async {
    final res = await http.get(
      Uri.parse('$_baseUrl/trips/user'),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  // ──────────────── Markets ────────────────

  /// POST /api/markets/seed
  Future<Map<String, dynamic>> seedMarkets() async {
    final res = await http.post(
      Uri.parse('$_baseUrl/markets/seed'),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  /// GET /api/markets/recommend/:tripId → { trip_id, produce, current_freshness, top_recommendation, all_options }
  Future<Map<String, dynamic>> getMarketRecommendation(String tripId) async {
    final res = await http.get(
      Uri.parse('$_baseUrl/markets/recommend/$tripId'),
      headers: _headers,
    );
    return _handleResponse(res);
  }

  // ──────────────── Helpers ────────────────

  Map<String, dynamic> _handleResponse(http.Response res) {
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        statusCode: res.statusCode,
        message: body['message'] ?? body['error'] ?? 'Unknown error',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
