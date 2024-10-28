import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/repository/payment_intent_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/process_exception.dart';
import '../../core/utils/settings.dart';

part 'payment_intent_event.dart';
part 'payment_intent_state.dart';

class PaymentIntentBloc extends Bloc<PaymentIntentEvent, PaymentIntentState> {
  final PaymentIntentRepository repository;
  PaymentIntentBloc({required this.repository})
      : super(PaymentIntentInitial()) {
    on<FetchClientSecret>(_onFetchClientSecret);
  }

  /// Handles the [FetchClientSecret] event.
  ///
  /// Emits [PaymentIntentLoading], [PaymentIntentSuccess], or [PaymentIntentFail] states.
  _onFetchClientSecret(FetchClientSecret event, Emitter emit) async {
    try {
      if (state is! PaymentIntentLoading) {
        emit(PaymentIntentLoading());
        final token = await getToken();

        if (token != null) {
          final res = await repository.createPaymentIntent(
            currency: event.currency,
            amount: event.amount,
            accessToken: token,
          );
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
      }
    } on ServerException catch (error, stackTrace) {
      emit(PaymentIntentFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(PaymentIntentFail(reason: processException(error)));
    }
  }
}
