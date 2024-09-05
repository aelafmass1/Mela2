import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/data/repository/plaid_repository.dart';

part 'plaid_event.dart';
part 'plaid_state.dart';

class PlaidBloc extends Bloc<PlaidEvent, PlaidState> {
  PlaidBloc() : super(PlaidInitial()) {
    on<CreateLinkToken>(_onCreateLinkToken);
    on<ExchangePublicToken>(_onExchangePublicToken);
  }
  _onExchangePublicToken(ExchangePublicToken event, Emitter emit) async {
    try {
      emit(PlaidPublicTokenLoading());
      final accessToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final res = await PlaidRepository.exchangePublicToken(
          accessToken!, event.publicToken);
      if (res.containsKey('error')) {
        return emit(PlaidPublicTokenFail(reason: res['error']));
      }
      emit(PlaidPublicTokenSuccess());
    } catch (error) {
      log(error.toString());
      emit(PlaidPublicTokenFail(reason: error.toString()));
    }
  }

  _onCreateLinkToken(CreateLinkToken event, Emitter emit) async {
    try {
      emit(PlaidLinkTokenLoading());
      final accessToken = await FirebaseAuth.instance.currentUser?.getIdToken();
      final res = await PlaidRepository.createLinkToken(accessToken!);
      if (res.containsKey('error')) {
        return emit(PlaidLinkTokenFail(reason: res['error']));
      }
      emit(PlaidLinkTokenSuccess(linkToken: res['linkToken']));
    } catch (error) {
      log(error.toString());
      emit(PlaidLinkTokenFail(reason: error.toString()));
    }
  }
}
