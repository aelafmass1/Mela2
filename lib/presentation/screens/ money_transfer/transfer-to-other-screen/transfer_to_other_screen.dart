// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/money_request/money_request_bloc.dart';
import 'package:transaction_mobile_app/bloc/money_transfer/money_transfer_bloc.dart';
import 'package:transaction_mobile_app/core/utils/show_qr_generator.dart';
import 'package:transaction_mobile_app/presentation/screens/%20money_transfer/utils/show_money_receiver_selection.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';
import '../../../../bloc/check-details-bloc/check_details_bloc.dart';
import '../../../../bloc/contact/contact_bloc.dart';
import '../../../../bloc/transfer-rate/transfer_rate_bloc.dart';
import '../../../../bloc/wallet/wallet_bloc.dart';
import '../../../../bloc/wallet_recent_transaction/wallet_recent_transaction_bloc.dart';
import '../../../../bloc/wallet_transaction/wallet_transaction_bloc.dart';
import '../../../../core/utils/show_change_wallet_modal.dart';
import '../../../../core/utils/show_snackbar.dart';
import '../../../../core/utils/show_wallet_receipt.dart';
import '../../../../data/models/contact_status_model.dart';
import '../../../../data/models/transfer_fees_model.dart';
import '../../../../data/models/wallet_model.dart';
import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../widgets/card_widget.dart';
import '../../../widgets/custom_shimmer.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/text_field_widget.dart';

class TransferToOtherScreen extends StatefulWidget {
  final bool isFromRequest;
  const TransferToOtherScreen({super.key, required this.isFromRequest});
  @override
  State<TransferToOtherScreen> createState() => _TransferToOtherScreenState();
}

class _TransferToOtherScreenState extends State<TransferToOtherScreen> {
  final amountKey = GlobalKey<FormFieldState>();
  final noteKey = GlobalKey<FormFieldState>();
  final amountController = TextEditingController();
  final amountFocusNode = FocusNode();
  final noteController = TextEditingController();

  final scrollController = ScrollController();

  double facilityFee = 12.08;
  double bankFee = 94.28;
  WalletModel? transferFromWalletModel;
  WalletModel? transferToWalletModel;

  ContactStatusModel? selectedContact;
  ContactStatusModel? previousSelectedContact;

  bool isEmpty = false;

  final _formKey = GlobalKey<FormState>();
  // int transferToWalletId = -1;

  clearStates() {
    context.read<TransferRateBloc>().add(ResetTransferRate());
    context.read<CheckDetailsBloc>().add(ResetTransferFee());
  }

