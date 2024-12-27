import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/models/payment_card_model.dart';
import 'package:transaction_mobile_app/data/repository/payment_card_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/settings.dart';

part 'payment_card_event.dart';
part 'payment_card_state.dart';

class PaymentCardBloc extends Bloc<PaymentCardEvent, PaymentCardState> {
  final PaymentCardRepository repository;
  PaymentCardBloc({required this.repository})
      : super(PaymentCardInitial(
          paymentCards: [],
        )) {
    on<AddPaymentCard>(_onPaymentCard);
    on<FetchPaymentCards>(_onFetchPaymentCards);
    on<ResetPaymentCard>(_onResetPaymentCard);
    on<AddBankAccount>(_onAddBankAccount);
  }

  _onAddBankAccount(AddBankAccount event, Emitter emit) async {
    try {
      if (state is! PaymentCardLoading) {
        emit(PaymentCardLoading(paymentCards: state.paymentCards));
        final res = await repository.addBankAccount(event.publicToken);

        if (res.containsKey('error')) {
          return emit(PaymentCardFail(
              paymentCards: state.paymentCards, reason: res['error']));
        }
        emit(PaymentCardSuccess(
          paymentCards: [
            ...state.paymentCards,
            PaymentCardModel.fromMap(res as Map<String, dynamic>)
          ],
          addedNewCard: true,
        ));
      }
    } on ServerException catch (error, stackTrace) {
      emit(PaymentCardFail(
          paymentCards: state.paymentCards, reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(PaymentCardFail(
          paymentCards: state.paymentCards, reason: error.toString()));
    }
  }

  _onResetPaymentCard(ResetPaymentCard event, Emitter emit) {
    emit(PaymentCardInitial(
      paymentCards: [],
    ));
  }

  _onFetchPaymentCards(FetchPaymentCards event, Emitter emit) async {
    try {
      if (state is! PaymentCardLoading) {
        emit(PaymentCardLoading(paymentCards: state.paymentCards));
        final token = await getToken();
        debugPrint('Token: $token');
        final res = await repository.fetchPaymentCards(
          accessToken: token!,
        );
        if (res.isNotEmpty) {
          if (res.first.containsKey('error')) {
            return emit(PaymentCardFail(
              reason: res.first['error'],
              paymentCards: state.paymentCards,
            ));
          }
          final cards = res
              .map((c) => PaymentCardModel.fromMap(c as Map<String, dynamic>))
              .toList();

          emit(PaymentCardSuccess(
            paymentCards: cards,
          ));
        } else {
          emit(PaymentCardSuccess(
            paymentCards: state.paymentCards,
          ));
        }
      }
    } on ServerException catch (error, stackTrace) {
      emit(PaymentCardFail(
        reason: error.message,
        paymentCards: state.paymentCards,
      ));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(
        PaymentCardFail(
          reason: error.toString(),
          paymentCards: state.paymentCards,
        ),
      );
    }
  }

  _onPaymentCard(AddPaymentCard event, Emitter emit) async {
    try {
      if (state is! PaymentCardLoading) {
        emit(PaymentCardLoading(paymentCards: state.paymentCards));

        if (event.token == null) {
          return emit(PaymentCardFail(
            reason: "Missing token",
            paymentCards: state.paymentCards,
          ));
        }
        final res = await repository.addPaymentCard(
          token: event.token!,
        );
        if (res.containsKey('error')) {
          return emit(PaymentCardFail(
            reason: res['error'],
            paymentCards: state.paymentCards,
          ));
        }

        emit(PaymentCardSuccess(
          paymentCards: [
            ...state.paymentCards,
            PaymentCardModel.fromMap(res as Map<String, dynamic>)
          ],
          addedNewCard: true,
        ));
      }
    } on ServerException catch (error, stackTrace) {
      emit(PaymentCardFail(
          reason: error.message, paymentCards: state.paymentCards));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } on StripeException catch (stripe) {
      log(state.toString());
      emit(
        PaymentCardFail(
          reason: stripe.error.message ??
              'Failed to process card. Please try again.',
          paymentCards: state.paymentCards,
        ),
      );
    } catch (error) {
      log(error.toString());
      emit(
        PaymentCardFail(
          reason: error.toString(),
          paymentCards: state.paymentCards,
        ),
      );
    }
  }
}
