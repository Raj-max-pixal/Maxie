import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maxie_mobile/features/auth/application/auth_providers.dart';
import 'package:maxie_mobile/features/auth/presentation/auth_widgets.dart';
import 'package:maxie_mobile/navigation/app_routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
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
      await auth.signIn(email: _email.text, password: _password.text);
      if (mounted) goHome(context);
    } catch (error) {
      if (mounted) setState(() => _error = authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AuthFrame(
    title: 'Welcome back',
    subtitle: 'Sign in to continue with MAXie.',
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
          Align(
            alignment: Alignment.centerRight,
            child: AuthLink(
              label: 'Forgot password?',
              route: AppRoutes.forgotPassword,
            ),
          ),
          FilledButton(
            onPressed: _loading ? null : _submit,
            child: Text(_loading ? 'Signing in...' : 'Sign in'),
          ),
          AuthLink(label: 'Create an account', route: AppRoutes.signup),
        ],
      ),
    ),
  );
}
