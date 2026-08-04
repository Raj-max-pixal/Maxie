import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to MAXie'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Onboarding Screen'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.go('/home');
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
