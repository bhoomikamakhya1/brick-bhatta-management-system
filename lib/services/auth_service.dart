import 'package:firebase_auth/firebase_auth.dart';
// Google sign-in temporarily disabled for development
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with phone number
  Future<void> signInWithPhoneNumber(String phoneNumber) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          throw Exception('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Store verification ID for later use
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('verificationId', verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      throw Exception('Phone authentication failed: $e');
    }
  }

  // Verify OTP
  Future<UserCredential?> verifyOTP(String otp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final verificationId = prefs.getString('verificationId');
      
      if (verificationId == null) {
        throw Exception('No verification ID found');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      
      // Save authentication state
      await prefs.setBool('isAuthenticated', true);
      await prefs.setString('userId', userCredential.user?.uid ?? '');
      
      return userCredential;
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  // Sign in with Google (disabled)
  // Future<UserCredential?> signInWithGoogle() async {
  //   throw Exception('Google sign-in is disabled in development mode');
  // }

  // Sign out
  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        // _googleSignIn.signOut(),
      ]);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isAuthenticated', false);
      await prefs.remove('userId');
      await prefs.remove('verificationId');
      await prefs.remove('userName');
      await prefs.remove('userRole');
      await prefs.remove('phoneNumber');
      await prefs.remove('firebaseUid');
      await prefs.remove('firebaseToken'); // Clear Firebase token
    } catch (e) {
      throw Exception('Sign out failed: $e');
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAuthenticated') ?? false;
  }

  // Get stored user ID
  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Get stored phone number
  Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('phoneNumber');
  }

  // Get stored user role
  Future<Map<String, String?>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('userId'),
      'userName': prefs.getString('userName'),
      'userRole': prefs.getString('userRole'),
      'phoneNumber': prefs.getString('phoneNumber'),
      'firebaseUid': prefs.getString('firebaseUid'),
    };
  }
}
