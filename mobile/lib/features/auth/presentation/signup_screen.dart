import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/auth/application/auth_providers.dart';
import 'package:maxie_mobile/features/auth/presentation/auth_widgets.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = ref.read(authServiceProvider);
      final credential = await auth.signUp(
        email: _email.text,
        password: _password.text,
        displayName: _name.text,
      );
      final user = credential.user;
      if (user != null) {
        await ref.read(userProfileRepositoryProvider).ensureProfile(user);
      }
      if (mounted) goHome(context);
    } catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthFrame(
    title: 'Create your account',
    subtitle: 'Your MAXie data belongs to your account.',
    child: Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) ...[
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            const SizedBox(height: 12),
          ],
          AuthTextField(controller: _name, label: 'Display name'),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _email,
            label: 'Email',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          AuthTextField(
            controller: _password,
            label: 'Password',
            obscureText: true,
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: Text(_loading ? 'Creating account...' : 'Create account'),
          ),
          AuthLink(label: 'Already have an account?', route: AppRoutes.login),
        ],
      ),
    ),
  );
}
