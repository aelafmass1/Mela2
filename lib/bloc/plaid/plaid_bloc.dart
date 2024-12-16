import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/models/payment_card_model.dart';
import 'package:transaction_mobile_app/data/repository/plaid_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/settings.dart';

part 'plaid_event.dart';
part 'plaid_state.dart';

class PlaidBloc extends Bloc<PlaidEvent, PlaidState> {
  final PlaidRepository repository;
  PlaidBloc({required this.repository}) : super(PlaidInitial()) {
    on<CreateLinkToken>(_onCreateLinkToken);
    on<ExchangePublicToken>(_onExchangePublicToken);
    on<AddBankAccount>(_onAddBankAccount);
  }
  _onAddBankAccount(AddBankAccount event, Emitter emit) async {
    try {
      if (state is! AddBankAccountLoading) {
        emit(AddBankAccountLoading());
        final token = await getToken();

        final res = await repository.addBankAccount(token!, event.publicToken);
        debugPrint("add payment result: ${res.toString()}");
        if (res.containsKey('error')) {
          return emit(AddBankAccountFail(reason: res['error']));
        }
        emit(AddBankAccountSuccess(
            paymentCard:
                PaymentCardModel.fromMap(res as Map<String, dynamic>)));
      }
    } on ServerException catch (error, stackTrace) {
      emit(AddBankAccountFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(AddBankAccountFail(reason: error.toString()));
    }
  }

  _onExchangePublicToken(ExchangePublicToken event, Emitter emit) async {
    try {
      if (state is! PlaidPublicTokenLoading) {
        emit(PlaidPublicTokenLoading());
        final token = await getToken();

        final res =
            await repository.exchangePublicToken(token!, event.publicToken);
        if (res.containsKey('error')) {
          return emit(PlaidPublicTokenFail(reason: res['error']));
        }
        emit(PlaidPublicTokenSuccess());
      }
    } on ServerException catch (error, stackTrace) {
      emit(PlaidPublicTokenFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(PlaidPublicTokenFail(reason: error.toString()));
    }
  }

  _onCreateLinkToken(CreateLinkToken event, Emitter emit) async {
    try {
      if (state is! PlaidLinkTokenLoading) {
        emit(PlaidLinkTokenLoading());
        final token = await getToken();

        final res = await repository.createLinkToken(token!);
        if (res.containsKey('error')) {
          return emit(PlaidLinkTokenFail(reason: res['error']));
        }
        emit(PlaidLinkTokenSuccess(linkToken: res['linkToken']));
      }
    } on ServerException catch (error, stackTrace) {
      emit(PlaidLinkTokenFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(PlaidLinkTokenFail(reason: error.toString()));
    }
  }
}
