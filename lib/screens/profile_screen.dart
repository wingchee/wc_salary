import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wc_salary/providers/auth_provider.dart';
import 'package:wc_salary/providers/toilet_session_provider.dart';
import 'package:wc_salary/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _salaryController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize the salary controller with the current value
    final provider = Provider.of<ToiletSessionProvider>(context, listen: false);
    _salaryController.text = provider.monthlySalary.toString();
  }

  @override
  Widget build(BuildContext context) {
    final toiletProvider = Provider.of<ToiletSessionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Your Profile'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Player Card
            Center(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        child: Icon(
                          authProvider.isAuthenticated ? Icons.person : Icons.person_outline,
                          size: 50,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        authProvider.isAuthenticated
                            ? (authProvider.user?.displayName ?? 'Game Player')
                            : 'Guest Player',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (authProvider.isAuthenticated && authProvider.user?.email != null)
                        Text(
                          authProvider.user!.email!,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      const SizedBox(height: 16),
                      if (!authProvider.isAuthenticated)
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const LoginScreen()),
                            );
                          },
                          icon: const Icon(Icons.login),
                          label: const Text('Sign In to Save Progress'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.secondary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Game Settings Section
            const Text(
              'GAME SETTINGS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Monthly Salary Setting
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Monthly Salary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Adjust your monthly salary to recalculate your earnings.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Monthly Salary',
                        hintText: 'Enter your monthly salary',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                if (_salaryController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please enter a valid salary'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  _isLoading = true;
                                });

                                try {
                                  final salary = double.parse(_salaryController.text);
                                  await toiletProvider.setMonthlySalary(salary);

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Salary updated successfully!'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please enter a valid number'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } finally {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              },
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Update Salary'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Data Management Section
            const Text(
              'DATA MANAGEMENT',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // Clear History Option
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: Colors.red.shade400,
                ),
                title: const Text('Clear Toilet History'),
                subtitle: const Text('Delete all your toilet session records'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Clear History?'),
                      content: const Text(
                        'Are you sure you want to clear all your toilet session records? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            toiletProvider.clearSessions();
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('History cleared successfully!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Reset Game Option
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: Icon(
                  Icons.refresh,
                  color: Colors.orange.shade700,
                ),
                title: const Text('Reset Game'),
                subtitle: const Text('Reset all game data and start fresh'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Reset Game?'),
                      content: const Text(
                        'Are you sure you want to reset all game data? This will clear your history and reset your salary. This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            // Reset salary to 0 and clear sessions
                            await toiletProvider.setMonthlySalary(0);
                            toiletProvider.clearSessions();
                            Navigator.of(context).pop();

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Game reset successfully!'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // Navigate back to home screen
                              Navigator.of(context).pop();
                            }
                          },
                          child: Text(
                            'Reset',
                            style: TextStyle(color: Colors.red.shade600),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            if (authProvider.isAuthenticated) ...[
              const SizedBox(height: 24),

              // Account Section
              const Text(
                'ACCOUNT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Logout Option
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.blue,
                  ),
                  title: const Text('Sign Out'),
                  subtitle: const Text('Sign out from your account'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Sign Out?'),
                        content: const Text(
                          'Are you sure you want to sign out from your account?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              await authProvider.signOut();
                              toiletProvider.clearSessions();
                              Navigator.of(context).pop();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'Toilet Cash Game',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
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
    super.dispose();
  }
}
