import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/wallet/wallet_bloc.dart';
import '../../../../core/utils/show_change_wallet_modal.dart';
import '../../../../data/models/wallet_model.dart';

class TransferAppBar extends StatefulWidget {
  const TransferAppBar({
    super.key,
    this.onWalletChanged,
  });
  final Function(int selectedWallet)? onWalletChanged;

  @override
  State<TransferAppBar> createState() => TransferAppBarState();
}

class TransferAppBarState extends State<TransferAppBar> {
  WalletModel? selectedWalletModel;

  @override
  void initState() {
    final state = context.read<WalletBloc>().state;

    selectedWalletModel = state.wallets[0];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      centerTitle: true,
      title: BlocListener<WalletBloc, WalletState>(
        listener: (BuildContext context, WalletState state) {
          selectedWalletModel = state.wallets[0];
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextWidget(
              text: '\$${selectedWalletModel?.balance ?? 0}',
              fontSize: 15,
              weight: FontWeight.bold,
            ),
            InkWell(
              onTap: () async {
                final selectedWallet =
                    await showChangeWalletModal(context: context);
                if (selectedWallet != null) {
                  setState(() {
                    selectedWalletModel = selectedWallet;
                  });
                  widget.onWalletChanged?.call(selectedWallet.walletId);
                }
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextWidget(
                    text:
                        " ${selectedWalletModel?.currency.code ?? 'USD'} Wallet",
                    fontSize: 15,
                    color: ColorName.grey,
                  ),
                  const Icon(Icons.keyboard_arrow_down)
                ],
              ),
            ),
          ],
        ),
      ),
      leading: IconButton(
        icon: SvgPicture.asset(Assets.images.svgs.backArrow),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }
}
