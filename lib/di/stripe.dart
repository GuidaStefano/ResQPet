import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stripe.g.dart';

@riverpod
Stripe stripe(Ref ref) {
  return Stripe.instance;
}