import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/providers/user_provider.dart';

class SidebarMenu extends StatefulWidget {
  const SidebarMenu({super.key});

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> {
  @override
  void initState() {
    super.initState();
    // Fetch user data when sidebar is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.userData == null) {
        userProvider.fetchUserData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green[800],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      child: userProvider.userData?['profileImage'] != null &&
                              userProvider.userData!['profileImage'].isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(30),
                              child: Image.network(
                                userProvider.userData!['profileImage'],
                                fit: BoxFit.cover,
                                width: 60,
                                height: 60,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.person,
                                        size: 40, color: Colors.white),
                              ),
                            )
                          : const Icon(Icons.person,
                              size: 40, color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    if (userProvider.isLoading)
                      const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    else if (userProvider.userData != null) ...[
                      Text(
                        '${userProvider.userData!['firstName'] ?? ''} ${userProvider.userData!['lastName'] ?? ''}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      Text(
                        userProvider.userData!['email'] ?? '',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ] else ...[
                      Text(
                        'Guest User',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      Text(
                        'Please login to see profile',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white70,
                            ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              context.go('/edit-profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.card_travel),
            title: const Text('My Trips'),
            onTap: () {
              Navigator.pop(context);
              context.go('/my-trips');
            },
          ),
          ListTile(
            leading: const Icon(Icons.place),
            title: const Text('Places'),
            onTap: () {
              Navigator.pop(context);
              context.go('/places');
            },
          ),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('Refresh Profile'),
            onTap: () {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              userProvider.fetchUserData();
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              userProvider.clearUserData();
              Navigator.pop(context);
              context.go('/login');
            },
          ),
        ],
      ),
    );
  }
}
