import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../core/utils/settings.dart';
import '../../data/models/transfer_rate_model.dart';
import '../../data/repository/wallet_repository.dart';

part 'transfer_rate_event.dart';
part 'transfer_rate_state.dart';

class TransferRateBloc extends Bloc<TransferRateEvent, TransferRateState> {
  final WalletRepository walletRepository;

  TransferRateBloc({required this.walletRepository})
      : super(TransferRateInitial()) {
    on<FetchTransferRate>(_onFetchTransferRate);
    on<ResetTransferRate>(_onResetTransferRate);
  }

  _onResetTransferRate(ResetTransferRate event, Emitter emit) {
    emit(TransferRateInitial());
  }

  Future<void> _onFetchTransferRate(
    FetchTransferRate event,
    Emitter<TransferRateState> emit,
  ) async {
    emit(TransferRateLoading());

    try {
      final accessToken = await getToken();
      final transferRate = await walletRepository.fetchTransferRate(
        accessToken: accessToken ?? '',
        fromWalletId: event.fromWalletId,
        toWalletId: event.toWalletId,
        amount: 0.0,
      );

      emit(TransferRateSuccess(transferRate));
    } catch (e) {
      emit(TransferRateFailure(e.toString()));
    }
  }
}
