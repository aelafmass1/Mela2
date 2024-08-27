import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/repository/payment_intent_repository.dart';

part 'payment_intent_event.dart';
part 'payment_intent_state.dart';

class PaymentIntentBloc extends Bloc<PaymentIntentEvent, PaymentIntentState> {
  PaymentIntentBloc() : super(PaymentIntentInitial()) {
    on<FetchClientSecret>(_onFetchClientSecret);
  }

  /// Handles the [FetchClientSecret] event.
  ///
  /// Emits [PaymentIntentLoading], [PaymentIntentSuccess], or [PaymentIntentFail] states.
  _onFetchClientSecret(FetchClientSecret event, Emitter emit) async {
    try {
      emit(PaymentIntentLoading());
      final accessToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      if (accessToken != null) {
        final res = await PaymentIntentRepository.createPaymentIntent(
            currency: event.currency,
            amount: event.amount,
            accessToken: accessToken);
        if (res.containsKey('error')) {
          return emit(PaymentIntentFail(reason: res['error']));
        }
        emit(
          PaymentIntentSuccess(
              clientSecret: res['clientSecret'],
              customerId: res['stripeCustomerId']),
        );
      } else {
        emit(PaymentIntentFail(reason: 'Please login first'));
      }
    } catch (error) {
      log(error.toString());
      emit(PaymentIntentFail(reason: error.toString()));
    }
  }
}
