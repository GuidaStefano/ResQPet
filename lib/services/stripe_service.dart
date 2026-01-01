import 'dart:convert';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:resqpet/core/config/stripe.dart' as stripe_config;

sealed class StripePaymentStatus {
  StripePaymentStatus();

  factory StripePaymentStatus.success() = StripePaymentSuccess;
  factory StripePaymentStatus.error(StripeException e) = StripePaymentError;
}

final class StripePaymentSuccess extends StripePaymentStatus {}

final class StripePaymentError extends StripePaymentStatus {
  final StripeException exception;
  StripePaymentError(this.exception);
}

class StripeService {
  
  final Stripe _stripe;

  StripeService(this._stripe);

  Future<void> createPayment(double amount, [String currency = 'EUR']) async {

    final paymentIntent = await _createPaymentIntent(
      (amount * 100).round().toString(),
      currency
    );

    await _stripe.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        customFlow: false,
        paymentIntentClientSecret: paymentIntent['client_secret'],
        googlePay: PaymentSheetGooglePay(
          testEnv: true,
          currencyCode: currency,
          merchantCountryCode: 'IT',
        ),
        merchantDisplayName: stripe_config.merchantName
      )
    );
  }

  Future<StripePaymentStatus> makePayment() async {
    try{
      await _stripe.presentPaymentSheet();
      return StripePaymentStatus.success();
    } on StripeException catch(e) {
      return StripePaymentStatus.error(e);
    }
  }

  Future<Map<String, dynamic>> _createPaymentIntent(String amount, String currency) async {
    
    final body = {
      'amount': amount,
      'currency': currency
    };

    final response = await http.post(
      Uri.parse(stripe_config.paymentIntentApiEndPoint), 
      headers: {
        'Authorization': 'Bearer ${stripe_config.secretKey}',
        'Content-Type': 'application/x-www-form-urlencoded'
      },
      body: body
    );
    
    return jsonDecode(response.body);
  }
}