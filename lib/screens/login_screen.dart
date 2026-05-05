import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/otp_service.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  
  bool _isLoading = false;
  bool _isOtpSent = false;
  bool _isCheckingPhone = false;
  String _selectedCountryCode = '+91';
  String _enteredPhoneNumber = '';
  String? _userRole;
  String? _userName;
  String? _userId;
  String? _verificationId;
  int _otpExpirySeconds = 60; // Firebase default timeout
  PhoneNumber? _currentPhoneNumber; // Store the phone number object from IntlPhoneField

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  /// Step 1: Check if phone number exists in database and send OTP via Firebase
  Future<void> _checkPhoneAndSendOtp() async {
    debugPrint('🔵 [LOGIN] Starting OTP send flow...');
    
    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ [LOGIN] Form validation failed');
      return;
    }

    // Validate that we have a complete phone number
    if (_currentPhoneNumber == null || _currentPhoneNumber!.number.isEmpty) {
      debugPrint('❌ [LOGIN] Phone number is empty or invalid');
      _showSnackBar('Please enter a valid phone number', Colors.red);
      return;
    }

    // Use the complete number from IntlPhoneField (includes country code)
    final fullPhoneNumber = _currentPhoneNumber!.completeNumber;
    
    // Additional validation: ensure we have at least 10 digits
    if (_currentPhoneNumber!.number.length < 10) {
      debugPrint('❌ [LOGIN] Phone number too short: ${_currentPhoneNumber!.number.length} digits');
      _showSnackBar('Please enter a valid 10-digit phone number', Colors.red);
      return;
    }

    setState(() {
      _isCheckingPhone = true;
    });

    try {
      debugPrint('📱 [LOGIN] Phone number entered: $fullPhoneNumber');
      debugPrint('📱 [LOGIN] Country code: ${_currentPhoneNumber!.countryCode}');
      debugPrint('📱 [LOGIN] Phone digits: ${_currentPhoneNumber!.number}');
      debugPrint('📱 [LOGIN] Complete number: ${_currentPhoneNumber!.completeNumber}');
      
      // Check if phone exists in database and send OTP via Firebase
      debugPrint('🔄 [LOGIN] Calling OtpService.sendOtpWithFirebase...');
      final verificationId = await OtpService.sendOtpWithFirebase(fullPhoneNumber);
      debugPrint('✅ [LOGIN] OTP sent successfully. Verification ID received: ${verificationId.substring(0, 20)}...');
      
      // Get user info from check (optional, for display)
      try {
        debugPrint('🔄 [LOGIN] Fetching user info from backend...');
        final userInfo = await OtpService.checkPhoneNumber(fullPhoneNumber);
        if (userInfo != null) {
          debugPrint('✅ [LOGIN] User info retrieved:');
          debugPrint('   - Name: ${userInfo['name']}');
          debugPrint('   - Role: ${userInfo['role']}');
          debugPrint('   - User ID: ${userInfo['user_id']}');
          setState(() {
            _userRole = userInfo['role'];
            _userName = userInfo['name'];
            _userId = userInfo['user_id'];
          });
        }
      } catch (e) {
        debugPrint('⚠️ [LOGIN] Could not fetch user info (already validated): $e');
        // User info already validated in sendOtpWithFirebase
      }
      
      setState(() {
        _enteredPhoneNumber = fullPhoneNumber;
        _verificationId = verificationId;
        _isOtpSent = true;
        _otpExpirySeconds = 60; // Firebase timeout
      });
      
      debugPrint('✅ [LOGIN] State updated: OTP sent = true');
      debugPrint('✅ [LOGIN] Verification ID stored: ${verificationId.substring(0, 20)}...');
      
      _showSnackBar('OTP sent to $_enteredPhoneNumber via SMS', Colors.green);
      
    } catch (e, stackTrace) {
      debugPrint('❌ [LOGIN] Error in _checkPhoneAndSendOtp: $e');
      debugPrint('❌ [LOGIN] Stack trace: $stackTrace');
      _showSnackBar(e.toString(), Colors.red);
    } finally {
      setState(() {
        _isCheckingPhone = false;
      });
      debugPrint('🔵 [LOGIN] _checkPhoneAndSendOtp completed');
    }
  }

  /// Step 2: Verify OTP with Firebase and get user data
  Future<void> _verifyOTP() async {
    debugPrint('🔵 [LOGIN] Starting OTP verification...');
    debugPrint('🔢 [LOGIN] OTP entered: ${_otpController.text}');
    debugPrint('📱 [LOGIN] Phone number: $_enteredPhoneNumber');
    debugPrint('🆔 [LOGIN] Verification ID: ${_verificationId?.substring(0, 20) ?? "null"}...');
    
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      debugPrint('❌ [LOGIN] Invalid OTP format: length = ${_otpController.text.length}');
      _showSnackBar('Please enter a valid 6-digit OTP', Colors.red);
      return;
    }

    if (_verificationId == null) {
      debugPrint('❌ [LOGIN] Verification ID is null!');
      _showSnackBar('Verification ID not found. Please request OTP again.', Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Complete OTP flow: Verify with Firebase → Get user from backend
      debugPrint('🔄 [LOGIN] Calling OtpService.completeOtpFlow...');
      final result = await OtpService.completeOtpFlow(
        _enteredPhoneNumber,
        _verificationId!,
        _otpController.text,
      );
      
      debugPrint('📦 [LOGIN] OTP flow result received');
      debugPrint('   - Success: ${result['success']}');
      
      if (result['success'] == true) {
        final userData = result['user_data'] as Map<String, dynamic>;
        final firebaseUser = result['firebase_user'] as User?;
        
        debugPrint('✅ [LOGIN] OTP verification successful!');
        debugPrint('👤 [LOGIN] User data:');
        debugPrint('   - ID: ${userData['id']}');
        debugPrint('   - Name: ${userData['name']}');
        debugPrint('   - Role: ${userData['role']}');
        debugPrint('   - Firebase UID: ${firebaseUser?.uid}');
        debugPrint('   - Firebase Phone: ${firebaseUser?.phoneNumber}');
        
        // Get Firebase ID token for API authentication
        String? firebaseToken;
        if (firebaseUser != null) {
          try {
            debugPrint('🔑 [LOGIN] Getting Firebase ID token...');
            firebaseToken = await firebaseUser.getIdToken();
            if (firebaseToken != null) {
              debugPrint('✅ [LOGIN] Firebase ID token retrieved: ${firebaseToken.substring(0, 20)}...');
            }
          } catch (e) {
            debugPrint('⚠️ [LOGIN] Failed to get Firebase ID token: $e');
          }
        }
        
        // Save user data to SharedPreferences
        debugPrint('💾 [LOGIN] Saving user data to SharedPreferences...');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userId', userData['id'] ?? _userId ?? firebaseUser?.uid ?? '');
        await prefs.setString('userName', userData['name'] ?? _userName ?? '');
        await prefs.setString('userNameHindi', userData['name_hindi'] ?? userData['name'] ?? '');
        await prefs.setString('userRole', userData['role'] ?? _userRole ?? '');
        await prefs.setString('userRoleHindi', userData['role_hindi'] ?? userData['role'] ?? '');
        await prefs.setString('userPhone', _enteredPhoneNumber);
        await prefs.setString('phoneNumber', _enteredPhoneNumber);
        await prefs.setString('firebaseUid', firebaseUser?.uid ?? '');
        if (firebaseToken != null) {
          await prefs.setString('firebaseToken', firebaseToken);
          debugPrint('✅ [LOGIN] Firebase token saved to SharedPreferences');
        }
        debugPrint('✅ [LOGIN] User data saved to SharedPreferences');
        
        // Update auth provider
        debugPrint('🔄 [LOGIN] Updating auth provider...');
        final authNotifier = ref.read(authNotifierProvider.notifier);
        authNotifier.setUser(firebaseUser);
        debugPrint('✅ [LOGIN] Auth provider updated');
        
        _showSnackBar('Login successful!', Colors.green);
        
        // Navigate to main screen
        if (mounted) {
          debugPrint('🚀 [LOGIN] Navigating to main screen...');
          Navigator.of(context).pushReplacementNamed('/main');
          debugPrint('✅ [LOGIN] Navigation completed');
        }
      } else {
        debugPrint('❌ [LOGIN] OTP verification failed: success = false');
        _showSnackBar('OTP verification failed', Colors.red);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [LOGIN] Error in _verifyOTP: $e');
      debugPrint('❌ [LOGIN] Stack trace: $stackTrace');
      _showSnackBar(e.toString(), Colors.red);
    } finally {
      setState(() {
        _isLoading = false;
      });
      debugPrint('🔵 [LOGIN] _verifyOTP completed');
    }
  }

  /// Resend OTP
  Future<void> _resendOTP() async {
    debugPrint('🔄 [LOGIN] Resending OTP...');
    _otpController.clear();
    await _checkPhoneAndSendOtp();
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Header Section
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF8B4513), Color(0xFF8B4513)],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/logo.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Brick Bhatta Management System',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Content Section
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0, -30),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, -2),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Welcome Text
                            Text(
                              _isOtpSent ? 'Enter OTP' : 'Welcome Back',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF333333),
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            Text(
                              _isOtpSent 
                                ? 'Enter the 6-digit OTP sent to $_enteredPhoneNumber'
                                : 'Sign in with your registered phone number',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 20),
                            
                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  if (!_isOtpSent) ...[
                                    // Phone Number Field
                                    const Text(
                                      'फ़ोन नंबर / Phone Number',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    IntlPhoneField(
                                      controller: _phoneController,
                                      decoration: InputDecoration(
                                        hintText: 'Enter your phone number',
                                        hintStyle: const TextStyle(color: Color(0xFF999999)),
                                        prefixIcon: const Icon(
                                          Icons.phone,
                                          color: Color(0xFF999999),
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFFF9800)),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      initialCountryCode: 'IN',
                                      onChanged: (phone) {
                                        setState(() {
                                          _selectedCountryCode = phone.countryCode;
                                          _currentPhoneNumber = phone; // Store the phone object
                                        });
                                        debugPrint('📱 [LOGIN] Phone changed: ${phone.completeNumber}');
                                      },
                                      validator: (phone) {
                                        if (phone == null || phone.number.isEmpty) {
                                          return 'Please enter your phone number';
                                        }
                                        if (phone.number.length < 10) {
                                          return 'Please enter a valid 10-digit phone number';
                                        }
                                        return null;
                                      },
                                    ),
                                  ] else ...[
                                    // OTP Field
                                    const Text(
                                      'OTP / वन टाइम पासवर्ड',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      controller: _otpController,
                                      keyboardType: TextInputType.number,
                                      maxLength: 6,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        letterSpacing: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: '000000',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[300],
                                          fontSize: 24,
                                          letterSpacing: 8,
                                        ),
                                        counterText: '',
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(color: Color(0xFFFF9800)),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    
                                    // Resend OTP button
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Didn't receive OTP? ",
                                          style: TextStyle(
                                            color: Color(0xFF666666),
                                            fontSize: 14,
                                          ),
                                        ),
                                        TextButton(
                                          onPressed: _isLoading ? null : _resendOTP,
                                          child: const Text(
                                            'Resend OTP',
                                            style: TextStyle(
                                              color: Color(0xFFFF9800),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            
                            const Spacer(),
                            
                            // Action Button
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: (_isLoading || _isCheckingPhone) ? null : () {
                                  if (_isOtpSent) {
                                    _verifyOTP();
                                  } else {
                                    _checkPhoneAndSendOtp();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B4513),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 0,
                                ),
                                child: (_isLoading || _isCheckingPhone)
                                    ? const SpinKitThreeBounce(
                                        color: Colors.white,
                                        size: 20,
                                      )
                                    : Text(
                                        _isOtpSent ? 'Verify OTP' : 'Send OTP',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                            
                            if (_isOtpSent) ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isOtpSent = false;
                                    _otpController.clear();
                                    _phoneController.clear();
                                    _enteredPhoneNumber = '';
                                    _verificationId = null;
                                    _currentPhoneNumber = null;
                                  });
                                },
                                child: const Text(
                                  'Change Phone Number',
                                  style: TextStyle(
                                    color: Color(0xFF666666),
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
