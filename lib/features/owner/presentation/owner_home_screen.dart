import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/dashboard_stat_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/interest_card.dart';
import '../../../shared/widgets/loading_view.dart';
import '../../../shared/widgets/property_card.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/owner_dashboard_bloc.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const double _tabBarHeight = 48;
  static const double _expandedBodyHeight = 166;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final ownerId = context.read<AuthBloc>().state.user?.id;
    if (ownerId != null) {
      context.read<OwnerDashboardBloc>().add(
        OwnerDashboardLoadRequested(ownerId),
      );
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final ownerId = context.read<AuthBloc>().state.user?.id;
    if (ownerId != null) {
      context.read<OwnerDashboardBloc>().add(
        OwnerDashboardLoadRequested(ownerId),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  void _logout() {
    context.read<AuthBloc>().add(const AuthLogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = context.watch<AuthBloc>().state.user;

    return Scaffold(
      body: BlocBuilder<OwnerDashboardBloc, OwnerDashboardState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Welcome back 👋'),
                actions: [
                  IconButton(
                    tooltip: 'Logout',
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                  ),
                ],
              ),
              body: const LoadingView(message: 'Loading dashboard...'),
            );
          }

          if (state.hasError) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Welcome back 👋'),
                actions: [
                  IconButton(
                    tooltip: 'Logout',
                    icon: const Icon(Icons.logout),
                    onPressed: _logout,
                  ),
                ],
              ),
              body: ErrorState(
                message: state.errorMessage ?? 'Something went wrong.',
                onRetry: () {
                  final ownerId = context.read<AuthBloc>().state.user?.id;
                  if (ownerId != null) {
                    context.read<OwnerDashboardBloc>().add(
                      OwnerDashboardLoadRequested(ownerId),
                    );
                  }
                },
              ),
            );
          }

          return NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: SliverAppBar(
                    pinned: true,
                    primary: true,
                    forceElevated: innerBoxIsScrolled,
                    backgroundColor: colorScheme.surface,
                    surfaceTintColor: Colors.transparent,
                    // Collapse fully to the TabBar (`bottom`) only.
                    // Note: Flutter adds bottomHeight on top of collapsedHeight,
                    // so collapsedHeight must be 0 when bottom hosts the TabBar.
                    toolbarHeight: 0,
                    collapsedHeight: 0,
                    expandedHeight: _expandedBodyHeight + _tabBarHeight,
                    automaticallyImplyLeading: false,
                    bottom: PreferredSize(
                      preferredSize: const Size.fromHeight(_tabBarHeight),
                      child: Material(
                        color: colorScheme.surface,
                        elevation: 0,
                        child: TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'My Properties'),
                            Tab(text: 'Interested Users'),
                          ],
                        ),
                      ),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      background: ColoredBox(
                        color: colorScheme.surface,
                        child: SafeArea(
                          bottom: false,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              8,
                              8,
                              _tabBarHeight + 12,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Welcome back 👋',
                                            style: theme.textTheme.titleLarge
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          Text(
                                            user != null
                                                ? '${user.name}, manage your properties'
                                                : 'Manage your properties',
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      tooltip: 'Logout',
                                      icon: const Icon(Icons.logout),
                                      onPressed: _logout,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DashboardStatCard(
                                        label: 'Total Properties',
                                        value: '${state.totalProperties}',
                                        icon: Icons.home_work_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DashboardStatCard(
                                        label: 'Total Interests',
                                        value: '${state.totalInterests}',
                                        icon: Icons.favorite_border,
                                        color: const Color(0xFFC62828),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _PropertiesTab(state: state, onRefresh: _refresh),
                _InterestsTab(state: state, onRefresh: _refresh),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PropertiesTab extends StatelessWidget {
  const _PropertiesTab({required this.state, required this.onRefresh});

  final OwnerDashboardState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        if (state.properties.isEmpty) {
          return CustomScrollView(
            key: const PageStorageKey<String>('owner_properties_empty'),
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
              ),
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  title: 'No properties yet',
                  message: 'Your listed properties will appear here.',
                  icon: Icons.home_work_outlined,
                ),
              ),
            ],
          );
        }

        return RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            key: const PageStorageKey<String>('owner_properties'),
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverList.separated(
                  itemCount: state.properties.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final property = state.properties[index];
                    return PropertyCard(
                      property: property,
                      interestCount: state.interestCounts[property.id] ?? 0,
                      onViewDetails: () {
                        showModalBottomSheet<void>(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    property.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(property.location),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${Formatters.formatPrice(property.price)} • ${property.configuration} • ${Formatters.formatArea(property.area)}',
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Interests received: ${state.interestCounts[property.id] ?? 0}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(property.description),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InterestsTab extends StatelessWidget {
  const _InterestsTab({required this.state, required this.onRefresh});

  final OwnerDashboardState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: CustomScrollView(
            key: const PageStorageKey<String>('owner_interests'),
            slivers: [
              SliverOverlapInjector(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                  context,
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 56,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: const Text('All'),
                          selected: state.selectedPropertyFilterId == null,
                          onSelected: (_) {
                            context.read<OwnerDashboardBloc>().add(
                              const OwnerInterestPropertyFilterChanged(null),
                            );
                          },
                        ),
                      ),
                      ...state.properties.map(
                        (property) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              property.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                            selected:
                                state.selectedPropertyFilterId == property.id,
                            onSelected: (_) {
                              context.read<OwnerDashboardBloc>().add(
                                OwnerInterestPropertyFilterChanged(property.id),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (state.filteredInterests.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    title: 'No interest submissions yet',
                    message: 'When users show interest in your properties, they\'ll appear here.',
                    icon: Icons.inbox_outlined,
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverList.separated(
                    itemCount: state.filteredInterests.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return InterestCard(
                        interest: state.filteredInterests[index],
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
