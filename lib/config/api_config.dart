import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ApiConfig {
  // Update these with your actual FastAPI backend credentials
  // --- Dynamic Base URL Configuration ---
  
  // 1. Development URL (Local Network)
  // This is used when running in Debug or Profile mode (flutter run)
  static const String _devUrl = "http://192.168.1.196:8000";

  // 2. Production URL (AWS/Cloud)
  // This is used when building for Release (flutter build apk)
  // You can override this at build time using: --dart-define=BASE_URL=http://...
  static const String _prodUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: "http://15.207.111.174:8000",
   );

  // Dynamic Base URL getter
  static String get baseUrl {
    if (kReleaseMode) {
      return _prodUrl;
    }
    return _devUrl;
  }
  static const String apiKey = "brick_bhatta_123"; 
  static const String tenantId = "kiln-001"; 
  
  // API Headers - includes Firebase token if available
  static Future<Map<String, String>> get headers async {
    final headers = <String, String>{
    'Content-Type': 'application/json',
    'X-API-KEY': apiKey,
    'X-Tenant-ID': tenantId,
  };
  
    // Add Firebase ID token if available
    try {
      // First try to get fresh token from Firebase Auth
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          final token = await user.getIdToken();
          if (token != null && token.isNotEmpty) {
            headers['Authorization'] = 'Bearer $token';
            print('✅ [API_CONFIG] Got fresh Firebase token: ${token.substring(0, 20)}...');
          } else {
            throw Exception('Token is null or empty');
          }
        } catch (e) {
          print('⚠️ [API_CONFIG] Failed to get fresh token: $e');
          // If getting fresh token fails, try stored token
          final prefs = await SharedPreferences.getInstance();
          final storedToken = prefs.getString('firebaseToken');
          if (storedToken != null && storedToken.isNotEmpty) {
            headers['Authorization'] = 'Bearer $storedToken';
            print('✅ [API_CONFIG] Using stored Firebase token: ${storedToken.substring(0, 20)}...');
          } else {
            print('⚠️ [API_CONFIG] No stored token available');
          }
        }
      } else {
        print('⚠️ [API_CONFIG] No current Firebase user');
        // Fallback to stored token if no current user
        final prefs = await SharedPreferences.getInstance();
        final storedToken = prefs.getString('firebaseToken');
        if (storedToken != null && storedToken.isNotEmpty) {
          headers['Authorization'] = 'Bearer $storedToken';
          print('✅ [API_CONFIG] Using stored Firebase token (no current user): ${storedToken.substring(0, 20)}...');
        } else {
          print('⚠️ [API_CONFIG] No stored token available (no current user)');
        }
      }
    } catch (e) {
      // If all fails, continue without auth header (will get 401, but won't crash)
      print('⚠️ [API_CONFIG] Could not get Firebase token: $e');
    }
    
    return headers;
  }
  
  // API Endpoints (with trailing slashes to avoid 307 redirects)
  static const String namesEndpoint = '/names/'; // Trailing slash to avoid FastAPI redirects
  static const String usersEndpoint = '/users/';
  static const String salesEndpoint = '/sales/';
  static const String workEndpoint = '/work/';
  static const String transactionsEndpoint = '/transactions/';
  static const String healthEndpoint = '/health'; // No trailing slash for health endpoint
  
  // Full URLs
  static String get namesUrl => '$baseUrl$namesEndpoint';
  static String get usersUrl => '$baseUrl$usersEndpoint';
  static String get salesUrl => '$baseUrl$salesEndpoint';
  static String get workUrl => '$baseUrl$workEndpoint';
  static String get transactionsUrl => '$baseUrl$transactionsEndpoint';
  static String get healthUrl => '$baseUrl$healthEndpoint';
  
  // Helper methods
  static String getNameUrl(String id) => '$namesUrl/$id';
  static String getUserUrl(String id) => '$usersUrl/$id';
  static String getSaleUrl(String id) => '$salesUrl/$id';
  static String getWorkUrl(String id) => '$workUrl/$id';
  static String getTransactionUrl(String id) => '$transactionsUrl/$id';
}
