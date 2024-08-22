import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/data/repository/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc() : super(TransactionInitial()) {
    on<FetchTrasaction>(_onFetchTransaction);
  }

  _onFetchTransaction(FetchTrasaction event, Emitter emit) async {
    try {
      emit(TransactionLoading());
      final auth = FirebaseAuth.instance;
      if (auth.currentUser != null) {
        final accessToken = await auth.currentUser!.getIdToken();

        final res = await TransactionRepository.fetchTransaction(
          accessToken!,
          auth.currentUser!.uid,
        );
        if (res.containsKey('error')) {
          emit(TransactionFail(error: res['error']));
        }
        final data = res['success'] as List;
        final transactions = data.map((t) => ReceiverInfo.fromMap(t)).toList();
        Map<String, List<ReceiverInfo>> groupedTransactions = {};

        for (var transaction in transactions) {
          String formattedDate = DateFormat('yyyy-MM-dd')
              .format(transaction.trasactionDate ?? DateTime.now());

          if (groupedTransactions.containsKey(formattedDate)) {
            groupedTransactions[formattedDate]!.add(transaction);
          } else {
            groupedTransactions[formattedDate] = [transaction];
          }
        }

        return emit(TransactionSuccess(
          data: groupedTransactions,
        ));
      }
    } catch (error) {
      log(error.toString());
      return emit(TransactionFail(error: error.toString()));
    }
  }
}
