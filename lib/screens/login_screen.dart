import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wc_salary/providers/auth_provider.dart';
import 'package:wc_salary/providers/toilet_session_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await Provider.of<AuthProvider>(context, listen: false).signInWithGoogle();

      if (user != null && mounted) {
        final toiletProvider = Provider.of<ToiletSessionProvider>(context, listen: false);
        await toiletProvider.syncLocalSessionsToServer();
        await toiletProvider.fetchSessions();
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign in failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithApple() async {
    if (!kIsWeb && !Platform.isIOS) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Apple sign in is only available on iOS and Web')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await Provider.of<AuthProvider>(context, listen: false).signInWithApple();

      if (user != null && mounted) {
        final toiletProvider = Provider.of<ToiletSessionProvider>(context, listen: false);
        await toiletProvider.syncLocalSessionsToServer();
        await toiletProvider.fetchSessions();
        Navigator.of(context).pop();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Apple sign in failed')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sign in to save your toilet sessions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: _signInWithGoogle,
                    icon: Image.asset(
                      'assets/images/google_logo.png',
                      height: 24,
                    ),
                    label: const Text('Sign in with Google'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 15),
                  if (kIsWeb || Platform.isIOS)
                    ElevatedButton.icon(
                      onPressed: _signInWithApple,
                      icon: const Icon(Icons.apple),
                      label: const Text('Sign in with Apple'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
