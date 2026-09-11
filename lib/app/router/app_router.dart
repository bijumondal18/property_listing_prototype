import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/app_user.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/owner/presentation/owner_home_screen.dart';
import '../../features/owner/presentation/property_form_screen.dart';
import '../../features/property/presentation/interest_form_screen.dart';
import '../../features/property/presentation/property_details_screen.dart';
import '../../features/user/presentation/user_home_screen.dart';

class AppRouter {
  AppRouter({required this._authBloc});

  final AuthBloc _authBloc;
  late final GoRouterRefreshStream _refreshListenable =
      GoRouterRefreshStream(_authBloc.stream);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _refreshListenable,
    redirect: (context, state) {
      final authState = _authBloc.state;
      final loc = state.matchedLocation;
      final onAuthScreen = loc == '/login' || loc == '/signup';
      final isAuthenticated = authState.isAuthenticated;
      final user = authState.user;

      if (!isAuthenticated) {
        return onAuthScreen ? null : '/login';
      }

      if (onAuthScreen) {
        return user!.role == UserRole.propertyOwner
            ? '/owner/home'
            : '/user/home';
      }

      if (user!.role == UserRole.user && loc.startsWith('/owner')) {
        return '/user/home';
      }
      if (user.role == UserRole.propertyOwner && loc.startsWith('/user')) {
        return '/owner/home';
      }
      if (user.role == UserRole.propertyOwner && loc.contains('/interest')) {
        return '/owner/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/user/home',
        builder: (context, state) => const UserHomeScreen(),
      ),
      GoRoute(
        path: '/owner/home',
        builder: (context, state) => const OwnerHomeScreen(),
      ),
      GoRoute(
        path: '/owner/property/add',
        builder: (context, state) => const PropertyFormScreen(),
      ),
      GoRoute(
        path: '/owner/property/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PropertyFormScreen(propertyId: id);
        },
      ),
      GoRoute(
        path: '/property/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PropertyDetailsScreen(propertyId: id);
        },
        routes: [
          GoRoute(
            path: 'interest',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return InterestFormScreen(propertyId: id);
            },
          ),
        ],
      ),
    ],
  );

  void dispose() {
    _refreshListenable.dispose();
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<AuthState> stream) {
    _wasAuthenticated = false;
    _subscription = stream.listen((state) {
      final authenticated = state.isAuthenticated;
      if (authenticated == _wasAuthenticated) return;
      _wasAuthenticated = authenticated;

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!_disposed) notifyListeners();
      });
    });
  }

  late final StreamSubscription<AuthState> _subscription;
  bool _wasAuthenticated = false;
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _subscription.cancel();
    super.dispose();
  }
}
