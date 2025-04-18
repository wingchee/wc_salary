import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:wc_salary/models/toilet_session.dart';
import 'package:wc_salary/providers/auth_provider.dart';
import 'package:wc_salary/providers/toilet_session_provider.dart';
import 'package:wc_salary/screens/login_screen.dart';
import 'package:wc_salary/screens/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late Timer _timer;
  String _elapsedTimeDisplay = '00:00:00.000';
  Duration _elapsedTime = Duration.zero;

  // Animations
  late AnimationController _coinAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _pulseAnimation;
  bool _showCoinAnimation = false;
  List<_CoinAnimation> _coinAnimations = [];

  // Game levels
  final List<Map<String, dynamic>> _levels = [
    {'name': 'Beginner', 'minEarnings': 0, 'color': Colors.green},
    {'name': 'Pro Sitter', 'minEarnings': 50, 'color': Colors.blue},
    {'name': 'Lavatory Legend', 'minEarnings': 100, 'color': Colors.purple},
    {'name': 'Toilet Tycoon', 'minEarnings': 250, 'color': Colors.orange},
    {'name': 'Bathroom Baron', 'minEarnings': 500, 'color': Colors.red},
  ];

  // Rewards/achievements
  final List<Map<String, dynamic>> _achievements = [
    {
      'name': 'First Flush',
      'description': 'Complete your first toilet session',
      'icon': Icons.water_drop
    },
    {
      'name': 'Speed Runner',
      'description': 'Complete a session under 2 minutes',
      'icon': Icons.speed
    },
    {
      'name': 'Long Haul',
      'description': 'Spend over 10 minutes in one session',
      'icon': Icons.timer
    },
    {
      'name': 'Money Maker',
      'description': 'Earn over \$10 in a single session',
      'icon': Icons.monetization_on
    },
    {
      'name': 'Daily Ritual',
      'description': 'Use the app 5 days in a row',
      'icon': Icons.calendar_today
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();

    // Initialize animations
    _coinAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      final provider = Provider.of<ToiletSessionProvider>(context, listen: false);
      if (provider.isTracking) {
        final start = provider.startTime;
        if (start != null) {
          setState(() {
            _elapsedTime = DateTime.now().difference(start);
            _elapsedTimeDisplay = _formatDuration(_elapsedTime);

            // Generate random coin animation at intervals
            if (Random().nextInt(50) == 0) {
              // 1 in 50 chance every 100ms
              _addCoinAnimation();
            }
          });
        }
      }
    });
  }

  void _addCoinAnimation() {
    final screenWidth = MediaQuery.of(context).size.width;
    final startX = Random().nextDouble() * screenWidth;

    setState(() {
      _coinAnimations.add(
        _CoinAnimation(
          startX: startX,
          startY: 300,
          controller: AnimationController(
            vsync: this,
            duration: Duration(milliseconds: 1500 + Random().nextInt(1000)),
          )..forward().then((_) {
              setState(() {
                _coinAnimations.removeAt(0);
              });
            }),
        ),
      );
    });
  }

  void _showEarningsAnimation() {
    setState(() {
      _showCoinAnimation = true;
    });

    _coinAnimationController.reset();
    _coinAnimationController.forward().then((_) {
      setState(() {
        _showCoinAnimation = false;
      });
    });
  }

  String _getCurrentLevel(double totalEarnings) {
    String level = _levels[0]['name'];
    Color color = _levels[0]['color'];

    for (var i = _levels.length - 1; i >= 0; i--) {
      if (totalEarnings >= _levels[i]['minEarnings']) {
        level = _levels[i]['name'];
        color = _levels[i]['color'];
        break;
      }
    }

    return level;
  }

  Color _getLevelColor(double totalEarnings) {
    Color color = _levels[0]['color'];

    for (var i = _levels.length - 1; i >= 0; i--) {
      if (totalEarnings >= _levels[i]['minEarnings']) {
        color = _levels[i]['color'];
        break;
      }
    }

    return color;
  }

  double _getLevelProgress(double totalEarnings) {
    int currentLevelIndex = 0;

    for (var i = _levels.length - 1; i >= 0; i--) {
      if (totalEarnings >= _levels[i]['minEarnings']) {
        currentLevelIndex = i;
        break;
      }
    }

    if (currentLevelIndex >= _levels.length - 1) {
      return 1.0; // Max level reached
    }

    double currentLevelMin = _levels[currentLevelIndex]['minEarnings'];
    double nextLevelMin = _levels[currentLevelIndex + 1]['minEarnings'];
    double range = nextLevelMin - currentLevelMin;

    return (totalEarnings - currentLevelMin) / range;
  }

  void _checkAchievements(ToiletSession session) {
    final toiletProvider = Provider.of<ToiletSessionProvider>(context, listen: false);

    // First flush
    if (!toiletProvider.isAchievementUnlocked('First Flush')) {
      _unlockAchievement('First Flush');
    }

    // Speed runner
    if (session.duration.inMinutes < 2) {
      _unlockAchievement('Speed Runner');
    }

    // Long haul
    if (session.duration.inMinutes > 10) {
      _unlockAchievement('Long Haul');
    }

    // Money maker
    if (session.earnedAmount > 10) {
      _unlockAchievement('Money Maker');
    }

    // Daily ritual is checked elsewhere (need to track login days)
  }

  void _unlockAchievement(String name) {
    final toiletProvider = Provider.of<ToiletSessionProvider>(context, listen: false);

    // First check if it's already unlocked to avoid unnecessary work
    if (!toiletProvider.isAchievementUnlocked(name)) {
      // Unlock in the provider (which will handle local storage and Firebase)
      toiletProvider.unlockAchievement(name);

      // Show achievement dialog
      final achievement = _achievements.firstWhere((a) => a['name'] == name);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(achievement['icon'], color: Colors.yellow),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Achievement Unlocked!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(achievement['name']),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String threeDigits(int n) => n.toString().padLeft(3, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String threeDigitMilliseconds = threeDigits(duration.inMilliseconds.remainder(1000));
    return '${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds.$threeDigitMilliseconds';
  }

  String _formatMoney(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy - HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final toiletProvider = Provider.of<ToiletSessionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final totalEarnings = toiletProvider.totalEarnings;
    final currentLevel = _getCurrentLevel(totalEarnings);
    final levelColor = _getLevelColor(totalEarnings);
    final levelProgress = _getLevelProgress(totalEarnings);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.monetization_on, color: Colors.amber),
            const SizedBox(width: 8),
            const Text('TOILET CASH'),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            icon: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              // Player stats card
              Card(
                margin: const EdgeInsets.all(16),
                child: InkWell(
                  onTap: () {
                    _showPlayerStatsDialog();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'LEVEL: $currentLevel',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: levelColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: LinearProgressIndicator(
                                      value: levelProgress,
                                      backgroundColor: Colors.grey.shade200,
                                      valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                                      minHeight: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Add a small indicator to show it's tappable
                            const Icon(Icons.chevron_right, color: Colors.grey),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatItem(
                              icon: Icons.monetization_on,
                              label: 'Monthly Salary',
                              value: _formatMoney(toiletProvider.monthlySalary),
                              color: Colors.green,
                            ),
                            _StatItem(
                              icon: Icons.attach_money,
                              label: 'Earned',
                              value: _formatMoney(toiletProvider.totalEarnings),
                              color: Colors.amber,
                            ),
                            _StatItem(
                              icon: Icons.timer,
                              label: 'Time',
                              value: _formatDuration(toiletProvider.totalDuration).split('.').first,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Timer section
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: toiletProvider.isTracking
                        ? [Colors.blue.shade700, Colors.blue.shade900]
                        : [Colors.grey.shade200, Colors.grey.shade300],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                margin: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: toiletProvider.isTracking ? _pulseAnimation.value : 1.0,
                          child: child,
                        );
                      },
                      child: Text(
                        toiletProvider.isTracking
                            ? 'TOILET TIME: $_elapsedTimeDisplay'
                            : 'READY TO EARN?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: toiletProvider.isTracking ? Colors.white : Colors.grey.shade800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (toiletProvider.isTracking)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Earning in progress...',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.attach_money, color: Colors.amber, size: 20),
                                const SizedBox(width: 4),
                                StreamBuilder<int>(
                                  stream: Stream.periodic(
                                    const Duration(milliseconds: 500),
                                    (count) => count,
                                  ),
                                  builder: (context, snapshot) {
                                    if (!toiletProvider.isTracking) return const Text('0.00');
                                    final hourlyRate =
                                        toiletProvider.monthlySalary / (8 * 5 * 4.33);
                                    final secondRate = hourlyRate / 3600;
                                    final millisecondRate = secondRate / 1000;
                                    final currentEarning =
                                        millisecondRate * _elapsedTime.inMilliseconds;
                                    return Text(
                                      _formatMoney(currentEarning),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: !toiletProvider.isTracking
                          ? ElevatedButton.icon(
                              onPressed: () {
                                toiletProvider.startSession();
                              },
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('START EARNING'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : ElevatedButton.icon(
                              onPressed: () async {
                                final session = await toiletProvider.endSession();
                                if (session != null && mounted) {
                                  _showEarningsAnimation();
                                  _checkAchievements(session);

                                  // Show result dialog
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Row(
                                        children: [
                                          Icon(Icons.celebration,
                                              color: Theme.of(context).colorScheme.primary),
                                          const SizedBox(width: 8),
                                          const Text('You Earned Cash!'),
                                        ],
                                      ),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.attach_money,
                                            size: 50,
                                            color: Colors.amber.shade700,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            _formatMoney(session.earnedAmount),
                                            style: TextStyle(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green.shade700,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Text('Time spent: ${_formatDuration(session.duration)}'),
                                        ],
                                      ),
                                      actions: [
                                        if (!authProvider.isAuthenticated)
                                          TextButton.icon(
                                            onPressed: () {
                                              Navigator.of(ctx).pop();
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => const ProfileScreen(),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.login),
                                            label: const Text('Login to Save'),
                                          ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          child: const Text('Awesome!'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.stop),
                              label: const Text('FINISH'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),

              // History section with game styling
              Expanded(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.history,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'EARNINGS HISTORY',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (!authProvider.isAuthenticated)
                            TextButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                                );
                              },
                              icon: const Icon(Icons.login, size: 16),
                              label: const Text('Save Progress'),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: toiletProvider.sessions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.wc,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No toilet sessions yet!',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Press START to begin earning',
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: toiletProvider.sessions.length,
                              itemBuilder: (context, index) {
                                final session = toiletProvider.sessions[index];
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor:
                                          Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                      child: Icon(
                                        Icons.monetization_on,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                    title: Text(
                                      _formatDateTime(session.startTime),
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    subtitle: Text(
                                      'Duration: ${_formatDuration(session.duration).split('.').first}',
                                    ),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.shade50,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.green.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        _formatMoney(session.earnedAmount),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade700,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Coin animations
          if (_coinAnimations.isNotEmpty)
            ...List.generate(_coinAnimations.length, (index) {
              return AnimatedBuilder(
                animation: _coinAnimations[index].controller,
                builder: (context, child) {
                  final animation = _coinAnimations[index];
                  final value = animation.controller.value;

                  // Calculate position with a curve
                  final yPos = animation.startY - (300 * value); // Move up
                  final xPos = animation.startX + (sin(value * 6) * 40); // Wiggle
                  final opacity = 1.0 - (value * 0.5); // Fade out partially

                  return Positioned(
                    left: xPos,
                    top: yPos,
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.scale(
                        scale: 1.0 - (value * 0.3), // Slight shrink
                        child: const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 30,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),

          // Earnings animation overlay
          if (_showCoinAnimation)
            AnimatedBuilder(
              animation: _coinAnimationController,
              builder: (context, child) {
                final value = _coinAnimationController.value;
                return Stack(
                  children: List.generate(30, (index) {
                    final random = Random();
                    final size = 20 + random.nextInt(20).toDouble();
                    final speed = 0.6 + random.nextDouble() * 0.4;
                    final direction = random.nextDouble() * 2 * pi;
                    final distance = 100 + random.nextInt(150).toDouble();
                    final delay = random.nextDouble() * 0.3;

                    // Only start animation after delay
                    double animValue = value <= delay ? 0 : (value - delay) / (1 - delay);
                    animValue = animValue.clamp(0.0, 1.0);

                    final xPos = MediaQuery.of(context).size.width / 2 +
                        cos(direction) * distance * animValue * speed;
                    final yPos = MediaQuery.of(context).size.height / 2 +
                        sin(direction) * distance * animValue * speed;

                    return Positioned(
                      left: xPos - size / 2,
                      top: yPos - size / 2,
                      child: Opacity(
                        opacity: 1.0 - animValue,
                        child: Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: size,
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
        ],
      ),
    );
  }

  void _showPlayerStatsDialog() {
    final toiletProvider = Provider.of<ToiletSessionProvider>(context, listen: false);
    final totalEarnings = toiletProvider.totalEarnings;
    final currentLevel = _getCurrentLevel(totalEarnings);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              const Text(
                'PLAYER STATS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7D2A),
                ),
              ),
              const Divider(thickness: 2),

              // Content in a scrollable container
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Levels section
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'GAME LEVELS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // List of all levels with current level highlighted
                      ...List.generate(_levels.length, (index) {
                        final level = _levels[index];
                        final isCurrentLevel = level['name'] == currentLevel;
                        final isLocked = totalEarnings < level['minEarnings'];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: level['color'],
                            child: Icon(
                              isLocked ? Icons.lock : Icons.emoji_events,
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            level['name'],
                            style: TextStyle(
                              fontWeight: isCurrentLevel ? FontWeight.bold : FontWeight.normal,
                              color: isLocked ? Colors.grey : null,
                            ),
                          ),
                          subtitle: Text('Min earnings: ${_formatMoney(level['minEarnings'])}'),
                          trailing: isCurrentLevel
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : null,
                        );
                      }),

                      const Divider(thickness: 1),

                      // Achievements section
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'ACHIEVEMENTS',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // List of all achievements with unlock status
                      ...List.generate(_achievements.length, (index) {
                        final achievement = _achievements[index];
                        final isUnlocked =
                            toiletProvider.isAchievementUnlocked(achievement['name']);

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: isUnlocked ? Colors.amber : Colors.grey.shade300,
                            child: Icon(
                              achievement['icon'],
                              color: isUnlocked ? Colors.white : Colors.grey,
                            ),
                          ),
                          title: Text(
                            achievement['name'],
                            style: TextStyle(
                              fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                              color: isUnlocked ? null : Colors.grey,
                            ),
                          ),
                          subtitle: Text(achievement['description']),
                          trailing: isUnlocked
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : const Icon(Icons.lock, color: Colors.grey),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Close button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('CLOSE'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _coinAnimationController.dispose();
    _pulseAnimationController.dispose();
    for (var anim in _coinAnimations) {
      anim.controller.dispose();
    }
    super.dispose();
  }
}

// Helper classes
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

class _CoinAnimation {
  final double startX;
  final double startY;
  final AnimationController controller;

  _CoinAnimation({
    required this.startX,
    required this.startY,
    required this.controller,
  });
}
