import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Profile'),
            leading: const Icon(Icons.person),
            onTap: () {
              context.go('/profile');
            },
          ),
          ListTile(
            title: const Text('Subscription'),
            leading: const Icon(Icons.subscriptions),
            onTap: () {
              context.go('/subscription');
            },
          ),
        ],
      ),
    );
  }
}
