import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/repository/plaid_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/settings.dart';

part 'plaid_event.dart';
part 'plaid_state.dart';

class PlaidBloc extends Bloc<PlaidEvent, PlaidState> {
  PlaidBloc() : super(PlaidInitial()) {
    on<CreateLinkToken>(_onCreateLinkToken);
    on<ExchangePublicToken>(_onExchangePublicToken);
  }
  _onExchangePublicToken(ExchangePublicToken event, Emitter emit) async {
    try {
      if (state is! PlaidPublicTokenLoading) {
        emit(PlaidPublicTokenLoading());
        final token = await getToken();

        final res = await PlaidRepository.exchangePublicToken(
            token!, event.publicToken);
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

        final res = await PlaidRepository.createLinkToken(token!);
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
