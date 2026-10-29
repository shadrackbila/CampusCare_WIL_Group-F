import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/routing/app_router.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/auth_scaffold.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../viewModels/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _studentNumber = TextEditingController();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _studentNumber.dispose();
    _fullName.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final needsConfirmation = await context.read<AuthProvider>().signUp(
        studentNumber: _studentNumber.text,
        fullName: _fullName.text,
        email: _email.text,
        password: _password.text,
      );
      if (!mounted) return;
      if (needsConfirmation) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Check your email'),
            content: const Text(
              'We sent a confirmation link to your university email. '
              'Open it, then come back and log in.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
        if (mounted) Navigator.of(context).pushReplacement(AppRoutes.login());
      }
      // Otherwise a session exists and the router shows onboarding.
    } on AppException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AuthScaffold(
      showBack: true,
      child: GlassCard(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Create Your Account',
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please enter your details to get started.',
                style: text.bodyLarge,
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                ErrorBanner(_error!),
                const SizedBox(height: 16),
              ],
              AppTextField(
                label: 'Student Number',
                controller: _studentNumber,
                validator: Validators.studentNumber,
                textInputAction: TextInputAction.next,
                enabled: !_loading,
              ),
              const SizedBox(height: 8),
              AppTextField(
                label: 'Initials & Surname',
                controller: _fullName,
                validator: Validators.fullName,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                enabled: !_loading,
              ),
              const SizedBox(height: 8),
              AppTextField(
                label: 'Email Address',
                controller: _email,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                enabled: !_loading,
              ),
              const SizedBox(height: 8),
              AppTextField(
                label: 'Password',
                controller: _password,
                obscure: true,
                validator: Validators.password,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.newPassword],
                enabled: !_loading,
              ),
              const SizedBox(height: 8),
              AppTextField(
                label: 'Confirm Password',
                controller: _confirm,
                obscure: true,
                validator: (v) => Validators.confirmPassword(v, _password.text),
                textInputAction: TextInputAction.done,
                enabled: !_loading,
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Register',
                loading: _loading,
                onPressed: _submit,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: _loading
                        ? null
                        : () => Navigator.of(
                            context,
                          ).pushReplacement(AppRoutes.login()),
                    child: const Text('Log In'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
