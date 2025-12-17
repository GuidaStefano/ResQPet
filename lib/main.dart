import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:resqpet/screens/signin_screen.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResQPet',
      theme: resqpetTheme,
      home: const SignInScreen(),
    );
  }
}