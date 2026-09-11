import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/ui_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/property_filters.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/filter_bottom_sheet.dart';
import '../../../shared/widgets/filter_button.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/pinned_header_delegate.dart';
import '../../../shared/widgets/property_card.dart';
import '../../../shared/widgets/property_search_bar.dart';
import '../../../shared/widgets/logout_confirmation.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../property/bloc/property_bloc.dart';
import '../bloc/favorites_bloc.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  static const double _searchSectionHeight = 76;
  static const double _greetingSectionHeight = 72;
  static const double _controlsHeight = 92;

  @override
  void initState() {
    super.initState();
    context.read<PropertyBloc>().add(const PropertyLoadRequested());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      context.read<PropertyBloc>().add(PropertySearchChanged(query));
    });
  }

  void _openFilters(PropertyState state) {
    FilterBottomSheet.show(
      context,
      initialFilters: state.filters,
      onApply: (filters) {
        context.read<PropertyBloc>().add(PropertyFiltersApplied(filters));
      },
      onReset: () {
        context.read<PropertyBloc>().add(const PropertyFiltersReset());
      },
    );
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showLogoutConfirmation(context);
    if (!mounted || !confirmed) return;
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = context.watch<AuthBloc>().state.user;
    final greeting = Formatters.greeting();

    return BlocListener<FavoritesBloc, FavoritesState>(
      listenWhen: (previous, current) =>
          current.lastMessage != null &&
          current.lastMessage != previous.lastMessage,
      listener: (context, state) {
        final message = state.lastMessage;
        if (message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      },
      child: Scaffold(
      body: BlocBuilder<PropertyBloc, PropertyState>(
        builder: (context, state) {
          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Primary pinned app bar respects the status-bar inset.
                // Search is in `bottom` so it stays pinned and never slides under the status bar.
                // Greeting lives in flexibleSpace and collapses away.
                SliverAppBar(
                  pinned: true,
                  primary: true,
                  forceElevated: false,
                  backgroundColor: colorScheme.surface,
                  surfaceTintColor: Colors.transparent,
                  toolbarHeight: 0,
                  collapsedHeight: 0,
                  expandedHeight:
                      _greetingSectionHeight + _searchSectionHeight,
                  automaticallyImplyLeading: false,
                  bottom: PreferredSize(
                    preferredSize:
                        const Size.fromHeight(_searchSectionHeight),
                    child: ColoredBox(
                      color: colorScheme.surface,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: PropertySearchBar(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: ColoredBox(
                      color: colorScheme.surface,
                      child: SafeArea(
                        bottom: false,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8,0, 0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '$greeting 👋',
                                        style: theme.textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user != null
                                            ? 'Hi ${user.name.split(' ').first}, find your perfect property'
                                            : 'Find your perfect property',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade600,
                                          height: 1.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Logout',
                                  icon: const Icon(Icons.logout),
                                  onPressed: _confirmLogout,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: PinnedHeaderDelegate(
                    height: _controlsHeight,
                    backgroundColor: colorScheme.surface,
                    elevation: 0.1,
                    child: _FilterSortControls(
                      state: state,
                      onOpenFilters: () => _openFilters(state),
                    ),
                  ),
                ),
              ];
            },
            body: _buildBody(state),
          );
        },
      ),
    ),
    );
  }

  Widget _buildBody(PropertyState state) {
    final userId = context.read<AuthBloc>().state.user?.id;
    final favState = context.watch<FavoritesBloc>().state;
    if (state.isLoading) {
      return const CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: LoadingView(message: 'Loading properties...'),
          ),
        ],
      );
    }

    if (state.hasError) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorState(
              message: state.errorMessage ?? 'Something went wrong.',
              onRetry: () {
                context
                    .read<PropertyBloc>()
                    .add(const PropertyLoadRequested());
              },
            ),
          ),
        ],
      );
    }

    if (state.isEmpty) {
      return CustomScrollView(
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              title: 'No properties found',
              message: 'Try changing your search or filters.',
              action: TextButton(
                onPressed: () {
                  _searchController.clear();
                  context
                      .read<PropertyBloc>()
                      .add(const PropertyFiltersReset());
                  context
                      .read<PropertyBloc>()
                      .add(const PropertySearchChanged(''));
                },
                child: const Text('Clear search & filters'),
              ),
            ),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<PropertyBloc>().add(const PropertyLoadRequested());
        await Future<void>.delayed(const Duration(milliseconds: 600));
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            sliver: SliverList.separated(
              itemCount: state.properties.length,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final property = state.properties[index];
                return PropertyCard(
                  property: property,
                  isFavorite: favState.isFavorite(property.id),
                  onFavoriteToggle: userId == null
                      ? null
                      : () {
                          context.read<FavoritesBloc>().add(
                            FavoritesToggleRequested(
                              userId: userId,
                              propertyId: property.id,
                            ),
                          );
                        },
                  onViewDetails: () {
                    context
                        .read<PropertyBloc>()
                        .add(PropertySelected(property));
                    context.push('/property/${property.id}');
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSortControls extends StatelessWidget {
  const _FilterSortControls({
    required this.state,
    required this.onOpenFilters,
  });

  final PropertyState state;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showCount = state.status == PropertyStatus.success;
    final borderColor = Colors.grey.shade300;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FilterButton(
                  activeCount: state.filters.activeFilterCount,
                  onPressed: onOpenFilters,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: kDashboardControlHeight,
                    child: DropdownButtonFormField<PropertySort>(
                      // ignore: deprecated_member_use
                      value: state.filters.sort,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                      decoration: InputDecoration(
                        isDense: false,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: theme.colorScheme.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: PropertySort.none,
                          child: Text(
                            'Sort: Default',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: PropertySort.priceLowToHigh,
                          child: Text(
                            'Price: Low to High',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: PropertySort.priceHighToLow,
                          child: Text(
                            'Price: High to Low',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: PropertySort.areaSmallToLarge,
                          child: Text(
                            'Area: Small to Large',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        DropdownMenuItem(
                          value: PropertySort.areaLargeToSmall,
                          child: Text(
                            'Area: Large to Small',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      onChanged: (sort) {
                        if (sort == null) return;
                        context
                            .read<PropertyBloc>()
                            .add(PropertySortChanged(sort));
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              showCount
                  ? '${state.properties.length} properties found'
                  : ' ',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
