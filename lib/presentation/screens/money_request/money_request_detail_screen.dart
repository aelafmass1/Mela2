import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/money_request/money_request_bloc.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/core/utils/ui_helpers.dart';
import 'package:transaction_mobile_app/data/models/money_request_model.dart';
import 'package:transaction_mobile_app/data/models/wallet_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';

import '../../../bloc/check-details-bloc/check_details_bloc.dart';
import '../../../bloc/money_transfer/money_transfer_bloc.dart';
import '../../../bloc/notification/notification_bloc.dart';
import '../../../bloc/transfer-rate/transfer_rate_bloc.dart';
import '../../../bloc/wallet/wallet_bloc.dart';
import '../../../bloc/wallet_transaction/wallet_transaction_bloc.dart';
import '../../../core/utils/show_change_wallet_modal.dart';
import '../../../data/models/transfer_fees_model.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/card_widget.dart';
import '../../widgets/text_field_widget.dart';
import '../../widgets/text_widget.dart';

class MoneyRequestDetailScreen extends StatefulWidget {
  final int requestId;
  const MoneyRequestDetailScreen({super.key, required this.requestId});

  @override
  State<MoneyRequestDetailScreen> createState() =>
      _MoneyRequestDetailScreenState();
}

class _MoneyRequestDetailScreenState extends State<MoneyRequestDetailScreen> {
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final rejectReasonController = TextEditingController();
  WalletModel? transferFromWalletModel;
  WalletModel? transferToWalletModel;
  showRejectDialog() {
    showDialog(
      context: context,
      builder: (_) => Align(
        alignment: const Alignment(0, -0.2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Material(
            borderRadius: BorderRadius.circular(largeSize),
            color: ColorName.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: middleSize, horizontal: smallSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextWidget(
                        text: 'Rejection Reason (optional)',
                        type: TextType.small,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: ColorName.red),
                        onPressed: () {
                          context.pop();
                        },
                      ),
                    ],
                  ),
                  TextFieldWidget(
                    borderRadius: BorderRadius.circular(8),
                    hintText: 'Write your reason',
                    controller: rejectReasonController,
                    maxLine: tinySize.toInt(),
                  ),
                  const SizedBox(height: middleSize),
                  BlocConsumer<MoneyRequestBloc, MoneyRequestState>(
                    listener: (context, state) {
                      if (state is RejectMoneyRequestSuccess) {
                        context
                            .read<NotificationBloc>()
                            .add(FetchNotifications());
                        context.pop();
                        context.pop();
                      } else if (state is RejectMoneyRequestFail) {
                        context.pop();
                        showSnackbar(
                          context,
                          description: state.reason,
                        );
                      }
                    },
                    builder: (context, state) {
                      return ButtonWidget(
                        child: state is RejectMoneyRequestLoading
                            ? const LoadingWidget()
                            : const TextWidget(
                                text: 'Reject',
                                type: TextType.small,
                                color: ColorName.white,
                              ),
                        onPressed: () {
                          context.read<MoneyRequestBloc>().add(
                                RejectMoneyRequest(
                                  requestId: widget.requestId,
                                ),
                              );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    context.read<MoneyRequestBloc>().add(
          FetchMoneyRequestDetail(
            requestId: widget.requestId,
          ),
        );
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
      appBar: AppBar(),
      body: BlocConsumer<MoneyRequestBloc, MoneyRequestState>(
        listener: (context, state) {
          if (state is FetchMoneyRequestFail) {
            showSnackbar(
              context,
              description: state.reason,
            );
          } else if (state is FetchMoneyRequestSuccess) {
            setState(() {
              transferToWalletModel = state.moneyRequestModel.requesterWalletId;
            });
            amountController.text = state.moneyRequestModel.amount.toString();
            context.read<TransferRateBloc>().add(FetchTransferRate(
                  fromWalletId: transferFromWalletModel!.walletId,
                  toWalletId: transferToWalletModel!.walletId,
                ));

            context.read<CheckDetailsBloc>().add(
                  FetchTransferFeesEvent(
                    fromWalletId: transferFromWalletModel!.walletId,
                    toWalletId: transferToWalletModel!.walletId,
                  ),
                );
          }
        },
        builder: (context, state) {
          if (state is FetchMoneyRequestLoading) {
            return const Center(
              child: LoadingWidget(
                color: ColorName.primaryColor,
              ),
            );
          }
          if (state is FetchMoneyRequestSuccess) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15),
                          child: TextWidget(
                            text: 'Requested From',
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildContactTile(
                          state.moneyRequestModel,
                        ),
                        _buildEnterAmountSelection(),
                        _buildNoteSection(),
                        _buildCheckDetail(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Row(
                    children: [
                      Expanded(
                        child: ButtonWidget(
                          color: Colors.white,
                          borderSide: const BorderSide(
                            color: ColorName.red,
                          ),
                          child: const TextWidget(
                            text: 'Reject',
                            type: TextType.small,
                            color: ColorName.red,
                          ),
                          onPressed: () {
                            showRejectDialog();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child:
                            BlocConsumer<MoneyTransferBloc, MoneyTransferState>(
                          listener: (context, state) {
                            if (state is MoneyTransferOwnWalletSuccess) {
                              context
                                  .read<WalletTransactionBloc>()
                                  .add(FetchWalletTransaction());
                              context.pop();
                              context
                                  .read<NotificationBloc>()
                                  .add(FetchNotifications());
                            } else if (state is MoneyTransferFail) {
                              showSnackbar(context, description: state.reason);
                            }
                          },
                          builder: (context, state) {
                            return ButtonWidget(
                              child: state is MoneyTransferLoading
                                  ? const LoadingWidget()
                                  : const TextWidget(
                                      text: 'Accept',
                                      type: TextType.small,
                                      color: Colors.white,
                                    ),
                              onPressed: () {
                                if (transferFromWalletModel != null &&
                                    transferToWalletModel != null) {
                                  context.read<MoneyTransferBloc>().add(
                                        TransferToWallet(
                                          fromWalletId:
                                              transferFromWalletModel!.walletId,
                                          toWalletId:
                                              transferToWalletModel!.walletId,
                                          amount: double.tryParse(
                                                  amountController.text) ??
                                              0,
                                          note: noteController.text,
                                        ),
                                      );
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  _buildNoteSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
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
            maxLines: 2,
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
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                  const SizedBox(height: 15),
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
                  const SizedBox(height: 20),
                ],
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

  _buildEnterAmountSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const TextWidget(
            text: 'Enter Amount',
            fontSize: 18,
            weight: FontWeight.w600,
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _buildOnSummerizing(),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  _buildOnSummerizing() {
    return TextFieldWidget(
      readOnly: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(6),
      ],
      validator: (text) {
        if (text?.isEmpty == true) {
          return 'Please enter amount';
        } else if ((double.tryParse(amountController.text) ?? 0) == 0) {
          return 'Invalid Amount';
        } else if ((double.tryParse(text ?? '0') ?? 0) >
            (transferFromWalletModel?.balance?.toDouble() ?? 0)) {
          return 'Insfficient balance';
        }
        return null;
      },
      keyboardType: TextInputType.phone,
      fontSize: 20,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      hintText: '00.00',
      prefixText: '\$',
      borderRadius: BorderRadius.circular(24),
      controller: amountController,
      suffix: (transferFromWalletModel != null)
          ? GestureDetector(
              onTap: () async {
                final wallet = await showChangeWalletModal(
                  context: context,
                  selectedWalletId: transferFromWalletModel?.walletId,
                );

                if (wallet != null) {
                  setState(() {
                    transferFromWalletModel = wallet;
                  });
                  if (transferToWalletModel != null) {
                    context.read<TransferRateBloc>().add(FetchTransferRate(
                          fromWalletId: transferFromWalletModel!.walletId,
                          toWalletId: transferToWalletModel!.walletId,
                        ));

                    context.read<CheckDetailsBloc>().add(
                          FetchTransferFeesEvent(
                            fromWalletId: transferFromWalletModel!.walletId,
                            toWalletId: transferToWalletModel!.walletId,
                          ),
                        );
                  } else {
                    context.read<CheckDetailsBloc>().add(
                          FetchTransferFeeFromCurrencies(
                            toCurrency: 'USD',
                            fromCurrency:
                                transferFromWalletModel?.currency.code ?? 'USD',
                          ),
                        );
                  }
                }
              },
              child: Container(
                margin: const EdgeInsets.only(right: 5, top: 3, bottom: 3),
                width: 102,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(
                    30,
                  ),
                ),
                child: Center(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Image.asset(
                        'icons/currency/${transferFromWalletModel?.currency.code.toLowerCase() ?? 'etb'}.png',
                        fit: BoxFit.cover,
                        package: 'currency_icons',
                      ),
                    ),
                    const SizedBox(width: 5),
                    TextWidget(
                      text: transferFromWalletModel?.currency.code
                              .toUpperCase() ??
                          '',
                      fontSize: 12,
                      weight: FontWeight.w700,
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.keyboard_arrow_down_outlined,
                      size: 18,
                    )
                  ],
                )),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  _buildContactTile(MoneyRequestModel request) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CardWidget(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: 100.sw,
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Assets.images.profileImage.image(
              color: ColorName.primaryColor.shade200,
              fit: BoxFit.cover,
            ),
          ),
          title: Row(
            children: [
              TextWidget(
                text:
                    "${request.requesterWalletId.holder!.firstName ?? ''} ${request.requesterWalletId.holder!.lastName ?? ''}",
                fontSize: 16,
              ),
              const SizedBox(width: 5),
            ],
          ),
          subtitle: TextWidget(
            text: request.recipientId.phoneNumber ?? '---',
            fontSize: 10,
            color: ColorName.grey.shade500,
            weight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
