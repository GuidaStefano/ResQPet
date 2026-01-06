import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:resqpet/router.dart';
import 'package:resqpet/theme.dart';
import 'firebase_options.dart';

import 'package:resqpet/core/config/stripe.dart' as stripe_config;


Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );

  Stripe.publishableKey = stripe_config.publishableKEy;

  runApp(
    ProviderScope(
      child: const MyApp()
    )
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ResQPet',
      theme: resqpetTheme,
      routerConfig: ref.read(routerProvider)
    );
  }
}