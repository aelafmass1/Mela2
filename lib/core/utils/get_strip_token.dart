import 'dart:developer';

import 'package:flutter_stripe/flutter_stripe.dart';

Future<String?> getStripeToken() async {
  try {
    final token = await Stripe.instance.createToken(
      const CreateTokenParams.card(
        params: CardTokenParams(
          type: TokenType.Card,
        ),
      ),
    );
    return token.id;
  } catch (e) {
    log('Error creating token: $e');
    return null;
  }
}
