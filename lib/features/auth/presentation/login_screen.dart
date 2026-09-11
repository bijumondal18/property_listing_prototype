import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/validators/validators.dart';
import '../../../data/models/app_user.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/primary_button.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillCredentials(String email, String password, UserRole role) {
    _emailController.text = email;
    _passwordController.text = password;
    context.read<AuthBloc>().add(AuthRoleSelected(role));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final role = context.read<AuthBloc>().state.selectedRole;
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            role: role,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listenWhen: (previous, current) =>
            previous.status != current.status ||
            previous.errorMessage != current.errorMessage,
        listener: (context, state) {
          if (state.status == AuthStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: colorScheme.error,
                ),
              );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            Icons.apartment_rounded,
                            size: 40,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          AppConstants.appName,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppConstants.appTagline,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 32),
                        AppTextField(
                          controller: _emailController,
                          label: 'Email',
                          hint: 'Enter your email',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.email],
                          prefixIcon: const Icon(Icons.email_outlined),
                          validator: Validators.email,
                          enabled: !state.isLoading,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _passwordController,
                          label: 'Password',
                          hint: 'Enter your password',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            tooltip: _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                          validator: Validators.password,
                          enabled: !state.isLoading,
                          onChanged: (_) {},
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Login as',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SegmentedButton<UserRole>(
                          segments: const [
                            ButtonSegment(
                              value: UserRole.user,
                              label: Text('User'),
                              icon: Icon(Icons.person_outline),
                            ),
                            ButtonSegment(
                              value: UserRole.propertyOwner,
                              label: Text('Property Owner'),
                              icon: Icon(Icons.business_outlined),
                            ),
                          ],
                          selected: {state.selectedRole},
                          onSelectionChanged: state.isLoading
                              ? null
                              : (roles) {
                                  context
                                      .read<AuthBloc>()
                                      .add(AuthRoleSelected(roles.first));
                                },
                        ),
                        const SizedBox(height: 28),
                        PrimaryButton(
                          label: 'Login',
                          isLoading: state.isLoading,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 28),
                        _DemoCredentialsCard(
                          onSelectUser: () => _fillCredentials(
                            DemoCredentials.userEmail,
                            DemoCredentials.userPassword,
                            UserRole.user,
                          ),
                          onSelectOwner: () => _fillCredentials(
                            DemoCredentials.ownerEmail,
                            DemoCredentials.ownerPassword,
                            UserRole.propertyOwner,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DemoCredentialsCard extends StatelessWidget {
  const _DemoCredentialsCard({
    required this.onSelectUser,
    required this.onSelectOwner,
  });

  final VoidCallback onSelectUser;
  final VoidCallback onSelectOwner;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.grey.shade600),
              const SizedBox(width: 8),
              Text(
                'Demo Credentials',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _CredentialTile(
            role: 'User',
            email: DemoCredentials.userEmail,
            password: DemoCredentials.userPassword,
            onTap: onSelectUser,
          ),
          const Divider(height: 20),
          _CredentialTile(
            role: 'Property Owner',
            email: DemoCredentials.ownerEmail,
            password: DemoCredentials.ownerPassword,
            onTap: onSelectOwner,
          ),
          const SizedBox(height: 8),
          Text(
            'Also: owner2@test.com / owner3@test.com (password: owner123)',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CredentialTile extends StatelessWidget {
  const _CredentialTile({
    required this.role,
    required this.email,
    required this.password,
    required this.onTap,
  });

  final String role;
  final String email;
  final String password;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    role,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(email, style: TextStyle(color: Colors.grey.shade700)),
                  Text(password, style: TextStyle(color: Colors.grey.shade700)),
                ],
              ),
            ),
            Text(
              'Tap to fill',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
