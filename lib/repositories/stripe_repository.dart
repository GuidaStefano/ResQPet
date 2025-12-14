import 'package:resqpet/services/stripe_service.dart';

class StripeRepository {
  final StripeService _stripe;

  StripeRepository(this._stripe);

  Future<void> creaSessioneCheckout(String amount) async {
    await _stripe.createPayment(amount);
  }

  Future<StripePaymentStatus> effettuaPagamento() async {
    final status = await _stripe.makePayment();
    return status;
  }
}