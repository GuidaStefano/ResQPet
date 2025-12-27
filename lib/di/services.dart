import 'package:resqpet/di/firebase.dart';
import 'package:resqpet/di/stripe.dart';
import 'package:resqpet/services/auth_service.dart';
import 'package:resqpet/services/cloud_storage_service.dart';
import 'package:resqpet/services/stripe_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'services.g.dart';

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) {
  final firebaseAuth = ref.read(firebaseAuthProvider);
  return AuthService(firebaseAuth);
}

@Riverpod(keepAlive: true)
CloudStorageService cloudStorageService(Ref ref) {
  final firebaseStorage = ref.read(firebaseStorageProvider);
  return CloudStorageService(firebaseStorage);
}

@Riverpod(keepAlive: true)
StripeService stripeService(Ref ref) {
  final stripe = ref.read(stripeProvider);
  return StripeService(stripe);
}