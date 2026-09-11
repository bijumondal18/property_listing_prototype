import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_constants.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/favorites_repository.dart';
import '../data/repositories/interest_repository.dart';
import '../data/repositories/mock_auth_repository.dart';
import '../data/repositories/mock_favorites_repository.dart';
import '../data/repositories/mock_interest_repository.dart';
import '../data/repositories/mock_property_repository.dart';
import '../data/repositories/property_repository.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/owner/bloc/owner_dashboard_bloc.dart';
import '../features/property/bloc/interest_bloc.dart';
import '../features/property/bloc/property_bloc.dart';
import '../features/user/bloc/favorites_bloc.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class PropertyListingApp extends StatefulWidget {
  const PropertyListingApp({
    super.key,
    this.authRepository,
    this.propertyRepository,
    this.interestRepository,
    this.favoritesRepository,
  });

  final AuthRepository? authRepository;
  final PropertyRepository? propertyRepository;
  final InterestRepository? interestRepository;
  final FavoritesRepository? favoritesRepository;

  @override
  State<PropertyListingApp> createState() => _PropertyListingAppState();
}

class _PropertyListingAppState extends State<PropertyListingApp> {
  late final AuthRepository _authRepository;
  late final PropertyRepository _propertyRepository;
  late final InterestRepository _interestRepository;
  late final FavoritesRepository _favoritesRepository;
  late final AuthBloc _authBloc;
  late final PropertyBloc _propertyBloc;
  late final InterestBloc _interestBloc;
  late final OwnerDashboardBloc _ownerDashboardBloc;
  late final FavoritesBloc _favoritesBloc;
  late final AppRouter _appRouter;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? MockAuthRepository();
    _propertyRepository =
        widget.propertyRepository ?? MockPropertyRepository();
    _interestRepository =
        widget.interestRepository ?? MockInterestRepository();
    _favoritesRepository =
        widget.favoritesRepository ?? MockFavoritesRepository();

    _authBloc = AuthBloc(authRepository: _authRepository);
    _propertyBloc = PropertyBloc(propertyRepository: _propertyRepository);
    _interestBloc = InterestBloc(interestRepository: _interestRepository);
    _ownerDashboardBloc = OwnerDashboardBloc(
      propertyRepository: _propertyRepository,
      interestRepository: _interestRepository,
    );
    _favoritesBloc = FavoritesBloc(favoritesRepository: _favoritesRepository);
    _appRouter = AppRouter(authBloc: _authBloc);

    _authSub = _authBloc.stream.listen((state) {
      if (state.isAuthenticated && state.user != null) {
        _favoritesBloc.add(FavoritesLoadRequested(state.user!.id));
      } else {
        _favoritesBloc.add(const FavoritesCleared());
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _appRouter.dispose();
    _authBloc.close();
    _propertyBloc.close();
    _interestBloc.close();
    _ownerDashboardBloc.close();
    _favoritesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: _authRepository),
        RepositoryProvider<PropertyRepository>.value(
          value: _propertyRepository,
        ),
        RepositoryProvider<InterestRepository>.value(
          value: _interestRepository,
        ),
        RepositoryProvider<FavoritesRepository>.value(
          value: _favoritesRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<PropertyBloc>.value(value: _propertyBloc),
          BlocProvider<InterestBloc>.value(value: _interestBloc),
          BlocProvider<OwnerDashboardBloc>.value(value: _ownerDashboardBloc),
          BlocProvider<FavoritesBloc>.value(value: _favoritesBloc),
        ],
        child: MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          routerConfig: _appRouter.router,
        ),
      ),
    );
  }
}
