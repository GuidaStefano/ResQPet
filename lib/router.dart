import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/di/services.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:resqpet/screens/admin_annunci_screen.dart';
import 'package:resqpet/screens/admin_reports_screen.dart';
import 'package:resqpet/screens/admin_utenti_screen.dart';
import 'package:resqpet/screens/bacheca_annunci_screen.dart';
import 'package:resqpet/screens/crea_segnalazione_screen.dart';
import 'package:resqpet/screens/home_screen.dart';
import 'package:resqpet/screens/segnalazioni_map_screen.dart';
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
  static const map = Route(name: 'map', path: '/map');
  static const adminReports = Route(name: 'admin-reports', path: '/admin/reports');
  static const adminUsers = Route(name: 'admin-users', path: '/admin/users');
  static const adminAnnunci = Route(name: 'admin-annunci', path: '/admin/annunci');
  static const creaSegnalazione = Route(name: 'crea-segnalazione', path: '/crea-segnalazione');
  static const bacheca = Route(name: 'bacheca', path: '/bacheca');
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
        path: Routes.home.path,
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
      GoRoute(
        name: Routes.map.name,
        path: Routes.map.path,
        builder: (context, _) => const SegnalazioniMapScreen()
      ),
      GoRoute(
        path: Routes.adminReports.path,
        name: Routes.adminReports.name,
        builder: (context, _) => const AdminReportsScreen() 
      ),
      GoRoute(
        path: Routes.adminUsers.path,
        name: Routes.adminUsers.name,
        builder: (context, _) => const AdminUtentiScreen() 
      ),
      GoRoute(
        path: Routes.adminAnnunci.path,
        name: Routes.adminAnnunci.name,
        builder: (context, _) => const AdminAnnunciScreen()
      ),
      GoRoute(
        path: Routes.creaSegnalazione.path,
        name: Routes.creaSegnalazione.name,
        builder: (context, _) => const CreaSegnalazioneScreen()
      ),
      GoRoute(
        path: Routes.bacheca.path, 
        name: Routes.bacheca.name,
        builder: (context, state) {
          final TipoAnnuncio? tipo = state.extra as TipoAnnuncio?;
          return BachecaAnnunciScreen(
            tipoAnnuncio: tipo,
          );
        }
      )
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