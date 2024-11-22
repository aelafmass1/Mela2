import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/wallet_model.dart';
import 'package:transaction_mobile_app/data/repository/wallet_repository.dart';

import '../../data/models/wallet_transaction_model.dart';

part 'wallet_event.dart';
part 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository repository;
  WalletBloc({required this.repository})
      : super(WalletState(
          wallets: [],
        )) {
    on<FetchWallets>(_onFetchWallets);
    on<CreateWallet>(_onCreateWallet);
    on<AddFundToWallet>(_onAddFundToWallet);
  }

  _onAddFundToWallet(AddFundToWallet event, Emitter emit) async {
    try {
      if (state is! AddFundToWalletLoading) {
        emit(
          AddFundToWalletLoading(
            wallets: state.wallets,
          ),
        );
        final accessToken = await getToken();
        final res = await repository.addFundToWallet(
          accessToken: accessToken ?? '',
          amount: event.amount,
          paymentIntentId: event.paymentIntentId,
          paymentType: event.paymentType,
          publicToken: event.publicToken,
          savedPaymentId: event.savedPaymentId,
          walletId: event.walletId,
        );
        if (res.containsKey('error')) {
          return emit(
            AddFundToWalletFail(wallets: state.wallets, reason: res['error']),
          );
        }
        final data = res['successResponse'];
        final walletTransaction = WalletTransactionModel(
          fromWalletId: data['walletId'],
          toWalletId: data['walletId'],
          transactionId: data['transactionId'],
          fromWalletBalance: null,
          amount: data['balance'],
          transactionType: data['transactionType'],
          timestamp: DateTime.parse(data['transactionTimestamp']),
          note: '',
        );

        emit(
          AddFundToWalletSuccess(
            walletTransactionModel: walletTransaction,
            wallets: state.wallets,
          ),
        );
      }
    } catch (error) {
      emit(
        AddFundToWalletFail(
          wallets: state.wallets,
          reason: error.toString(),
        ),
      );
    }
  }

  _onCreateWallet(CreateWallet event, Emitter emit) async {
    try {
      if (state is! CreateWalletLoading) {
        List<WalletModel> wallets = state.wallets;
        emit(
          CreateWalletLoading(
            wallets: state.wallets,
          ),
        );
        final accessToken = await getToken();
        final res = await repository.createWallet(
          accessToken: accessToken ?? '',
          currency: event.currency,
        );
        if (res.containsKey('error')) {
          return emit(
            CreateWalletFail(wallets: state.wallets, reason: res['error']),
          );
        }
        final newWallet = WalletModel.fromMap((res['successResponse']));
        wallets.add(newWallet);
        emit(
          CreateWalletSuccess(
            wallets: wallets,
          ),
        );
      }
    } catch (error) {
      emit(
        CreateWalletFail(
          wallets: state.wallets,
          reason: error.toString(),
        ),
      );
    }
  }

  _onFetchWallets(FetchWallets event, Emitter emit) async {
    try {
      if (state is! FetchWalletsLoading) {
        emit(
          FetchWalletsLoading(
            wallets: state.wallets,
          ),
        );
        final accessToken = await getToken();
        final res = await repository.fetchWallets(
          accessToken: accessToken ?? '',
        );
        if (res.containsKey('error')) {
          return emit(
            FetchWalletsFail(wallets: state.wallets, reason: res['error']),
          );
        }
        final wallets = res['successResponse'] as List;

        emit(
          FetchWalletSuccess(
            wallets: wallets.map((w) => WalletModel.fromMap(w)).toList(),
          ),
        );
      }
    } catch (error) {
      emit(
        FetchWalletsFail(
          wallets: state.wallets,
          reason: error.toString(),
        ),
      );
    }
  }
}
