import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/name_model.dart';
import '../config/api_config.dart';

class ApiService {

  /// Send a new name to the FastAPI backend
  static Future<Map<String, dynamic>?> sendName(NameModel name) async {
    try {
      final url = Uri.parse(ApiConfig.namesUrl);
      final response = await http.post(
        url, 
        headers: ApiConfig.headers, 
        body: jsonEncode(name.toJson())
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ Send name timeout - service may be sleeping');
          throw Exception('Request timeout - service may be sleeping');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData;
      } else {
        print('❌ Failed to send name: ${response.statusCode} - ${response.body}');
        print('📤 Sent data: ${jsonEncode(name.toJson())}');
        return null;
      }
    } catch (e) {
      print('❌ Error sending name: $e');
      return null;
    }
  }

  /// Fetch all names from the FastAPI backend
  static Future<List<NameModel>> fetchNames() async {
    try {
      final url = Uri.parse(ApiConfig.namesUrl);
      final response = await http.get(url, headers: ApiConfig.headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ Fetch names timeout - service may be sleeping');
          throw Exception('Request timeout - service may be sleeping');
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => NameModel.fromJson(json)).toList();
      } else {
        print('❌ Failed to fetch names: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching names: $e');
      return [];
    }
  }

  /// Update an existing name on the backend
  static Future<bool> updateName(NameModel name) async {
    if (name.serverId == null) return false;
    
    try {
      final url = Uri.parse(ApiConfig.getNameUrl(name.serverId!));
      final response = await http.put(
        url, 
        headers: ApiConfig.headers, 
        body: jsonEncode(name.toJson())
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error updating name: $e');
      return false;
    }
  }

  /// Delete a name from the backend
  static Future<bool> deleteName(String serverId) async {
    try {
      final url = Uri.parse(ApiConfig.getNameUrl(serverId));
      final response = await http.delete(url, headers: ApiConfig.headers);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Error deleting name: $e');
      return false;
    }
  }

  /// Test connection to the backend
  static Future<bool> testConnection() async {
    try {
      final url = Uri.parse(ApiConfig.healthUrl);
      final response = await http.get(url, headers: ApiConfig.headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ Health check timeout after 30 seconds');
          throw Exception('Request timeout - service may be sleeping');
        },
      );
      print('🔍 Health check: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  /// Test the names endpoint with a simple GET request
  static Future<void> testNamesEndpoint() async {
    try {
      final url = Uri.parse(ApiConfig.namesUrl);
      final response = await http.get(url, headers: ApiConfig.headers).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ Names endpoint timeout - service may be sleeping');
          throw Exception('Request timeout - service may be sleeping');
        },
      );
      print('🔍 Names endpoint test: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('❌ Names endpoint test failed: $e');
    }
  }

  /// Wake up the Render.com service (useful for free tier services that sleep)
  static Future<bool> wakeUpService() async {
    try {
      print('🌅 Attempting to wake up the service...');
      
      // Try health endpoint first
      final healthUrl = Uri.parse(ApiConfig.healthUrl);
      final healthResponse = await http.get(healthUrl, headers: ApiConfig.headers).timeout(
        const Duration(seconds: 60), // Longer timeout for wake-up
        onTimeout: () {
          print('⏰ Health wake-up timeout');
          throw Exception('Health wake-up timeout');
        },
      );
      
      if (healthResponse.statusCode == 200) {
        print('✅ Service is awake (health check)');
        return true;
      }
      
      // If health fails, try names endpoint
      final namesUrl = Uri.parse(ApiConfig.namesUrl);
      final namesResponse = await http.get(namesUrl, headers: ApiConfig.headers).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          print('⏰ Names wake-up timeout');
          throw Exception('Names wake-up timeout');
        },
      );
      
      print('🔍 Wake-up response: ${namesResponse.statusCode}');
      return namesResponse.statusCode == 200;
      
    } catch (e) {
      print('❌ Service wake-up failed: $e');
      return false;
    }
  }
}
