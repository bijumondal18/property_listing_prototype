import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/validators/validators.dart';
import '../../../data/models/property.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/interest_bloc.dart';

class InterestFormScreen extends StatefulWidget {
  const InterestFormScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  State<InterestFormScreen> createState() => _InterestFormScreenState();
}

class _InterestFormScreenState extends State<InterestFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController(
    text: "I'm interested in this property. Please contact me with more details.",
  );

  Property? _property;
  bool _loadingProperty = true;
  String? _propertyError;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    context.read<InterestBloc>().add(const InterestResetStatus());
    final user = context.read<AuthBloc>().state.user;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
    }
    _loadProperty();
  }

  Future<void> _loadProperty() async {
    try {
      final property = await context
          .read<PropertyRepository>()
          .getPropertyById(widget.propertyId);
      if (!mounted) return;
      if (property == null) {
        setState(() {
          _loadingProperty = false;
          _propertyError = 'Property not found.';
        });
      } else {
        setState(() {
          _property = property;
          _loadingProperty = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingProperty = false;
        _propertyError = 'Something went wrong.';
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_submitted) return;
    if (!_formKey.currentState!.validate()) return;
    final property = _property;
    if (property == null) return;

    context.read<InterestBloc>().add(
          InterestSubmitRequested(
            propertyId: property.id,
            propertyName: property.name,
            ownerId: property.ownerId,
            userName: _nameController.text.trim(),
            mobile: _mobileController.text.trim(),
            email: _emailController.text.trim(),
            message: _messageController.text.trim(),
          ),
        );
  }

  void _showSuccessDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: Icon(
            Icons.check_circle_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 48,
          ),
          title: const Text('Interest submitted successfully!'),
          content: const Text(
            'The property owner will be able to view your request.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/user/home');
                }
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Interest')),
      body: BlocConsumer<InterestBloc, InterestState>(
        listenWhen: (previous, current) =>
            previous.submitStatus != current.submitStatus,
        listener: (context, state) {
          if (state.isSubmitSuccess) {
            setState(() => _submitted = true);
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                const SnackBar(
                  content: Text(
                    'Interest submitted successfully! The property owner will be able to view your request.',
                  ),
                ),
              );
            _showSuccessDialog();
          } else if (state.submitStatus == InterestSubmitStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
          }
        },
        builder: (context, state) {
          if (_loadingProperty) {
            return const LoadingView(message: 'Loading...');
          }
          if (_propertyError != null) {
            return ErrorState(message: _propertyError!, onRetry: _loadProperty);
          }

          final property = _property!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Express your interest',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Fill in your details and the owner will get in touch.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Selected Property',
                      prefixIcon: Icon(Icons.home_work_outlined),
                      enabled: false,
                    ),
                    child: Text(
                      property.name,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.person_outline),
                    validator: Validators.name,
                    enabled: !state.isSubmitting && !_submitted,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _mobileController,
                    label: 'Mobile Number',
                    hint: '10-digit Indian mobile number',
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.phone_outlined),
                    validator: Validators.phone,
                    enabled: !state.isSubmitting && !_submitted,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _emailController,
                    label: 'Email ID',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: Validators.email,
                    enabled: !state.isSubmitting && !_submitted,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _messageController,
                    label: 'Message',
                    hint: 'Tell the owner more about your interest',
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    validator: (value) =>
                        Validators.required(value, fieldName: 'Message'),
                    enabled: !state.isSubmitting && !_submitted,
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    label: _submitted ? 'Submitted' : 'Submit Interest',
                    isLoading: state.isSubmitting,
                    onPressed: _submitted ? null : _submit,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