  handleContactSelection() async {
    final selecteduser = await showMoneyReceiverSelection(context);
    print("the selected user once agian is $selecteduser");
    if (selecteduser != null) {
      setState(() {
        selectedContact = selecteduser;
      });
      if (selectedContact?.wallets?.isNotEmpty == true) {
        setState(() {
          transferToWalletModel = selectedContact?.wallets?.first;
        });
        if (widget.isFromRequest == false) {
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
      } else {
        setState(() {
          transferToWalletModel = null;
        });
        clearStates();
        if (transferFromWalletModel != null && transferToWalletModel != null) {
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
                  fromCurrency: transferFromWalletModel?.currency.code ?? 'USD',
                ),
              );
        }
      }
      scrollDown();
    }
  }

  scrollDown() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100), () {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      });
    } catch (e) {
      log(e.toString());
    }
  }

  @override
  void initState() {
    try {
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
      final walletRecent = context.read<WalletRecentTransactionBloc>().state;
      if (walletRecent is WalletRecentTransactionSuccess) {
        if (walletRecent.transactions.isEmpty) {
          context.read<WalletRecentTransactionBloc>().add(
                FetchRecentTransaction(),
              );
        }
      }
    } catch (e) {
      log(e.toString());
    }

    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    amountFocusNode.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: selectedContact != null
            ? IconButton(
                onPressed: () {
                  setState(() {
                    previousSelectedContact = selectedContact;
                    selectedContact = null;
                  });
                },
                icon: const Icon(Icons.arrow_back),
              )
            : const SizedBox.shrink(),
        title: widget.isFromRequest
            ? const TextWidget(
                text: 'Request Money',
                fontSize: 20,
                weight: FontWeight.w700,
              )
            : _buildChangeWallet(),
        toolbarHeight: 70,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                context.pop();
              },
              icon: const Icon(Icons.close),
            ),
          )
        ],
      ),
      body: BlocListener<MoneyRequestBloc, MoneyRequestState>(
        listener: (context, state) {
          if (state is MoneyRequestFailure) {
            showSnackbar(
              context,
              description: state.reason,
            );
          } else if (state is MoneyRequestSuccess) {
            context.pop();
            showQrGenerator(
              context: context,
              shareLink: state.id.toString(),
              amount: double.tryParse(amountController.text) ?? 0,
            );
          }
        },
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchButton(),
                    _buildRecentUsers(),
                    _buildPreviousSelectedAccount(),
                    _buildTransferTo(),
                    _buildEnterAmountSelection(),
                    _buildNoteSection(),
                    _buildCheckDetail(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: ButtonWidget(
                onPressed: selectedContact == null
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          if (widget.isFromRequest) {
                          
                            context.read<MoneyRequestBloc>().add(
                                  MoneyRequest(
                                    requesterWalletId:
                                        transferFromWalletModel?.walletId ?? -1,
                                    amount: double.tryParse(
                                            amountController.text) ??
                                        0,
                                    note: noteController.text,
                                    userId: selectedContact?.userId ?? -1,
                                  ),
                                );
                          } else {
                            if (transferFromWalletModel != null &&
                                transferToWalletModel != null) {
                              scrollDown();
                              context.read<MoneyTransferBloc>().add(
                                    TransferToWallet(
                                      amount: double.tryParse(
                                              amountController.text) ??
                                          0,
                                      note: noteController.text,
                                      fromWalletId:
                                          transferFromWalletModel!.walletId,
                                      toWalletId:
                                          transferToWalletModel!.walletId,
                                    ),
                                  );
                            } else {
                            

                              context.read<MoneyTransferBloc>().add(
                                    TransferToUnregisteredUser(
                                      phoneNumber:
                                          selectedContact?.contactPhoneNumber ??
                                              '',
                                      amount: double.tryParse(
                                              amountController.text) ??
                                          0,
                                      name: selectedContact?.contactName ?? '',
                                      senderWalletId:
                                          transferFromWalletModel?.walletId ??
                                              0,
                                    ),
                                  );
                            }
                          }
                        }
                      },
                child: BlocBuilder<MoneyRequestBloc, MoneyRequestState>(
                  builder: (context, requestState) {
                    return BlocConsumer<MoneyTransferBloc, MoneyTransferState>(
                      listener: (context, state) {
                        if (state is MoneyTransferOwnWalletSuccess) {
                          context.pop();
                          if (mounted) {
                            context.read<WalletBloc>().add(FetchWallets());
                            context
                                .read<WalletTransactionBloc>()
                                .add(FetchWalletTransaction());

                            showWalletReceipt(
                              context,
                              state.walletTransactionModel!,
                            );
                          }
                        } else if (state
                            is MoneyTransferUnregisteredUserSuccess) {
                          context.pop();

                          if (mounted) {
                            context.read<WalletBloc>().add(FetchWallets());
                            context
                                .read<WalletTransactionBloc>()
                                .add(FetchWalletTransaction());

                            showWalletReceipt(
                              context,
                              state.walletTransactionModel!,
                            );
                          }
                        } else if (state is MoneyTransferFail) {
                          showSnackbar(
                            context,
                            description: state.reason,
                          );
                        }
                      },
                      builder: (context, state) {
                        return state is MoneyTransferLoading ||
                                requestState is MoneyRequestLoading
                            ? const LoadingWidget()
                            : const TextWidget(
                                text: 'Continue',
                                type: TextType.small,
                                color: ColorName.white,
                              );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
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
                  // transferToWalletId = -1;
                  // showDetail = false;
                });
                if (selectedContact != null) {
                  if (selectedContact?.wallets?.isNotEmpty == true) {
                    if (transferFromWalletModel == null) {
                      setState(() {
                        transferToWalletModel = selectedContact?.wallets?.first;
                      });
                    }

                    context.read<TransferRateBloc>().add(FetchTransferRate(
                          fromWalletId: transferFromWalletModel!.walletId,
                          toWalletId: transferToWalletModel!.walletId,
                        ));
                    if (transferFromWalletModel != null &&
                        transferToWalletModel != null) {
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
                                  transferFromWalletModel?.currency.code ??
                                      'USD',
                            ),
                          );
                    }
                  } else {
                    clearStates();
                  }
                }
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextWidget(
                  text:
                      "${transferFromWalletModel?.currency.code ?? 'USD'} Wallet",
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

  _buildSearchButton() {
    return Visibility(
      visible: selectedContact == null,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, left: 15, right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: 'Search Recipient',
              fontSize: 20,
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: handleContactSelection,
              child: CardWidget(
                  boxBorder: Border.all(color: ColorName.primaryColor),
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
                  child: Row(
                    children: [
                      SvgPicture.asset(Assets.images.svgs.search),
                      const SizedBox(width: 12),
                      const TextWidget(
                        text: 'Search by @username , name or phone number',
                        fontSize: 12,
                        weight: FontWeight.w400,
                        color: ColorName.grey,
                      ),
                    ],
                  )),
            ),
          ],
        ),
      ),
    );
  }

  _buildRecentUsers() {
    return Visibility(
      visible: selectedContact == null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: 'Recent',
              type: TextType.small,
              weight: FontWeight.w600,
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  BlocConsumer<WalletRecentTransactionBloc,
                      WalletRecentTransactionState>(
                    listener: (context, state) {
                      if (state is WalletRecentTransactionSuccess) {
                        if (state.transactions.isEmpty) {
                          setState(() {
                            isEmpty = true;
                          });
                        }
                      }
                    },
                    builder: (context, state) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (state is WalletRecentTransactionLoading)
                            ...List.generate(
                                6,
                                (index) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Column(
                                        children: [
                                          CustomShimmer(
                                            width: 40,
                                            height: 40,
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          const SizedBox(height: 5),
                                          const CustomShimmer(
                                            width: 30,
                                            height: 5,
                                          ),
                                          const SizedBox(height: 1),
                                          const CustomShimmer(
                                            width: 30,
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    ))
                          else if (state is WalletRecentTransactionSuccess)
                            for (int index = 0;
                                index < state.transactions.length;
                                index++)
                              Padding(
                                padding: const EdgeInsets.only(right: 20),
                                child: Column(
                                  children: [
                                    const SizedBox(height: 5),
                                    CircleAvatar(
                                      backgroundImage:
                                          Assets.images.profileImage.provider(),
                                    ),
                                    TextWidget(
                                      text: state.transactions[index].holder
                                              ?.firstName ??
                                          '',
                                      fontSize: 8,
                                      weight: FontWeight.w400,
                                      color: ColorName.grey,
                                    ),
                                    TextWidget(
                                      text:
                                          '${state.transactions[index].balance ?? ''}',
                                      fontSize: 8,
                                      weight: FontWeight.w700,
                                    )
                                  ],
                                ),
                              )
                        ],
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildContactTile(ContactStatusModel contact, {Function()? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: CardWidget(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: 100.sw,
        child: ListTile(
          onTap: onTap,
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
                text: contact.contactName ?? '---',
                fontSize: 16,
              ),
              const SizedBox(width: 5),
              Visibility(
                visible: contact.wallets?.isNotEmpty == true,
                child: SvgPicture.asset(
                  Assets.images.svgs.checkmarkIcon,
                  width: 18,
                  height: 18,
                ),
              ),
            ],
          ),
          subtitle: TextWidget(
            text: contact.contactPhoneNumber ?? '---',
            fontSize: 10,
            color: ColorName.grey.shade500,
            weight: FontWeight.w400,
          ),
          trailing: onTap != null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(right: 5),
                  child: SizedBox(
                    width: 58,
                    height: 25,
                    child: ButtonWidget(
                      borderSide:
                          const BorderSide(color: ColorName.primaryColor),
                      color: ColorName.white,
                      borderRadius: BorderRadius.circular(20),
                      verticalPadding: 0,
                      onPressed: handleContactSelection,
                      child: const TextWidget(
                        text: 'Change',
                        color: ColorName.primaryColor,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  _buildTransferTo() {
    return BlocListener<ContactBloc, ContactState>(
      listener: (context, state) {
        if (state is ContactFilterSuccess) {
          if (state.remoteContacts.isNotEmpty) {
            final melaMemberContacts =
                state.filteredContacts.map((c) => c.contactId).toList();
            if (melaMemberContacts.contains(selectedContact?.contactId)) {
              setState(() {
                selectedContact = state.filteredContacts
                    .firstWhere(
                        (c) => c.contactId == selectedContact?.contactId)
                    .copyWith(
                      contactName: selectedContact?.contactName,
                      contactPhoneNumber: selectedContact?.contactPhoneNumber,
                    );
              });
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
          }
        }
      },
      child: Visibility(
        visible: selectedContact != null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextWidget(
                text: 'Transfer To',
                fontSize: 18,
                weight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 15),
            if (selectedContact != null)
              _buildContactTile(
                selectedContact!,
              )
          ],
        ),
      ),
    );
  }

  _buildEnterAmountSelection() {
    return Visibility(
      visible: selectedContact != null,
      child: Padding(
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
            Visibility(
              visible: widget.isFromRequest == false,
              child: Row(
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
            ),
            Visibility(
                visible: widget.isFromRequest == false, child: const Gap(15)),
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
        if (state is TransferRateLoading) {
          return Column(
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
          );
        }
        double convertedAmount = 0.0;
        if (state is TransferRateSuccess) {
          convertedAmount = (state.transferRate.rate ?? 0) *
              (double.tryParse(amountController.text) ?? 0.0);
        } else {
          convertedAmount = 0.0;
        }

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
                          (transferFromWalletModel?.balance?.toDouble() ?? 0)) {
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
                    suffix: (transferFromWalletModel != null)
                        ? GestureDetector(
                            onTap: () async {
                              final wallet = await showChangeWalletModal(
                                context: context,
                                selectedWalletId:
                                    transferFromWalletModel?.walletId,
                              );

                              if (wallet != null) {
                                setState(() {
                                  transferFromWalletModel = wallet;
                                });
                                if (transferToWalletModel != null &&
                                    widget.isFromRequest == false) {
                                  context
                                      .read<TransferRateBloc>()
                                      .add(FetchTransferRate(
                                        fromWalletId:
                                            transferFromWalletModel!.walletId,
                                        toWalletId:
                                            transferToWalletModel!.walletId,
                                      ));

                                  context.read<CheckDetailsBloc>().add(
                                        FetchTransferFeesEvent(
                                          fromWalletId:
                                              transferFromWalletModel!.walletId,
                                          toWalletId:
                                              transferToWalletModel!.walletId,
                                        ),
                                      );
                                } else {
                                  context.read<CheckDetailsBloc>().add(
                                        FetchTransferFeeFromCurrencies(
                                          toCurrency: 'USD',
                                          fromCurrency: transferFromWalletModel
                                                  ?.currency.code ??
                                              'USD',
                                        ),
                                      );
                                }
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  right: 5, top: 3, bottom: 3),
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
                  ),
                  const Gap(10),
                  Visibility(
                    visible: widget.isFromRequest == false,
                    child: TextFieldWidget(
                      readOnly: true,
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
                      suffix: (transferToWalletModel != null)
                          ? GestureDetector(
                              onTap: () async {
                                if ((selectedContact?.wallets?.length ?? 0) >
                                    1) {
                                  WalletModel? wallet;
                                  if (transferToWalletModel == null) {
                                    wallet = await showChangeWalletModal(
                                      context: context,
                                      wallets: selectedContact?.wallets,
                                      selectedWalletId: selectedContact
                                          ?.wallets?.first.walletId,
                                    );
                                  } else {
                                    wallet = await showChangeWalletModal(
                                      context: context,
                                      wallets: selectedContact?.wallets,
                                      selectedWalletId:
                                          transferToWalletModel?.walletId,
                                    );
                                  }

                                  if (wallet != null) {
                                    setState(() {
                                      transferToWalletModel = wallet;
                                    });
                                    context
                                        .read<TransferRateBloc>()
                                        .add(FetchTransferRate(
                                          fromWalletId:
                                              transferFromWalletModel!.walletId,
                                          toWalletId:
                                              transferToWalletModel!.walletId,
                                        ));
                                    context.read<CheckDetailsBloc>().add(
                                          FetchTransferFeesEvent(
                                            fromWalletId:
                                                transferFromWalletModel!
                                                    .walletId,
                                            toWalletId:
                                                transferToWalletModel!.walletId,
                                          ),
                                        );
                                  }
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(
                                    right: 5, top: 3, bottom: 3),
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
                                        'icons/currency/${transferToWalletModel?.currency.code.toLowerCase() ?? 'etb'}.png',
                                        fit: BoxFit.cover,
                                        package: 'currency_icons',
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    TextWidget(
                                      text: transferToWalletModel?.currency.code
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
              child: Visibility(
                visible: widget.isFromRequest == false,
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
              ),
            )
          ],
        );
      },
    );
  }

  _buildNoteSection() {
    return Visibility(
      visible: selectedContact != null,
      child: Padding(
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
              visible: selectedContact != null && widget.isFromRequest == false,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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

  _buildPreviousSelectedAccount() {
    if (selectedContact != null || previousSelectedContact == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: TextWidget(
            text: 'Transfer To',
            fontSize: 18,
            weight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 15),
        _buildContactTile(previousSelectedContact!, onTap: () {
          setState(() {
            selectedContact = previousSelectedContact;
          });
        }),
      ],
    );
  }
}
