import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/core/utils/show_wallet_receipt.dart';
import 'package:transaction_mobile_app/data/models/transfer_fees_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/check-details-bloc/check_details_bloc.dart';
import '../../../../bloc/money_transfer/money_transfer_bloc.dart';
import '../../../../bloc/transfer-rate/transfer_rate_bloc.dart';
import '../../../../bloc/wallet/wallet_bloc.dart';
import '../../../../bloc/wallet_transaction/wallet_transaction_bloc.dart';
import '../../../../core/utils/show_change_wallet_modal.dart';
import '../../../../data/models/wallet_model.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../widgets/card_widget.dart';
import '../../../widgets/custom_shimmer.dart';
import '../../../widgets/text_field_widget.dart';

class SendMoneyScreen extends StatefulWidget {
  const SendMoneyScreen({super.key});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  int selectedWalletIndex = -1;
  final amountController = TextEditingController();

  final noteController = TextEditingController();

  final amountFocusNode = FocusNode();

  WalletModel? transferFromWalletModel;

  int transferToWalletId = -1;
  bool showDetail = false;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    amountController.dispose();
    amountFocusNode.dispose();

    super.dispose();
  }

  @override
  void initState() {
    final wallets = context.read<WalletBloc>().state.wallets;
    if (wallets.isNotEmpty) {
      final w = wallets.where((w) => w.currency.code == "USD");
      if (w.isEmpty) {
        setState(() {
          transferFromWalletModel = wallets.first;
        });
      } else {
        setState(() {
          transferFromWalletModel = w.first;
        });
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: _buildChangeWallet(),
        toolbarHeight: 70,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildTransferToSection(),
                  _buildEnterAmountSelection(),
                  _buildNoteSection(),
                  _buildCheckDetail(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: ButtonWidget(
              onPressed: (showDetail == false && transferToWalletId == -1)
                  ? null
                  : () {
                      if (showDetail == false) {
                        if (transferFromWalletModel?.walletId != null) {
                          context
                              .read<TransferRateBloc>()
                              .add(FetchTransferRate(
                                fromWalletId: transferFromWalletModel!.walletId,
                                toWalletId: transferToWalletId,
                              ));
                          context.read<CheckDetailsBloc>().add(
                                FetchTransferFeesEvent(
                                  fromWalletId:
                                      transferFromWalletModel!.walletId,
                                  toWalletId: transferToWalletId,
                                ),
                              );
                        }
                      } else {
                        if (_formKey.currentState?.validate() == true) {
                          context.read<MoneyTransferBloc>().add(
                                TransferToWallet(
                                  fromWalletId:
                                      transferFromWalletModel?.walletId ?? 0,
                                  toWalletId: transferToWalletId,
                                  amount:
                                      double.tryParse(amountController.text) ??
                                          0,
                                  note: noteController.text,
                                ),
                              );
                        }
                      }
                    },
              child: BlocConsumer<MoneyTransferBloc, MoneyTransferState>(
                listener: (context, state) {
                  if (state is MoneyTransferOwnWalletSuccess) {
                    context.pop();

                    context.read<WalletBloc>().add(FetchWallets());
                    context
                        .read<WalletTransactionBloc>()
                        .add(FetchWalletTransaction());

                    showWalletReceipt(
                      context,
                      state.walletTransactionModel!,
                    );
                  } else if (state is MoneyTransferFail) {
                    showSnackbar(
                      context,
                      description: state.reason,
                    );
                  }
                },
                builder: (context, moneyTransferState) {
                  return BlocConsumer<TransferRateBloc, TransferRateState>(
                    listener: (context, state) {
                      if (state is TransferRateSuccess) {
                        setState(() {
                          showDetail = true;
                        });
                      } else if (state is TransferRateFailure) {
                        showSnackbar(
                          context,
                          description: state.message,
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is TransferRateLoading ||
                          moneyTransferState is MoneyTransferLoading) {
                        return const LoadingWidget();
                      }
                      return const TextWidget(
                        text: 'Continue',
                        type: TextType.small,
                        color: Colors.white,
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildTransferToSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: TextWidget(
            text: 'Transfer To',
            fontSize: 18,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),
        BlocBuilder<WalletBloc, WalletState>(
          builder: (context, state) {
            return Column(
              children: [
                for (int i = 0; i < state.wallets.length; i++)
                  Visibility(
                    visible: (showDetail
                        ? (transferToWalletId == state.wallets[i].walletId)
                        : (transferFromWalletModel?.walletId !=
                            state.wallets[i].walletId)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 15,
                          ),
                          child: CardWidget(
                            boxBorder: Border.all(
                              color: transferToWalletId ==
                                      state.wallets[i].walletId
                                  ? ColorName.primaryColor
                                  : Colors.transparent,
                            ),
                            alignment: Alignment.center,
                            borderRadius: BorderRadius.circular(24),
                            width: 100.sw,
                            height: 65,
                            child: ListTile(
                              shape: ContinuousRectangleBorder(
                                  borderRadius: BorderRadius.circular(50)),
                              onTap: () {
                                if (transferToWalletId ==
                                    state.wallets[i].walletId) {
                                  setState(() {
                                    transferToWalletId = -1;
                                    showDetail = false;
                                  });
                                } else {
                                  setState(() {
                                    transferToWalletId =
                                        state.wallets[i].walletId;
                                  });
                                }
                              },
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              leading: Container(
                                width: 44,
                                height: 44,
                                clipBehavior: Clip.antiAlias,
                                decoration:
                                    const BoxDecoration(shape: BoxShape.circle),
                                child: Image.asset(
                                  'icons/currency/${state.wallets[i].currency.code.toLowerCase()}.png',
                                  package: 'currency_icons',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text:
                                        '${state.wallets[i].currency.code.toUpperCase()} Wallet',
                                    fontSize: 14,
                                  ),
                                  TextWidget(
                                    text:
                                        '${state.wallets[i].currency.code.toUpperCase()} ${NumberFormat('##,###.##').format(state.wallets[i].balance)}',
                                    fontSize: 10,
                                  )
                                ],
                              ),
                              trailing: Checkbox(
                                shape: const CircleBorder(),
                                onChanged: (value) {
                                  if (transferToWalletId ==
                                      state.wallets[i].walletId) {
                                    setState(() {
                                      transferToWalletId = -1;
                                      showDetail = false;
                                    });
                                  } else {
                                    setState(() {
                                      transferToWalletId =
                                          state.wallets[i].walletId;
                                    });
                                  }
                                },
                                value: transferToWalletId ==
                                    state.wallets[i].walletId,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    ),
                  )
              ],
            );
          },
        ),
        // Padding(
        //   padding: const EdgeInsets.only(right: 15),
        //   child: Align(
        //     alignment: Alignment.topRight,
        //     child: SizedBox(
        //       child: ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           foregroundColor: ColorName.primaryColor,
        //           backgroundColor: Colors.white,
        //           elevation: 7,
        //           shadowColor: Colors.black.withOpacity(0.3),
        //           shape: RoundedRectangleBorder(
        //             borderRadius: BorderRadius.circular(10),
        //           ),
        //         ),
        //         onPressed: () {},
        //         child: const Padding(
        //           padding: EdgeInsets.all(8.0),
        //           child: Row(
        //             mainAxisSize: MainAxisSize.min,
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               Icon(Icons.add),
        //               TextWidget(
        //                 text: 'Add New Card',
        //                 color: ColorName.primaryColor,
        //                 fontSize: 13,
        //               ),
        //             ],
        //           ),
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  _buildChangeWallet() {
    return BlocListener<WalletBloc, WalletState>(
      listener: (BuildContext context, WalletState state) {
        transferFromWalletModel = state.wallets[0];
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextWidget(
            text:
                '\$${NumberFormat('##,###.##').format(transferFromWalletModel?.balance ?? 0)}',
            fontSize: 15,
            weight: FontWeight.bold,
          ),
          InkWell(
            onTap: () async {
              final selectedWallet = await showChangeWalletModal(
                context: context,
                selectedWalletId: transferFromWalletModel?.walletId,
              );
              if (selectedWallet != null) {
                setState(() {
                  transferFromWalletModel = selectedWallet;
                  transferToWalletId = -1;
                  showDetail = false;
                });
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(
                  text:
                      " ${transferFromWalletModel?.currency.code ?? 'USD'} Wallet",
                  fontSize: 15,
                  color: ColorName.grey,
                ),
                const Icon(Icons.keyboard_arrow_down)
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildEnterAmountSelection() {
    return Visibility(
      visible: showDetail,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: 'Enter Amount',
              fontSize: 18,
              weight: FontWeight.w600,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const TextWidget(
                  text: 'Today\'s Exchange Rate',
                  fontSize: 12,
                  color: ColorName.grey,
                ),
                const Gap(8),
                BlocConsumer<TransferRateBloc, TransferRateState>(
                  listener: (context, state) {
                    if (state is TransferRateFailure) {
                      showSnackbar(
                        context,
                        description:
                            'Exchange rate not found for the specified currency pair',
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is TransferRateSuccess) {
                      final convertedAmount =
                          state.transferRate.rate?.toStringAsFixed(2);
                      return TextWidget(
                        text:
                            '1 ${state.transferRate.fromCurrency?.code ?? ""} = $convertedAmount ${state.transferRate.toCurrency?.code ?? ""}',
                        fontSize: 12,
                        color: ColorName.primaryColor,
                        weight: FontWeight.bold,
                      );
                    }
                    if (state is TransferRateLoading) {
                      return CustomShimmer(
                        borderRadius: BorderRadius.circular(5),
                        width: 100,
                        height: 20,
                      );
                    }
                    return const TextWidget(
                      text: '---',
                      fontSize: 12,
                      weight: FontWeight.bold,
                    );
                  },
                ),
              ],
            ),
            const Gap(15),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildOnSummerizing(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  _buildOnSummerizing() {
    return BlocBuilder<TransferRateBloc, TransferRateState>(
      builder: (context, state) {
        if (state is TransferRateSuccess) {
          final convertedAmount = (state.transferRate.rate ?? 0) *
              (double.tryParse(amountController.text) ?? 0.0);

          return Stack(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFieldWidget(
                      onChanged: (p0) {
                        _formKey.currentState?.validate();
                        setState(() {});
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      validator: (text) {
                        if (text?.isEmpty == true) {
                          return 'Please enter amount';
                        } else if ((double.tryParse(amountController.text) ??
                                0) ==
                            0) {
                          return 'Invalid Amount';
                        } else if ((double.tryParse(text ?? '0') ?? 0) >
                            (transferFromWalletModel?.balance?.toDouble() ??
                                0)) {
                          return 'Insfficient balance';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      fontSize: 20,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 15),
                      hintText: '00.00',
                      prefixText: '\$',
                      focusNode: amountFocusNode,
                      borderRadius: BorderRadius.circular(24),
                      controller: amountController,
                    ),
                    const Gap(10),
                    AbsorbPointer(
                      absorbing: true,
                      child: TextFieldWidget(
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (text) {
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        fontSize: 20,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        hintText: '00.00',
                        prefixText: '\$',
                        borderRadius: BorderRadius.circular(24),
                        controller: TextEditingController(
                          text: convertedAmount.toStringAsFixed(2),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                top: 0,
                left: 0,
                child: Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: ColorName.primaryColor,
                    child: SvgPicture.asset(
                      Assets.images.svgs.transactionIconVertical,
                      // ignore: deprecated_member_use
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            ],
          );
        } else if (state is TransferRateLoading) {
          return SizedBox(
            height: 200,
            child: Column(
              children: [
                CustomShimmer(
                  borderRadius: BorderRadius.circular(20),
                  width: 100.sw,
                  height: 55,
                ),
                const SizedBox(height: 10),
                CustomShimmer(
                  borderRadius: BorderRadius.circular(20),
                  width: 100.sw,
                  height: 55,
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  _buildNoteSection() {
    return Visibility(
      visible: showDetail,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: 'Note',
                  fontSize: 14,
                  weight: FontWeight.w600,
                ),
                Icon(
                  Icons.info_outline,
                  color: ColorName.primaryColor,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Write your note',
                hintStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: ColorName.grey.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: ColorName.primaryColor,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildCheckDetail() {
    return BlocConsumer<CheckDetailsBloc, CheckDetailsState>(
      listener: (context, state) {
        if (state is CheckDetailsError) {
          showSnackbar(context, description: state.message);
        }
      },
      builder: (context, state) {
        if (state is CheckDetailsLoaded) {
          if (state.fees.isEmpty) {
            return const SizedBox.shrink();
          } else {
            return Visibility(
              visible: showDetail,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const TextWidget(
                          text: 'Check Details',
                          fontSize: 18,
                          weight: FontWeight.w600,
                        ),
                        if (state is CheckDetailsLoading)
                          const LoadingWidget(
                            color: ColorName.primaryColor,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ColorName.grey.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          _buildFeeDetails(
                            state.fees,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildFeeDetails(
    List<TransferFeesModel> fees,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 20,
        ),
        for (var fee in fees)
          Column(
            children: [
              _buildFeeRow(
                fee: fee,
              ),
              Visibility(
                  visible: fees.last.id != fee.id, child: const Divider()),
              Visibility(
                visible: fees.last.id != fee.id,
                replacement: const SizedBox(
                  height: 15,
                ),
                child: const SizedBox(
                  height: 5,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFeeRow({
    required TransferFeesModel fee,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              TextWidget(
                text: fee.label ?? '',
                color: isTotal ? null : ColorName.grey,
                fontSize: isTotal ? 16 : 14,
              ),
              Visibility(
                visible: fee.type == 'PERCENTAGE',
                child: TextWidget(
                  text:
                      '  ${NumberFormat('##,###.##').format(fee.amount ?? 0)}%',
                  fontSize: isTotal ? 16 : 14,
                  weight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextWidget(
                text: fee.type == 'PERCENTAGE'
                    ? "\$${((fee.amount ?? 0) / 100) * (double.tryParse(amountController.text) ?? 0)}"
                    : "\$${NumberFormat('##,###.##').format((fee.amount ?? 0))}",
                weight: FontWeight.w700,
                fontSize: 14,
              ),
              const SizedBox(
                width: 5,
              ),
              Icon(
                Icons.info_outline,
                color: ColorName.grey.withOpacity(0.5),
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
