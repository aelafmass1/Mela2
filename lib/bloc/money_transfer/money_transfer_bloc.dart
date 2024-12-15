import 'dart:async';
import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/data/models/wallet_transaction_model.dart';
import 'package:transaction_mobile_app/data/repository/money_transfer_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/settings.dart';

part 'money_transfer_event.dart';
part 'money_transfer_state.dart';

class MoneyTransferBloc extends Bloc<MoneyTransferEvent, MoneyTransferState> {
  final MoneyTransferRepository repository;
  MoneyTransferBloc({required this.repository})
      : super(MoneyTransferInitial()) {
    on<SendMoney>(_onSendMoney);
    on<TransferToWallet>(_onTransferToOwnWallet);
    on<TransferToUnregisteredUser>(_onTransferToUnregisteredUser);
  }

  _onTransferToUnregisteredUser(
      TransferToUnregisteredUser event, Emitter emit) async {
    try {
      if (state is! MoneyTransferLoading) {
        emit(MoneyTransferLoading());
        final token = await getToken();

        if (token != null) {
          final res = await repository.transferToUnregisteredUser(
            accessToken: token,
            amount: event.amount,
            recipientPhoneNumber: event.phoneNumber,
            senderWalletId: event.senderWalletId,
          );
          if (res.containsKey('error')) {
            return emit(MoneyTransferFail(reason: res['error']));
          }
          res["name"] = event.name;
          final walletTransaction =
              WalletTransactionModel.fromMap(res['successResponse'] as Map);
          emit(MoneyTransferUnregisteredUserSuccess(
            walletTransactionModel: walletTransaction,
          ));
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

  _onSendMoney(SendMoney event, Emitter emit) async {
    try {
      if (state is! MoneyTransferLoading) {
        emit(MoneyTransferLoading());
        final token = await getToken();

        if (token != null) {
          final res = await repository.sendMoney(
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

  FutureOr<void> _onTransferToOwnWallet(
      TransferToWallet event, Emitter<MoneyTransferState> emit) async {
    try {
      if (state is! MoneyTransferLoading) {
        emit(MoneyTransferLoading());
        final token = await getToken();

        final res = await repository.transferToOwnWallet(
          accessToken: token ?? '',
          fromWalletId: event.fromWalletId,
          toWalletId: event.toWalletId,
          amount: event.amount,
          note: event.note,
        );
        if (res.containsKey('error')) {
          return emit(MoneyTransferFail(reason: res['error']));
        }
        final walletTransaction =
            WalletTransactionModel.fromMap(res['successResponse'] as Map);
        emit(MoneyTransferOwnWalletSuccess(
          walletTransactionModel: walletTransaction,
        ));
      }
    } on ServerException catch (error, stackTrace) {
      emit(MoneyTransferFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      final errorMessage = (error as Map)['errorMessage'];
      emit(MoneyTransferFail(reason: errorMessage));
    }
  }
}
