import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/user_provider.dart';

class ProfileHeader extends StatefulWidget {
  const ProfileHeader({super.key});

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
} 

class _ProfileHeaderState extends State<ProfileHeader> {
  @override
  void initState() {
    super.initState();
    // Don't automatically fetch user data on init to prevent rendering issues
    // User can refresh manually if needed
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[300],
            child: userProvider.userData?['profileImage'] != null &&
                    userProvider.userData!['profileImage'].isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      userProvider.userData!['profileImage'],
                      fit: BoxFit.cover,
                      width: 100,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey),
                    ),
                  )
                : const Icon(Icons.person, size: 60, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            userProvider.userData?['firstName'] ?? 'User',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            userProvider.userData?['email'] ?? '',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
