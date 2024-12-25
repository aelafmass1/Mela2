import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/money_request_model.dart';
import 'package:transaction_mobile_app/data/repository/money_transfer_repository.dart';

part 'money_request_event.dart';
part 'money_request_state.dart';

class MoneyRequestBloc extends Bloc<MoneyRequestEvent, MoneyRequestState> {
  final MoneyTransferRepository repository;
  MoneyRequestBloc({required this.repository}) : super(MoneyRequestInitial()) {
    on<MoneyRequest>(_onMoneyRequest);
    on<FetchMoneyRequestDetail>(_onFetchMoneyRequestDetail);
    on<RejectMoneyRequest>(_onRejectMoneyRequest);
    on<MoneyRequestToUnregisteredUser>(_onMoneyRequestToUnregisteredUser);

  }

  _onRejectMoneyRequest(RejectMoneyRequest event, Emitter emit) async {
    try {
      if (state is! RejectMoneyRequestLoading) {
        emit(RejectMoneyRequestLoading());
        final accessToken = await getToken();
        final res = await repository.rejectRequestMoney(
          accessToken: accessToken ?? '',
          requestId: event.requestId,
        );
        if (res.containsKey("error")) {
          return emit(
            RejectMoneyRequestFail(reason: res['error']),
          );
        }
        emit(RejectMoneyRequestSuccess());
      }
    } catch (e) {
      emit(RejectMoneyRequestFail(reason: e.toString()));
    }
  }

  _onFetchMoneyRequestDetail(
      FetchMoneyRequestDetail event, Emitter emit) async {
    try {
      if (state is! FetchMoneyRequestLoading) {
        emit(FetchMoneyRequestLoading());
        final accessToken = await getToken();
        final res = await repository.fetchRequestMoneyDetail(
          accessToken: accessToken ?? '',
          requestId: event.requestId,
        );
        if (res.containsKey("error")) {
          return emit(
            FetchMoneyRequestFail(reason: res['error']),
          );
        }
        final req = MoneyRequestModel.fromMap(res['successResponse']);
        emit(FetchMoneyRequestSuccess(
          moneyRequestModel: req,
        ));
      }
    } catch (e) {
      emit(
        FetchMoneyRequestFail(reason: e.toString()),
      );
    }
  }

  _onMoneyRequest(MoneyRequest event, Emitter emit) async {
    try {
      if (state is! MoneyRequestLoading) {
        emit(MoneyRequestLoading());
        final accessToken = await getToken();
        final res = await repository.requestMoney(
          accessToken: accessToken ?? '',
          requesterWalletId: event.requesterWalletId,
          amount: event.amount,
          note: event.note,
          userId: event.userId,
        );
        if (res.containsKey("error")) {
          return emit(
            MoneyRequestFailure(reason: res['error']),
          );
        }
        emit(MoneyRequestSuccess(id: res['successResponse']['id']));
      }
    } catch (e) {
      emit(
        MoneyRequestFailure(reason: e.toString()),
      );
    }
  }
  _onMoneyRequestToUnregisteredUser(MoneyRequestToUnregisteredUser event, Emitter emit) async {
    try {
      if (state is! MoneyRequestLoading) {
        emit(MoneyRequestLoading());
        final res = await repository.requestMoneyToUnregisteredUser(
          requesterWalletId: event.requesterWalletId,
          amount: event.amount,
          note: event.note,
          recipientPhoneNumber: event.recipientPhoneNumber,
        );
        if (res.containsKey("error")) {
          return emit(
            MoneyRequestFailure(reason: res['error']),
          );
        }
        emit(MoneyRequestSuccess(id: res['successResponse']['id']));
      }
    } catch (e) {
      emit(
        MoneyRequestFailure(reason: e.toString()),
      );
    }
  }
}
