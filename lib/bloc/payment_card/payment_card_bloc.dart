import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/models/payment_card_model.dart';
import 'package:transaction_mobile_app/data/repository/payment_card_repository.dart';

import '../../core/utils/settings.dart';

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
      final token = await getToken();

      final res = await PaymentCardRepository.fetchPaymentCards(
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
      final token = await getToken();

      final res = await PaymentCardRepository.addPaymentCard(
        accessToken: token!,
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
