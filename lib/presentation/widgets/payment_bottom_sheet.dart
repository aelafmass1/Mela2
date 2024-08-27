import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentBottomSheet extends StatefulWidget {
  @override
  _PaymentBottomSheetState createState() => _PaymentBottomSheetState();
}

class _PaymentBottomSheetState extends State<PaymentBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  CardFieldInputDetails? _card;

  Future<void> _handlePayment(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      try {
        final auth = FirebaseAuth.instance;
        if (auth.currentUser != null && _card != null) {
          final paymentMethod = await Stripe.instance.createPaymentMethod(
            params: PaymentMethodParams.card(
              paymentMethodData: PaymentMethodData(
                billingDetails: BillingDetails(
                  name: auth.currentUser?.displayName,
                  email: auth.currentUser?.email,
                ),
              ),
            ),
          );

          final paymentMethodId = paymentMethod.id;
          Navigator.pop(context, paymentMethodId);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid payment details.')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your payment information',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            CardField(
              onCardChanged: (card) {
                // setState(() {
                //   _card = card;
                // });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handlePayment(context),
              child: const Text('Pay Now'),
            ),
          ],
        ),
      ),
    );
  }
}

void showPaymentBottomSheet(BuildContext context) async {
  final paymentMethodId = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) {
      return PaymentBottomSheet();
    },
  );

  if (paymentMethodId != null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Method ID: $paymentMethodId')),
    );
  }
}
