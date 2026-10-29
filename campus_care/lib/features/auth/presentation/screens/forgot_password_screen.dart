import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../../shared/widgets/auth_scaffold.dart';
import '../../../../shared/widgets/error_banner.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../viewModels/auth_provider.dart';

/// Deliberately differs from the Figma: the design lets anyone reset a password with
/// only a student number. Here a reset link is emailed to the university address.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _loading = false;
  bool _sent = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
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
      await context.read<AuthProvider>().sendPasswordReset(_email.text);
      if (mounted) setState(() => _sent = true);
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AuthScaffold(
      showBack: true,
      child: GlassCard(
        child: _sent
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Check your email',
                    style: text.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'If an account exists for that address, we have sent a link to reset '
                    'your password. The link expires after a short time.',
                    style: text.bodyLarge,
                  ),
                ],
              )
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Forgot Password',
                      style: text.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No worries! Enter your university email and we will send you a reset link.',
                      style: text.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    if (_error != null) ...[
                      ErrorBanner(_error!),
                      const SizedBox(height: 16),
                    ],
                    AppTextField(
                      label: 'University email',
                      controller: _email,
                      validator: Validators.email,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.email],
                      enabled: !_loading,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 24),
                    AppButton(
                      label: 'Send reset link',
                      loading: _loading,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
