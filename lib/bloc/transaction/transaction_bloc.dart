import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/data/repository/transaction_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/process_exception.dart';
import '../../core/utils/settings.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository repository;
  TransactionBloc({required this.repository}) : super(TransactionInitial()) {
    on<FetchTrasaction>(_onFetchTransaction);
  }

  /// Handles the fetching of transaction data and emits the appropriate state.
  ///
  /// This method is called when the [FetchTrasaction] event is dispatched. It
  /// first checks if the current state is not [TransactionLoading], then emits
  /// the [TransactionLoading] state. It then fetches the token and uses it to
  /// fetch the transaction data from the [TransactionRepository]. If the response
  /// contains an error, it emits the [TransactionFail] state with the error
  /// message. Otherwise, it maps the response data to a list of [ReceiverInfo]
  /// objects, groups them by the transaction date, and emits the [TransactionSuccess]
  /// state with the grouped data.
  _onFetchTransaction(FetchTrasaction event, Emitter emit) async {
    try {
      if (state is! TransactionLoading) {
        emit(TransactionLoading());
        final token = await getToken();

        final res = await repository.fetchTransaction(
          token!,
        );
        if (res.containsKey('error')) {
          return emit(TransactionFail(reason: res['error']));
        }
        final data = res['success'] as List;
        final transactions = data.map((t) => ReceiverInfo.fromMap(t)).toList();
        Map<String, List<ReceiverInfo>> groupedTransactions = {};

        for (var transaction in transactions) {
          String formattedDate = DateFormat('yyyy-MM-dd')
              .format(transaction.transactionDate ?? DateTime.now());

          if (groupedTransactions.containsKey(formattedDate)) {
            groupedTransactions[formattedDate]!.add(transaction);
          } else {
            groupedTransactions[formattedDate] = [transaction];
          }

          return emit(TransactionSuccess(
            data: groupedTransactions,
          ));
        }
        emit(TransactionSuccess(data: groupedTransactions));
      }
    } on ServerException catch (error, stackTrace) {
      emit(TransactionFail(reason: error.message));
      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    } catch (error) {
      log(error.toString());
      return emit(TransactionFail(reason: processException(error)));
    }
  }
}
