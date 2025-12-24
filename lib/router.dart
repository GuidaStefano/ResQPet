import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resqpet/di/services.dart';
import 'package:resqpet/models/annuncio/annuncio.dart';
import 'package:resqpet/models/annuncio/tipo_annuncio.dart';
import 'package:resqpet/models/utente.dart';
import 'package:resqpet/screens/admin_annunci_screen.dart';
import 'package:resqpet/screens/admin_reports_screen.dart';
import 'package:resqpet/screens/admin_utenti_screen.dart';
import 'package:resqpet/screens/annuncio_form_screen.dart';
import 'package:resqpet/screens/bacheca_annunci_screen.dart';
import 'package:resqpet/screens/crea_ente_screen.dart';
import 'package:resqpet/screens/crea_segnalazione_screen.dart';
import 'package:resqpet/screens/dettagli_annuncio_screen.dart';
import 'package:resqpet/screens/home_screen.dart';
import 'package:resqpet/screens/segnalazioni_in_carico_screen.dart';
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
  static const adminRegistraEnte = Route(name: 'admin-registra-ente', path: '/admin/new-ente');
  static const creaSegnalazione = Route(name: 'crea-segnalazione', path: '/crea-segnalazione');
  static const bacheca = Route(name: 'bacheca', path: '/bacheca');
  static const dettagliAnnuncio = Route(name: 'annuncio', path: '/annuncio');
  static const segnalazioniInCarico = Route(name: 'in-carico', path: '/segnalazioni/inCarico');
  static const creaAnnuncio = Route(name: 'crea-annuncio', path: '/crea-annuncio/:tipo');
  static const aggiornaAnnuncio = Route(name: 'aggiorna-annuncio', path: '/aggiorna-annuncio/:tipo');
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
        path: Routes.segnalazioniInCarico.path,
        name: Routes.segnalazioniInCarico.name,
        builder: (context, _) => const SegnalazioniInCaricoScreen()
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
        path: Routes.adminRegistraEnte.path,
        name: Routes.adminRegistraEnte.name,
        builder: (context, _) => const CreaEnteScreen()
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
      ),
      GoRoute(
        path: Routes.dettagliAnnuncio.path, 
        name: Routes.dettagliAnnuncio.name,
        builder: (context, state) {
          final  data = state.extra as Map<String, dynamic>?;
          return DettagliAnnuncioScreen(
            annuncio: data!['annuncio'] as Annuncio,
            creatore: data['creatore'] as Utente
          );
        }
      ),
      GoRoute(
        path: Routes.creaAnnuncio.path, 
        name: Routes.creaAnnuncio.name,
        builder: (context, state) {
          final tipo = TipoAnnuncio.fromString(state.pathParameters['tipo']!);
          return AnnuncioFormScreen(tipoAnnuncio: tipo);
        }
      ),
      GoRoute(
        path: Routes.aggiornaAnnuncio.path, 
        name: Routes.aggiornaAnnuncio.name,
        builder: (context, state) {
          final tipo = TipoAnnuncio.fromString(state.pathParameters['tipo']!);
          final annuncio = state.extra as Annuncio;
          return AnnuncioFormScreen(
            tipoAnnuncio: tipo,
            annuncio: annuncio
          );
        }
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