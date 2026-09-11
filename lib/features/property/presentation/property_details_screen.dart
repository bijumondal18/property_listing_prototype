import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/formatters.dart';
import '../../../data/models/app_user.dart';
import '../../../data/models/property.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/property_image.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../user/bloc/favorites_bloc.dart';

class PropertyDetailsScreen extends StatefulWidget {
  const PropertyDetailsScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  State<PropertyDetailsScreen> createState() => _PropertyDetailsScreenState();
}

class _PropertyDetailsScreenState extends State<PropertyDetailsScreen> {
  Property? _property;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final property = await context
          .read<PropertyRepository>()
          .getPropertyById(widget.propertyId);
      if (!mounted) return;
      if (property == null) {
        setState(() {
          _loading = false;
          _error = 'Property not found.';
        });
      } else {
        setState(() {
          _property = property;
          _loading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Something went wrong.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = context.watch<AuthBloc>().state.user;
    final isUser = user?.role == UserRole.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Property Details'),
        actions: [
          if (isUser && _property != null)
            BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, favState) {
                final userId = user!.id;
                final isFavorite = favState.isFavorite(_property!.id);
                return IconButton(
                  tooltip: isFavorite
                      ? 'Remove from saved'
                      : 'Save property',
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? const Color(0xFFC62828) : null,
                  ),
                  onPressed: () {
                    context.read<FavoritesBloc>().add(
                      FavoritesToggleRequested(
                        userId: userId,
                        propertyId: _property!.id,
                      ),
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: _loading
          ? const LoadingView(message: 'Loading property...')
          : _error != null
              ? ErrorState(message: _error!, onRetry: _load)
              : _buildContent(theme, _property!),
      bottomNavigationBar: _property == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: PrimaryButton(
                  label: 'Submit Interest',
                  icon: Icons.favorite_border,
                  onPressed: () {
                    context.push('/property/${widget.propertyId}/interest');
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildContent(ThemeData theme, Property property) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PropertyImage(
            imageUrl: property.imageUrl,
            localImagePath: property.localImagePath,
            height: 260,
            borderRadius: BorderRadius.zero,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  Formatters.formatPrice(property.price),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _DetailChip(
                      icon: Icons.bed_outlined,
                      label: property.configuration,
                    ),
                    _DetailChip(
                      icon: Icons.square_foot,
                      label: Formatters.formatArea(property.area),
                    ),
                    _DetailChip(
                      icon: Icons.home_work_outlined,
                      label: property.type,
                    ),
                    _DetailChip(
                      icon: Icons.info_outline,
                      label: property.status,
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  'About Property',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  property.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.55,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 16),
                _InfoTile(
                  label: 'Owner',
                  value: property.ownerName,
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _InfoTile(
                  label: 'Property ID',
                  value: property.id,
                  icon: Icons.tag,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ],
    );
  }
}
