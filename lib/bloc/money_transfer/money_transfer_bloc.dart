import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/data/repository/money_transfer_repository.dart';

part 'money_transfer_event.dart';
part 'money_transfer_state.dart';

class MoneyTransferBloc extends Bloc<MoneyTransferEvent, MoneyTransferState> {
  final FirebaseAuth auth;
  MoneyTransferBloc({required this.auth}) : super(MoneyTransferInitial()) {
    on<SendMoney>(_onSendMoney);
  }
  _onSendMoney(SendMoney event, Emitter emit) async {
    try {
      emit(MoneyTransferLoading());
      final token = await auth.currentUser?.getIdToken();
      if (token != null) {
        final res = await MoneyTransferRepository.sendMoney(
          accessToken: token,
          receiverInfo: event.receiverInfo,
          paymentId: event.paymentId,
        );
        if (res.containsKey('error')) {
          return emit(MoneyTransferFail(reason: res['error']));
        }
        emit(MoneyTransferSuccess());
      }
    } catch (error) {
      log(error.toString());
      emit(MoneyTransferFail(reason: error.toString()));
    }
  }
}
