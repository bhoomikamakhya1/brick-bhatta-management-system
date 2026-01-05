import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/sale_model.dart';

/// Service for sending SMS messages
/// Currently supports backend API integration and mock mode for development
class SmsService {
  // Enable/disable SMS sending (set to false for development/testing)
  static const bool _isEnabled = true;
  
  // Use backend API for SMS (set to false to use mock mode)
  static const bool _useBackendApi = true;

  /// Send SMS with sale confirmation details to customer
  /// Returns true if SMS was sent successfully, false otherwise
  static Future<bool> sendSaleConfirmationSms(SaleEntry sale) async {
    if (!_isEnabled) {
      print('📱 SMS service is disabled');
      return false;
    }

    if (sale.customerPhone == null || sale.customerPhone!.isEmpty) {
      print('📱 No phone number provided for customer: ${sale.customerName}');
      return false;
    }

    try {
      final message = _formatSaleMessage(sale);
      
      if (_useBackendApi) {
        return await _sendViaBackendApi(sale.customerPhone!, message);
      } else {
        // Mock mode - just log the message
        print('📱 [MOCK SMS] To: ${sale.customerPhone}');
        print('📱 [MOCK SMS] Message: $message');
        return true;
      }
    } catch (e) {
      print('❌ Error sending SMS: $e');
      return false;
    }
  }

  /// Format the sale confirmation message
  static String _formatSaleMessage(SaleEntry sale) {
    final buffer = StringBuffer();
    
    // Header
    buffer.writeln('Your order has been confirmed!');
    buffer.writeln('OTP: ${sale.otp ?? "N/A"}');
    buffer.writeln('');
    
    // Brick details
    buffer.writeln('Total Bricks: ${sale.brickEntries.fold(0.0, (sum, e) => sum + e.quantity).toStringAsFixed(0)}');
    buffer.writeln('');
    buffer.writeln('Brick Details:');
    for (var entry in sale.brickEntries) {
      buffer.writeln('• ${entry.brickType}: ${entry.quantity.toStringAsFixed(0)} bricks @ ₹${entry.price.toStringAsFixed(2)}');
    }
    buffer.writeln('');
    
    // Freight details (if applicable)
    if (sale.freightDetails != null && sale.freightDetails!.type == 'sending') {
      if (sale.freightDetails!.driverName != null) {
        buffer.writeln('Driver: ${sale.freightDetails!.driverName}');
        if (sale.freightDetails!.driverPhone != null) {
          buffer.writeln('Driver Phone: ${sale.freightDetails!.driverPhone}');
        }
      }
      if (sale.freightDetails!.vehicleName != null) {
        buffer.writeln('Vehicle: ${sale.freightDetails!.vehicleName}');
      }
      if (sale.freightDetails!.vehicleNumber != null) {
        buffer.writeln('Vehicle No: ${sale.freightDetails!.vehicleNumber}');
      }
      buffer.writeln('');
    } else if (sale.freightDetails != null && sale.freightDetails!.type == 'self') {
      if (sale.freightDetails!.vehicleNumber != null) {
        buffer.writeln('Vehicle No: ${sale.freightDetails!.vehicleNumber}');
        buffer.writeln('');
      }
    }
    
    // Amount details
    buffer.writeln('Bricks Total: ₹${sale.totalAmount.toStringAsFixed(2)}');
    if (sale.advancePayment > 0) {
      buffer.writeln('Advance Paid: ₹${sale.advancePayment.toStringAsFixed(2)}');
    }
    buffer.writeln('Final Amount: ₹${sale.finalAmount.toStringAsFixed(2)}');
    
    return buffer.toString();
  }

  /// Send SMS via backend API
  static Future<bool> _sendViaBackendApi(String phoneNumber, String message) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/api/sms/send');
      
      final requestBody = {
        'phoneNumber': phoneNumber,
        'message': message,
      };

      final headers = await ApiConfig.headers;
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏰ SMS send timeout');
          throw Exception('SMS send timeout');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ SMS sent successfully to $phoneNumber');
        return true;
      } else {
        print('❌ Failed to send SMS: ${response.statusCode} - ${response.body}');
        // Fallback to mock mode if backend is not available
        print('📱 Falling back to mock mode...');
        print('📱 [MOCK SMS] To: $phoneNumber');
        print('📱 [MOCK SMS] Message: $message');
        return false;
      }
    } catch (e) {
      print('❌ Error sending SMS via API: $e');
      // Fallback to mock mode
      print('📱 Falling back to mock mode...');
      print('📱 [MOCK SMS] To: $phoneNumber');
      print('📱 [MOCK SMS] Message: $message');
      return false;
    }
  }

  /// Send a simple SMS message (generic method)
  static Future<bool> sendSms(String phoneNumber, String message) async {
    if (!_isEnabled) {
      print('📱 SMS service is disabled');
      return false;
    }

    if (phoneNumber.isEmpty) {
      print('📱 No phone number provided');
      return false;
    }

    try {
      if (_useBackendApi) {
        return await _sendViaBackendApi(phoneNumber, message);
      } else {
        // Mock mode
        print('📱 [MOCK SMS] To: $phoneNumber');
        print('📱 [MOCK SMS] Message: $message');
        return true;
      }
    } catch (e) {
      print('❌ Error sending SMS: $e');
      return false;
    }
  }
}

