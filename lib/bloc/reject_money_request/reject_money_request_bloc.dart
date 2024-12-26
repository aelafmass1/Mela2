import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils/settings.dart';
import '../../data/repository/money_transfer_repository.dart';

part 'reject_money_request_event.dart';
part 'reject_money_request_state.dart';

class RejectMoneyReuestBloc
    extends Bloc<RejectMoneyRequest, RejectMoneyRequestState> {
  final MoneyTransferRepository repository;

  RejectMoneyReuestBloc({required this.repository})
      : super(RejectMoneyRequestInitial()) {
    on<RejectMoneyRequest>(_onRejectMoneyRequest);
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
}
