import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/constants/app_constants.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/interest_repository.dart';
import '../data/repositories/mock_auth_repository.dart';
import '../data/repositories/mock_interest_repository.dart';
import '../data/repositories/mock_property_repository.dart';
import '../data/repositories/property_repository.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/owner/bloc/owner_dashboard_bloc.dart';
import '../features/property/bloc/interest_bloc.dart';
import '../features/property/bloc/property_bloc.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class PropertyListingApp extends StatefulWidget {
  const PropertyListingApp({
    super.key,
    this.authRepository,
    this.propertyRepository,
    this.interestRepository,
  });

  final AuthRepository? authRepository;
  final PropertyRepository? propertyRepository;
  final InterestRepository? interestRepository;

  @override
  State<PropertyListingApp> createState() => _PropertyListingAppState();
}

class _PropertyListingAppState extends State<PropertyListingApp> {
  late final AuthRepository _authRepository;
  late final PropertyRepository _propertyRepository;
  late final InterestRepository _interestRepository;
  late final AuthBloc _authBloc;
  late final PropertyBloc _propertyBloc;
  late final InterestBloc _interestBloc;
  late final OwnerDashboardBloc _ownerDashboardBloc;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authRepository = widget.authRepository ?? MockAuthRepository();
    _propertyRepository =
        widget.propertyRepository ?? MockPropertyRepository();
    _interestRepository =
        widget.interestRepository ?? MockInterestRepository();

    _authBloc = AuthBloc(authRepository: _authRepository);
    _propertyBloc = PropertyBloc(propertyRepository: _propertyRepository);
    _interestBloc = InterestBloc(interestRepository: _interestRepository);
    _ownerDashboardBloc = OwnerDashboardBloc(
      propertyRepository: _propertyRepository,
      interestRepository: _interestRepository,
    );
    _appRouter = AppRouter(authBloc: _authBloc);
  }

  @override
  void dispose() {
    _appRouter.dispose();
    _authBloc.close();
    _propertyBloc.close();
    _interestBloc.close();
    _ownerDashboardBloc.close();
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
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>.value(value: _authBloc),
          BlocProvider<PropertyBloc>.value(value: _propertyBloc),
          BlocProvider<InterestBloc>.value(value: _interestBloc),
          BlocProvider<OwnerDashboardBloc>.value(value: _ownerDashboardBloc),
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
