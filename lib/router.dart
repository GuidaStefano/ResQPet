import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/di/services.dart';
import 'package:resqpet/screens/home_screen.dart';
import 'package:resqpet/screens/signin_screen.dart';
import 'package:resqpet/screens/signup_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'router.g.dart';

@immutable
class Route {
  final String name;
  final String path;

  const Route({
    required this.name,
    required this.path
  });
}

class Routes {
  static const home =  Route(name: 'home', path: '/');
  static const signIn = Route(name: 'signin', path: '/signin');
  static const signUp = Route(name: 'signup', path: '/signup');
}

class GoRouterStreamNotifier extends ChangeNotifier {
  
  late final StreamSubscription<dynamic> _subscription;
  
  GoRouterStreamNotifier(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream()
      .listen(
        (_) => notifyListeners(),
      );
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final _navigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter router(Ref ref) {

  final authService = ref.read(authServiceProvider);

  return GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: Routes.home.path,
    routes: [
      GoRoute(
        name: Routes.home.name,
        path: '/',
        builder: (context, _) => const HomeScreen()
      ),
      GoRoute(
        path: Routes.signIn.path,
        name: Routes.signIn.name,
        builder: (context, _) => const SignInScreen()
      ),
      GoRoute(
        path: Routes.signUp.path,
        name: Routes.signUp.name,
        builder: (context, _) => const SignUpScreen()
      ),
    ],
    refreshListenable: GoRouterStreamNotifier(authService.getAuthChanges()),
    redirect: (context, state) {

      final isLoggedIn = authService.currentUser != null;
      final isLoggingIn = state.matchedLocation == Routes.signIn.path
        || state.matchedLocation == Routes.signUp.path;

        if (!isLoggedIn && !isLoggingIn) {
          return Routes.signIn.path;
        }

        if (isLoggedIn && isLoggingIn) {
          return Routes.home.path;
        }
        
        return null;
    }
  );
}