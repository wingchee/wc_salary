import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wc_salary/providers/toilet_session_provider.dart';
import 'package:wc_salary/screens/home_screen.dart';
import 'package:wc_salary/screens/login_screen.dart';
import 'dart:math' as math;
import 'package:wc_salary/widgets/game_button.dart';
import 'package:wc_salary/providers/auth_provider.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _salaryController = TextEditingController();
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _checkSalary();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticInOut,
      ),
    );

    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _checkSalary() async {
    final toiletProvider = Provider.of<ToiletSessionProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    await toiletProvider.initialize();

    // Only navigate to home if not authenticated and has salary set
    // (authenticated users are handled by AuthCheckWrapper)
    if (!authProvider.isAuthenticated && toiletProvider.monthlySalary > 0) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = const Offset(1.0, 0.0);
          var end = Offset.zero;
          var curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            // Background decoration
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFF8D6E63).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: const Color(0xFF8D6E63).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Wooden planks background
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Image.asset(
                  'assets/images/wooden_background.jpg',
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Main content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App title with animation
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _bounceAnimation.value),
                          child: Transform.rotate(
                            angle: _rotateAnimation.value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3D2314),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF8D6E63),
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '💰 TOILET CASH 💰',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFFFAA33),
                                    fontFamily: 'RubikDirt',
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        offset: Offset(2, 2),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: -10,
                                top: -20,
                                child: Transform.rotate(
                                  angle: 0.3,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'GAME',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3D2314),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF8D6E63),
                                width: 2,
                              ),
                            ),
                            child: const Text(
                              'Make money while you go! 🚽',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontFamily: 'RubikDirt',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // Toilet image in a frame
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2314),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF8D6E63),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.wc,
                        size: 80,
                        color: Color(0xFFFFAA33),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Game intro text
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2314),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF8D6E63),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF7D2A),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFFFAA33),
                                  Color(0xFFFF7D2A),
                                ],
                              ),
                            ),
                            child: const Text(
                              'MISSION',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'RubikDirt',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                const Text(
                                  'Ready to turn your bathroom breaks into cash?',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    height: 1.4,
                                    fontFamily: 'RubikDirt',
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Enter your salary to start the game!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFFFFAA33),
                                    fontFamily: 'RubikDirt',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Salary input field
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3D2314),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF8D6E63),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF7D2A),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0xFFFFAA33),
                                  Color(0xFFFF7D2A),
                                ],
                              ),
                            ),
                            child: const Text(
                              'YOUR STATS',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'RubikDirt',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _salaryController,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'RubikDirt',
                            ),
                            decoration: InputDecoration(
                              labelText: 'Monthly Salary',
                              hintText: 'Enter your monthly salary',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFF8D6E63),
                                  width: 2,
                                ),
                              ),
                              prefixIcon: const Icon(
                                Icons.monetization_on,
                                color: Color(0xFFFFAA33),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Start game button
                    _isLoading
                        ? const CircularProgressIndicator(
                            color: Color(0xFFFFAA33),
                          )
                        : Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  blurRadius: 4,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                // Button frame/border
                                Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3D2314), // Wood-like brown
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFF8D6E63),
                                      width: 3,
                                    ),
                                  ),
                                ),

                                // Button inner padding for 3D effect
                                Positioned(
                                  top: 3,
                                  left: 3,
                                  right: 3,
                                  bottom: 3,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: MaterialButton(
                                      onPressed: () async {
                                        if (_salaryController.text.isEmpty) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                  'Please enter your salary to start the game!'),
                                              backgroundColor: Colors.red.shade400,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                          return;
                                        }

                                        setState(() {
                                          _isLoading = true;
                                        });

                                        try {
                                          final salary = double.parse(_salaryController.text);

                                          await Provider.of<ToiletSessionProvider>(context,
                                                  listen: false)
                                              .setMonthlySalary(salary);

                                          _navigateToHome();
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: const Text('Please enter a valid number'),
                                              backgroundColor: Colors.red.shade400,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        } finally {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        }
                                      },
                                      padding: EdgeInsets.zero,
                                      color: const Color(0xFFFF7D2A),
                                      splashColor: const Color(0xFFFFAA33).withOpacity(0.3),
                                      highlightColor: const Color(0xFFFFAA33).withOpacity(0.1),
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      elevation: 0,
                                      highlightElevation: 0,
                                      child: Ink(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Color(0xFFFFAA33),
                                              Color(0xFFFF7D2A),
                                              Color(0xFFFF5722),
                                            ],
                                          ),
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                          child: const Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.play_arrow, color: Colors.white),
                                              SizedBox(width: 8),
                                              Text(
                                                'START GAME',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  fontFamily: 'RubikDirt',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                    const SizedBox(height: 20),

                    // Login button with the game UI style
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Button frame/border
                          Container(
                            width: double.infinity,
                            height: 56,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3D2314), // Wood-like brown
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF8D6E63),
                                width: 3,
                              ),
                            ),
                          ),

                          // Button inner padding for 3D effect
                          Positioned(
                            top: 3,
                            left: 3,
                            right: 3,
                            bottom: 3,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: MaterialButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                                  );
                                },
                                padding: EdgeInsets.zero,
                                color: const Color(0xFF8D6E63),
                                splashColor: const Color(0xFFFFAA33).withOpacity(0.3),
                                highlightColor: const Color(0xFFFFAA33).withOpacity(0.1),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                elevation: 0,
                                highlightElevation: 0,
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.login, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text(
                                        'LOGIN',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          fontFamily: 'RubikDirt',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Rating button - circular button
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          // Button frame/border
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3D2314), // Wood-like brown
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF8D6E63),
                                width: 3,
                              ),
                            ),
                          ),

                          // Button inner padding for 3D effect
                          Positioned(
                            top: 3,
                            left: 3,
                            right: 3,
                            bottom: 3,
                            child: ClipOval(
                              child: MaterialButton(
                                onPressed: null,
                                padding: EdgeInsets.zero,
                                color: const Color(0xFF8D6E63),
                                elevation: 0,
                                highlightElevation: 0,
                                shape: const CircleBorder(),
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.leaderboard,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _salaryController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
