import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/data/repository/money_transfer_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/settings.dart';

part 'money_transfer_event.dart';
part 'money_transfer_state.dart';

class MoneyTransferBloc extends Bloc<MoneyTransferEvent, MoneyTransferState> {
  MoneyTransferBloc() : super(MoneyTransferInitial()) {
    on<SendMoney>(_onSendMoney);
  }
  _onSendMoney(SendMoney event, Emitter emit) async {
    try {
      if (state is! MoneyTransferLoading) {
        emit(MoneyTransferLoading());
        final token = await getToken();

        if (token != null) {
          final res = await MoneyTransferRepository.sendMoney(
            accessToken: token,
            receiverInfo: event.receiverInfo,
            paymentId: event.paymentId,
            savedPaymentId: event.savedPaymentId,
          );
          if (res.containsKey('error')) {
            return emit(MoneyTransferFail(reason: res['error']));
          }
          emit(MoneyTransferSuccess());
        }
      }
    } on ServerException catch (error, stackTrace) {
      emit(MoneyTransferFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(MoneyTransferFail(reason: error.toString()));
    }
  }
}
