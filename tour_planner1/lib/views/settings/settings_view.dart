import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';
import '../../core/providers/auth_provider.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer2<UserProvider, AuthProvider>(
        builder: (context, userProvider, authProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Profile Section
              Card(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Profile'),
                  subtitle:
                      Text(userProvider.userData?['email'] ?? 'Not logged in'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Account Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text('Notifications'),
                      trailing: Switch(
                        value: true, // TODO: Connect to user preferences
                        onChanged: (value) {
                          // TODO: Update notification preferences
                        },
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.security),
                      title: const Text('Privacy & Security'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Navigate to privacy settings
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.language),
                      title: const Text('Language'),
                      subtitle: const Text('English'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Navigate to language settings
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // App Settings
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.info),
                      title: const Text('About'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('About Tour Planner'),
                            content: const Text(
                              'Tour Planner v1.0.0\n\nYour companion for exploring Sri Lanka.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Close'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.help),
                      title: const Text('Help & Support'),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        // TODO: Navigate to help section
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Account Actions
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.refresh),
                      title: const Text('Refresh Profile Data'),
                      onTap: () {
                        userProvider.fetchUserData();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Profile data refreshed'),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout',
                          style: TextStyle(color: Colors.red)),
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  userProvider.clearUserData();
                                  authProvider.logout();
                                  Navigator.pop(context);
                                  Navigator.pushReplacementNamed(
                                      context, '/login');
                                },
                                child: const Text('Logout',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
