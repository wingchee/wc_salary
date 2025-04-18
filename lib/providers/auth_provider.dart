import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isInitializing = true;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isInitializing => _isInitializing;

  AuthProvider() {
    // Listen to authentication state changes
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      _isInitializing = false;
      notifyListeners();
    });
  }

  // Sign in with Google
  Future<User?> signInWithGoogle() async {
    try {
      // Web implementation
      if (kIsWeb) {
        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
        return userCredential.user;
      }
      // Mobile implementation
      else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return null;

        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(credential);
        return userCredential.user;
      }
    } catch (e) {
      debugPrint('Google sign in error: $e');
      return null;
    }
  }

  // Sign in with Apple (iOS only)
  Future<User?> signInWithApple() async {
    // Web implementation
    if (kIsWeb) {
      try {
        OAuthProvider oAuthProvider = OAuthProvider('apple.com');
        final UserCredential userCredential = await _auth.signInWithPopup(oAuthProvider);
        return userCredential.user;
      } catch (e) {
        debugPrint('Apple sign in error (web): $e');
        return null;
      }
    }
    // iOS implementation
    else if (Platform.isIOS) {
      try {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        final oauthCredential = OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );

        final UserCredential userCredential = await _auth.signInWithCredential(oauthCredential);
        return userCredential.user;
      } catch (e) {
        debugPrint('Apple sign in error (iOS): $e');
        return null;
      }
    }
    return null;
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    if (!kIsWeb && await GoogleSignIn().isSignedIn()) {
      await GoogleSignIn().signOut();
    }
  }
}
