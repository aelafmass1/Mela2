import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/models/payment_card_model.dart';
import 'package:transaction_mobile_app/data/repository/payment_card_repository.dart';

part 'payment_card_event.dart';
part 'payment_card_state.dart';

class PaymentCardBloc extends Bloc<PaymentCardEvent, PaymentCardState> {
  PaymentCardBloc()
      : super(PaymentCardInitial(
          paymentCards: [],
        )) {
    on<AddPaymentCard>(_onPaymentCard);
    on<FetchPaymentCards>(_onFetchPaymentCards);
  }

  _onFetchPaymentCards(FetchPaymentCards event, Emitter emit) async {
    try {
      emit(PaymentCardLoading(paymentCards: state.paymentCards));
      final accessToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final res = await PaymentCardRepository.fetchPaymentCards(
        accessToken: accessToken!,
      );
      if (res.first.containsKey('error')) {
        return emit(PaymentCardFail(
          reason: res.first['error'],
          paymentCards: state.paymentCards,
        ));
      }
      final cards = res.map((c) => PaymentCardModel.fromMap(c)).toList();

      emit(PaymentCardSuccess(
        paymentCards: cards,
      ));
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
      List<PaymentCardModel> cards = state.paymentCards;

      emit(PaymentCardLoading(paymentCards: state.paymentCards));
      final accessToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final res = await PaymentCardRepository.addPaymentCard(
        accessToken: accessToken!,
        token: event.token,
      );
      if (res.containsKey('error')) {
        return emit(PaymentCardFail(
          reason: res['error'],
          paymentCards: state.paymentCards,
        ));
      }
      final newCard = PaymentCardModel.fromMap(res);
      cards.add(newCard);

      emit(PaymentCardSuccess(
        paymentCards: cards,
      ));
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
