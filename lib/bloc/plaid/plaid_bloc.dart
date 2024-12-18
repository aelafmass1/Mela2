import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:transaction_mobile_app/data/repository/plaid_repository.dart';

import '../../core/exceptions/server_exception.dart';
import '../../core/utils/settings.dart';

part 'plaid_event.dart';
part 'plaid_state.dart';

class PlaidBloc extends Bloc<PlaidEvent, PlaidState> {
  final PlaidRepository repository;
  PlaidBloc({required this.repository}) : super(PlaidInitial()) {
    on<CreateLinkToken>(_onCreateLinkToken);
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
        var linkToken = res['linkToken'];
        emit(PlaidLinkTokenSuccess(linkToken: linkToken));

        var cofiguration = LinkTokenConfiguration(
          token: linkToken,
        );
        await PlaidLink.create(configuration: cofiguration);
        await PlaidLink.open();
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
