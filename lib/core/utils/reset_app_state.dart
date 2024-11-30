import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/bloc/wallet_transaction/wallet_transaction_bloc.dart';

import '../../bloc/payment_card/payment_card_bloc.dart';

resetAppState(BuildContext context) {
  context.read<PaymentCardBloc>().add(ResetPaymentCard());
  context.read<WalletTransactionBloc>().add(ResetWalletTransaction());
}
