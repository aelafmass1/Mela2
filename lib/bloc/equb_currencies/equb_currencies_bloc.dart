import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/repository/equb_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/process_exception.dart';
import '../../core/utils/settings.dart';

part 'equb_currencies_event.dart';
part 'equb_currencies_state.dart';

class EqubCurrenciesBloc
    extends Bloc<EqubCurrenciesEvent, EqubCurrenciesState> {
  final EqubRepository repository;
  EqubCurrenciesBloc({required this.repository})
      : super(EqubCurrenciesInitial()) {
    on<FetchEqubCurrencies>(_onFetchEqubCurrencies);
  }

  Future<void> _onFetchEqubCurrencies(
      FetchEqubCurrencies event, Emitter<EqubCurrenciesState> emit) async {
    try {
      if (state is! EqubCurrenciesLoading) {
        emit(EqubCurrenciesLoading());
        final res = await repository.fetchEqubCurrencies(
          accessToken: await getToken() ?? '',
        );
        if (res.containsKey('error')) {
          return emit(EqubCurrenciesFail(reason: res['error']));
        } else if (res.containsKey('successResponse')) {
          log(res['successResponse'].toString());
          List currencies = res['successResponse'];
          return emit(
            EqubCurrenciesSuccess(
                currencies: currencies.map((c) => c.toString()).toList()),
          );
        } else {
          emit(EqubCurrenciesFail(reason: res['error']));
        }
      }
    } on ServerException catch (error, stackTrace) {
      emit(EqubCurrenciesFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      emit(EqubCurrenciesFail(reason: processException(error)));
    }
  }
}
