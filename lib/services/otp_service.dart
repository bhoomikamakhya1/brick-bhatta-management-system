import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

/// Service for OTP-based authentication using Firebase Phone Auth
class OtpService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if a phone number exists in the database
  /// This ensures only admin-created users can log in
  static Future<Map<String, dynamic>?> checkPhoneNumber(String phoneNumber) async {
    debugPrint('🔵 [OTP_SERVICE] checkPhoneNumber called for: $phoneNumber');
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/otp/check-phone');
      debugPrint('🌐 [OTP_SERVICE] API URL: $url');
      debugPrint('🌐 [OTP_SERVICE] Base URL: ${ApiConfig.baseUrl}');
      debugPrint('📤 [OTP_SERVICE] Sending POST request to check phone number...');
      final headers = await ApiConfig.headers;
      debugPrint('📤 [OTP_SERVICE] Headers: $headers');
      debugPrint('📤 [OTP_SERVICE] Body: {"phone_number": "$phoneNumber"}');
      
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ [OTP_SERVICE] Request timeout after 30 seconds');
          debugPrint('❌ [OTP_SERVICE] Backend server is not responding!');
          debugPrint('❌ [OTP_SERVICE] Please ensure the backend is running at: ${ApiConfig.baseUrl}');
          debugPrint('❌ [OTP_SERVICE] For Android Emulator, use: http://10.0.2.2:8000');
          debugPrint('❌ [OTP_SERVICE] For physical device, use your computer\'s IP address');
          throw Exception('Backend server is not responding. Please ensure the server is running at ${ApiConfig.baseUrl}');
        },
      );

      debugPrint('📥 [OTP_SERVICE] Response received:');
      debugPrint('   - Status code: ${response.statusCode}');
      debugPrint('   - Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('✅ [OTP_SERVICE] Phone number found in database');
        return data;
      } else if (response.statusCode == 404) {
        final error = jsonDecode(response.body);
        debugPrint('❌ [OTP_SERVICE] Phone number not found (404)');
        throw Exception(error['detail'] ?? 'Phone number not registered');
      } else if (response.statusCode == 403) {
        final error = jsonDecode(response.body);
        debugPrint('❌ [OTP_SERVICE] Account inactive (403)');
        throw Exception(error['detail'] ?? 'Account is inactive');
      } else {
        final error = jsonDecode(response.body);
        debugPrint('❌ [OTP_SERVICE] Failed to check phone number: ${response.statusCode}');
        throw Exception(error['detail'] ?? 'Failed to check phone number');
      }
    } on SocketException catch (e) {
      debugPrint('❌ [OTP_SERVICE] Connection error (SocketException): $e');
      debugPrint('❌ [OTP_SERVICE] Backend server is not running or not accessible!');
      debugPrint('❌ [OTP_SERVICE] Please start the backend server:');
      debugPrint('   1. Navigate to backend folder: cd backend');
      debugPrint('   2. Start with Docker: docker compose up -d');
      debugPrint('   3. Or start locally: uvicorn app.main:app --reload');
      throw Exception('Cannot connect to backend server. Please ensure the server is running at ${ApiConfig.baseUrl}');
    } catch (e, stackTrace) {
      debugPrint('❌ [OTP_SERVICE] Error in checkPhoneNumber: $e');
      debugPrint('❌ [OTP_SERVICE] Error type: ${e.runtimeType}');
      debugPrint('❌ [OTP_SERVICE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Send OTP using Firebase Phone Authentication
  /// First checks if phone exists in database, then uses Firebase to send OTP
  static Future<String> sendOtpWithFirebase(String phoneNumber) async {
    debugPrint('🔵 [OTP_SERVICE] sendOtpWithFirebase called for: $phoneNumber');
    
    // Step 1: Check if phone number exists in database
    debugPrint('📋 [OTP_SERVICE] Step 1: Checking if phone exists in database...');
    await checkPhoneNumber(phoneNumber);
    debugPrint('✅ [OTP_SERVICE] Phone number validated in database');
    
    // Step 2: Use Firebase Phone Auth to send OTP
    debugPrint('🔥 [OTP_SERVICE] Step 2: Calling Firebase verifyPhoneNumber...');
    final completer = Completer<String>();
    Exception? verificationError;
    
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint('✅ [OTP_SERVICE] Firebase auto-verification completed');
        // Auto-verification (if SMS is auto-retrieved)
        // This is handled automatically by Firebase
        // In this case, we can sign in directly, but we still need verificationId
        // For manual OTP entry, we'll wait for codeSent
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint('❌ [OTP_SERVICE] Firebase verification failed:');
        debugPrint('   - Code: ${e.code}');
        debugPrint('   - Message: ${e.message}');
        debugPrint('   - Details: ${e.toString()}');
        verificationError = Exception('Firebase verification failed: ${e.message}');
        if (!completer.isCompleted) {
          completer.completeError(verificationError!);
        }
      },
      codeSent: (String verId, int? resendToken) {
        debugPrint('✅ [OTP_SERVICE] Firebase codeSent callback triggered');
        debugPrint('   - Verification ID: ${verId.substring(0, 20)}...');
        debugPrint('   - Resend token: ${resendToken != null ? "available" : "null"}');
        // OTP has been sent, return the verification ID
        if (!completer.isCompleted) {
          completer.complete(verId);
        }
      },
      codeAutoRetrievalTimeout: (String verId) {
        debugPrint('⏱️ [OTP_SERVICE] Firebase auto-retrieval timeout');
        debugPrint('   - Verification ID: ${verId.substring(0, 20)}...');
        // Auto-retrieval timeout - use this as fallback
        if (!completer.isCompleted) {
          completer.complete(verId);
        }
      },
      timeout: const Duration(seconds: 60),
    );
    
    debugPrint('⏳ [OTP_SERVICE] Waiting for verification ID from Firebase...');
    // Wait for the verification ID from the callback
    try {
      final verificationId = await completer.future.timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint('⏱️ [OTP_SERVICE] Timeout waiting for verification ID');
          throw Exception('OTP sending timeout. Please try again.');
        },
      );
      debugPrint('✅ [OTP_SERVICE] Verification ID received: ${verificationId.substring(0, 20)}...');
      return verificationId;
    } catch (e) {
      if (verificationError != null) {
        debugPrint('❌ [OTP_SERVICE] Throwing verification error: $verificationError');
        throw verificationError!;
      }
      debugPrint('❌ [OTP_SERVICE] Error in sendOtpWithFirebase: $e');
      rethrow;
    }
  }

  /// Verify OTP using Firebase Phone Authentication
  static Future<UserCredential> verifyOtpWithFirebase(
    String verificationId,
    String otpCode,
  ) async {
    debugPrint('🔵 [OTP_SERVICE] verifyOtpWithFirebase called');
    debugPrint('   - Verification ID: ${verificationId.substring(0, 20)}...');
    debugPrint('   - OTP Code: $otpCode');
    
    try {
      debugPrint('🔐 [OTP_SERVICE] Creating PhoneAuthCredential...');
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );
      debugPrint('✅ [OTP_SERVICE] Credential created');

      debugPrint('🔄 [OTP_SERVICE] Signing in with credential...');
      final userCredential = await _auth.signInWithCredential(credential);
      debugPrint('✅ [OTP_SERVICE] Sign in successful');
      debugPrint('   - User UID: ${userCredential.user?.uid}');
      debugPrint('   - Phone: ${userCredential.user?.phoneNumber}');
      debugPrint('   - Email: ${userCredential.user?.email ?? "N/A"}');
      return userCredential;
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ [OTP_SERVICE] FirebaseAuthException:');
      debugPrint('   - Code: ${e.code}');
      debugPrint('   - Message: ${e.message}');
      debugPrint('   - Details: ${e.toString()}');
      
      if (e.code == 'invalid-verification-code') {
        debugPrint('❌ [OTP_SERVICE] Invalid OTP code');
        throw Exception('Invalid OTP code. Please try again.');
      } else if (e.code == 'session-expired') {
        debugPrint('❌ [OTP_SERVICE] OTP session expired');
        throw Exception('OTP session expired. Please request a new OTP.');
      } else {
        debugPrint('❌ [OTP_SERVICE] Other Firebase auth error');
        throw Exception('OTP verification failed: ${e.message}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [OTP_SERVICE] Error in verifyOtpWithFirebase: $e');
      debugPrint('❌ [OTP_SERVICE] Stack trace: $stackTrace');
      throw Exception('OTP verification failed: $e');
    }
  }

  /// Get user details from backend after Firebase authentication
  static Future<Map<String, dynamic>> getUserFromBackend(String phoneNumber) async {
    debugPrint('🔵 [OTP_SERVICE] getUserFromBackend called for: $phoneNumber');
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/otp/get-user-by-phone');
      debugPrint('🌐 [OTP_SERVICE] API URL: $url');
      debugPrint('📤 [OTP_SERVICE] Sending POST request to get user details...');
      
      final headers = await ApiConfig.headers;
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'phone_number': phoneNumber,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('⏱️ [OTP_SERVICE] Request timeout after 30 seconds');
          throw Exception('Request timeout');
        },
      );

      debugPrint('📥 [OTP_SERVICE] Response received:');
      debugPrint('   - Status code: ${response.statusCode}');
      debugPrint('   - Body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}');

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        debugPrint('✅ [OTP_SERVICE] User data retrieved successfully');
        debugPrint('   - User ID: ${userData['id']}');
        debugPrint('   - Name: ${userData['name']}');
        debugPrint('   - Role: ${userData['role']}');
        return userData;
      } else {
        final error = jsonDecode(response.body);
        debugPrint('❌ [OTP_SERVICE] Failed to get user details: ${response.statusCode}');
        throw Exception(error['detail'] ?? 'Failed to get user details');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [OTP_SERVICE] Error in getUserFromBackend: $e');
      debugPrint('❌ [OTP_SERVICE] Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Complete OTP flow: Check phone → Send OTP → Verify OTP → Get user
  static Future<Map<String, dynamic>> completeOtpFlow(
    String phoneNumber,
    String verificationId,
    String otpCode,
  ) async {
    debugPrint('🔵 [OTP_SERVICE] completeOtpFlow called');
    debugPrint('   - Phone: $phoneNumber');
    debugPrint('   - Verification ID: ${verificationId.substring(0, 20)}...');
    debugPrint('   - OTP Code: $otpCode');
    
    try {
      // Step 1: Verify OTP with Firebase
      debugPrint('🔄 [OTP_SERVICE] Step 1: Verifying OTP with Firebase...');
      final userCredential = await verifyOtpWithFirebase(verificationId, otpCode);
      debugPrint('✅ [OTP_SERVICE] Step 1 completed: OTP verified');
      
      // Step 2: Get user details from backend database
      debugPrint('🔄 [OTP_SERVICE] Step 2: Getting user details from backend...');
      final userData = await getUserFromBackend(phoneNumber);
      debugPrint('✅ [OTP_SERVICE] Step 2 completed: User data retrieved');
      
      debugPrint('✅ [OTP_SERVICE] completeOtpFlow completed successfully');
      return {
        'success': true,
        'firebase_user': userCredential.user,
        'user_data': userData,
      };
    } catch (e, stackTrace) {
      debugPrint('❌ [OTP_SERVICE] Error in completeOtpFlow: $e');
      debugPrint('❌ [OTP_SERVICE] Stack trace: $stackTrace');
      rethrow;
    }
  }
}
