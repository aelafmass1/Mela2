// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/wallet_transaction/wallet_transaction_bloc.dart';
import 'package:transaction_mobile_app/core/extensions/color_extension.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/core/utils/show_wallet_receipt.dart';
import 'package:transaction_mobile_app/data/models/wallet_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/core/utils/show_change_wallet_modal.dart';
import 'package:transaction_mobile_app/presentation/screens/add_money_screen/components/add_payment_method_widget.dart';
import 'package:transaction_mobile_app/presentation/tabs/home_tab/components/wallet_card.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../bloc/bank_fee/bank_fee_bloc.dart';
import '../../../bloc/fee/fee_bloc.dart';
import '../../../bloc/payment_card/payment_card_bloc.dart';
import '../../../bloc/plaid/plaid_bloc.dart';
import '../../../bloc/wallet/wallet_bloc.dart';
import '../../../bloc/wallet_currency/wallet_currency_bloc.dart';
import '../../../data/models/payment_card_model.dart';
import '../../../data/models/receiver_info_model.dart';
import '../../widgets/card_widget.dart';
import '../../widgets/custom_shimmer.dart';

class AddMoneyScreen extends StatefulWidget {
  final String selectedWallet;
  const AddMoneyScreen({super.key, required this.selectedWallet});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final amountController = TextEditingController();
  ScrollController scrollController = ScrollController();
  int selectedAccountIndex = -1;

  bool showFee = false;
  bool isAnimationFinished = false;
  String whoPayFee = 'SENDER';
  String selectedPaymentCardId = '';
  final _formKey = GlobalKey<FormState>();
  final amonutFocus = FocusNode();

  ReceiverInfo? receiverInfo;

  StreamSubscription<LinkEvent>? _streamEvent;
  StreamSubscription<LinkExit>? _streamExit;
  StreamSubscription<LinkSuccess>? _streamSuccess;
  String? publicToken;
  WalletModel? selectedWalletModel;
  List<PaymentCardModel> paymentCards = [];

  double _calculateTotalFee(PaymentCardSuccess state) {
    double totalFee = 0;
    for (final card in state.paymentCards) {
      for (final fee in card.fees) {
        if (fee.type == "PERCENTAGE") {
          totalFee +=
              (fee.amount * (double.tryParse(amountController.text) ?? 0)) /
                  100;
        } else {
          totalFee += fee.amount;
        }
      }
    }
    return totalFee;
  }

  _addFundToWallet(
      {required String intentId,
      required String publicToken,
      String? paymentType}) {
    final bankState = context.read<BankFeeBloc>().state;
    final wallets = context.read<WalletBloc>().state.wallets;
    double totalFee = 0;
    final bankLastDigits = paymentCards[selectedAccountIndex].last4Digits;
    if (bankState is BankFeeSuccess) {
      totalFee = 0;

      context.read<WalletBloc>().add(
            AddFundToWallet(
              amount: double.parse(amountController.text) + totalFee,
              paymentType: paymentType ?? '',
              publicToken: publicToken,
              savedPaymentId: selectedPaymentCardId,
              bankLastDigits: bankLastDigits ?? '',
              walletId: selectedWalletModel != null
                  ? selectedWalletModel!.walletId
                  : wallets.first.walletId,
            ),
          );
    }
  }

  void _onEvent(LinkEvent event) {
    final name = event.name;
    final metadata = event.metadata.description();
    log("onEvent: $name, metadata: $metadata, event: $event");
  }

  void _onSuccess(LinkSuccess event) {
    final token = event.publicToken;
    final metadata = event.metadata.description();
    log("onSuccess: $token, metadata: $metadata,  event: $event");
    setState(() {
      publicToken = token;
    });
    context.read<PaymentCardBloc>().add(
          AddBankAccount(
            publicToken: token,
          ),
        );
  }

  void _onExit(LinkExit event) {
    final metadata = event.metadata.description();
    final error = event.error?.description();
    log("onExit metadata: $metadata, error: $error, event: $event");
  }

  /// Displays a payment sheet using the Stripe SDK.
  ///
  /// If the payment is successful, it creates a [ReceiverInfo] object and adds a [SendMoney] event to the [MoneyTransferBloc].
  /// If an error occurs during the payment process, it displays an error message using [showSnackbar].
  displayPaymentSheet(String clientSecret) async {
    try {
      // Display the Stripe payment sheet
      await Stripe.instance.presentPaymentSheet();
      final paymentIntent =
          await Stripe.instance.retrievePaymentIntent(clientSecret);

      _addFundToWallet(intentId: paymentIntent.id, publicToken: '');
    } catch (error) {
      if (error is StripeException) {
        // Handle StripeException specifically
        if (error.error.code == FailureCode.Failed &&
            error.error.stripeErrorCode == 'resource_missing') {
          // Handle the specific case of a missing payment intent
          showSnackbar(
            context,
            title: 'Error',
            description: 'Payment intent not found. Please try again.',
          );
        } else {
          // Handle when payment process cancelled
          showSnackbar(
            context,
            title: 'Error',
            description: 'Payment not proccessed',
          );
        }
      } else {
        // Handle other errors
        log(error.toString());
        showSnackbar(
          context,
          title: 'Error',
          description: '$error',
        );
      }
      log(error.toString());
    }
  }

  _selectDefault() {
    final wallets = context.read<WalletBloc>().state.wallets;
    final filteredWallets =
        wallets.where((w) => w.currency.code == widget.selectedWallet);
    if (wallets.isNotEmpty) {
      if (filteredWallets.isEmpty) {
        selectedWalletModel = wallets.first;
      } else {
        selectedWalletModel = filteredWallets.first;
      }
    }
  }

  @override
  void initState() {
    context.read<BankFeeBloc>().add(FetchBankFee());
    context.read<WalletCurrencyBloc>().add(FetchWalletCurrency());
    context.read<PaymentCardBloc>().add(FetchPaymentCards());
    _selectDefault();

    _streamEvent = PlaidLink.onEvent.listen(_onEvent);
    _streamExit = PlaidLink.onExit.listen(_onExit);
    _streamSuccess = PlaidLink.onSuccess.listen(_onSuccess);
    super.initState();
  }

  @override
  void dispose() {
    amountController.dispose();
    scrollController.dispose();
    _streamEvent?.cancel();
    _streamExit?.cancel();
    _streamSuccess?.cancel();
    amonutFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        leadingWidth: 55,
        centerTitle: true,
        title: const TextWidget(
          text: 'Add Money',
          weight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTop(),
                  _buildAmountTextInput(),
                  _buidPaymentMethods(),
                  _buildAddPaymentMethods(),
                  _buildCheckDetail(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: BlocBuilder<PlaidBloc, PlaidState>(
              builder: (context, plaidState) {
                return BlocBuilder<WalletBloc, WalletState>(
                  builder: (context, state) {
                    return ButtonWidget(
                        child: state is AddFundToWalletLoading
                            ? const LoadingWidget()
                            : TextWidget(
                                text: showFee ? 'Confirm Payment' : 'Continue',
                                color: Colors.white,
                                type: TextType.small,
                              ),
                        onPressed: () async {
                          amonutFocus.unfocus();
                          if (showFee == false) {
                            if (_formKey.currentState?.validate() == true) {
                              if (selectedAccountIndex == -1) {
                                showSnackbar(context,
                                    description: 'Select Payment Method');
                              } else {
                                setState(() {
                                  showFee = true;
                                });

                                // Add scroll animation after a brief delay to allow fee content to render
                                Future.delayed(
                                    const Duration(milliseconds: 100), () {
                                  scrollController.animateTo(
                                    scrollController.position.maxScrollExtent,
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeOut,
                                  );
                                });
                              }
                            }
                          } else {
                            if (selectedAccountIndex != -1) {
                              final cards = context
                                  .read<PaymentCardBloc>()
                                  .state
                                  .paymentCards;
                              setState(() {
                                selectedPaymentCardId =
                                    cards[selectedAccountIndex].id;
                              });
                              _addFundToWallet(
                                intentId: '',
                                publicToken: '',
                                paymentType: 'SAVED_PAYMENT',
                              );
                            }
                          }
                        });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  _buildAddPaymentMethods() {
    return MultiBlocListener(
      listeners: [
        BlocListener<PaymentCardBloc, PaymentCardState>(
          listener: (context, state) {
            if (state is PaymentCardSuccess) {
              setState(() {
                paymentCards = state.paymentCards;
                selectedAccountIndex =
                    state.addedNewCard ? state.paymentCards.length - 1 : -1;
              });
            } else if (state is PaymentCardFail) {
              showSnackbar(
                context,
                description: state.reason,
              );
            }
          },
        ),
        BlocListener<PlaidBloc, PlaidState>(listener: (context, state) async {
          if (state is PlaidLinkTokenFail) {
            context.pop();
            showSnackbar(
              context,
              title: 'Error',
              description: state.reason,
            );
          } else if (state is PlaidLinkTokenLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => const SizedBox(
                child: Center(
                  child: LoadingWidget(
                    color: ColorName.primaryColor,
                  ),
                ),
              ),
            );
          } else if (state is PlaidLinkTokenSuccess) {
            context.pop();
          }
        }),
        BlocListener<WalletBloc, WalletState>(listener: (context, state) {
          if (state is AddFundToWalletFail) {
            showSnackbar(context, description: state.reason);
          } else if (state is AddFundToWalletSuccess) {
            amountController.clear();
            setState(() {
              showFee = false;
              selectedAccountIndex = -1;
            });

            context.pop();
            if (mounted) {
              showWalletReceipt(
                context,
                state.walletTransactionModel,
              );
              context.read<WalletBloc>().add(FetchWallets());
              context
                  .read<WalletTransactionBloc>()
                  .add(FetchWalletTransaction());
            }
          }
        }),
      ],
      child: Visibility(
        visible: !(showFee && selectedAccountIndex != -1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(
                    text: 'Add Payment Methods',
                    weight: FontWeight.w700,
                    type: TextType.small,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: (showFee && selectedAccountIndex == -1) == false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CardWidget(
                    width: 100.sw,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      onTap: () {
                        context.read<PlaidBloc>().add(CreateLinkToken());
                      },
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: ColorName.primaryColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: SvgPicture.asset(Assets.images.svgs.bankLogo),
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      title: Row(
                        children: [
                          const TextWidget(
                            text: 'Bank Account',
                            fontSize: 15,
                          ),
                          Container(
                            margin: const EdgeInsets.only(left: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                                color: ColorName.green,
                                borderRadius: BorderRadius.circular(10)),
                            child: const TextWidget(
                              text: 'Free',
                              fontSize: 11,
                              color: ColorName.white,
                              weight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      subtitle: const TextWidget(
                        text: 'Free service charge ',
                        fontSize: 11,
                        weight: FontWeight.w400,
                      ),
                    )),
              ),
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: (showFee && selectedAccountIndex == -1) == false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CardWidget(
                    width: 100.sw,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          scrollControlDisabledMaxHeightRatio: 1,
                          builder: (_) => const AddPaymentMethodWidget(),
                        );
                      },
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Assets.images.masteredCard.image(
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      title: const TextWidget(
                        text: 'Debit Card',
                        fontSize: 15,
                      ),
                      subtitle: const TextWidget(
                        text: 'Additional charge is going to be included',
                        fontSize: 11,
                        weight: FontWeight.w400,
                        color: ColorName.yellow,
                      ),
                    )),
              ),
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: (showFee && selectedAccountIndex == -1) == false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CardWidget(
                    width: 100.sw,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          scrollControlDisabledMaxHeightRatio: 1,
                          builder: (_) => const AddPaymentMethodWidget(),
                        );
                      },
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Assets.images.visaCard.image(
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      title: const TextWidget(
                        text: 'Credit Card',
                        fontSize: 15,
                      ),
                      subtitle: const TextWidget(
                        text: 'Additional charge is going to be included',
                        fontSize: 11,
                        weight: FontWeight.w400,
                        color: ColorName.yellow,
                      ),
                    )),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _buildAmountTextInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: 'Enter Amount',
              weight: FontWeight.w700,
              type: TextType.small,
            ),
            const SizedBox(height: 15),
            BlocBuilder<WalletBloc, WalletState>(
              builder: (context, state) {
                return TextFieldWidget(
                  focusNode: amonutFocus,
                  //
                  onChanged: (p0) {
                    if (p0.isNotEmpty) {
                      if (mounted) {
                        setState(() {});
                      }
                    }
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (text) {
                    if (text?.isEmpty == true) {
                      return 'Amount is Empty';
                    } else if ((double.tryParse(amountController.text) ?? 0) ==
                        0) {
                      return 'Invalid Amount';
                    }
                    return null;
                  },
                  keyboardType: TextInputType.phone,
                  fontSize: 20,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  hintText: '00.00',
                  prefixText: '\$',
                  borderRadius: BorderRadius.circular(24),
                  controller: amountController,
                  suffix: GestureDetector(
                    onTap: () async {
                      final selectedWallet = await showChangeWalletModal(
                        context: context,
                        selectedWalletId: selectedWalletModel?.walletId,
                      );
                      if (selectedWallet != null) {
                        setState(() {
                          selectedWalletModel = selectedWallet;
                        });
                      }
                    },
                    child: Container(
                      margin:
                          const EdgeInsets.only(right: 3, top: 3, bottom: 3),
                      width: 102,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9F9),
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                      ),
                      child: state.wallets.isNotEmpty
                          ? Row(
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
                                    'icons/currency/${selectedWalletModel?.currency.code.toLowerCase() ?? 'usd'}.png',
                                    fit: BoxFit.cover,
                                    package: 'currency_icons',
                                  ),
                                ),
                                const SizedBox(width: 5),
                                TextWidget(
                                  text:
                                      selectedWalletModel?.currency.code ?? '',
                                  fontSize: 12,
                                  weight: FontWeight.w700,
                                ),
                                const SizedBox(width: 5),
                                const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 18,
                                )
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  _buildTop() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<WalletBloc, WalletState>(
            builder: (context, state) {
              if (state.wallets.isNotEmpty) {
                return Container(
                  margin: const EdgeInsets.only(top: 10),
                  alignment: Alignment.center,
                  child: selectedWalletModel != null
                      ? WalletCard(
                          height: 120,
                          showPattern: true,
                          walletName:
                              '${selectedWalletModel!.currency.code} Wallet',
                          logo:
                              'icons/currency/${selectedWalletModel!.currency.code.toLowerCase()}.png',
                          amount: selectedWalletModel!.balance?.toDouble() ?? 0,
                          color: selectedWalletModel!.currency.backgroundColor
                                  ?.toColor() ??
                              const Color(0xFF3440EC),
                          textColor: selectedWalletModel!.currency.textColor
                                  ?.toColor() ??
                              Colors.white,
                        )
                      : WalletCard(
                          height: 120,
                          showPattern: true,
                          walletName:
                              '${state.wallets.first.currency.code} Wallet',
                          logo:
                              'icons/currency/${state.wallets.first.currency.code.toLowerCase()}.png',
                          amount: state.wallets.first.balance?.toDouble() ?? 0,
                          color: state.wallets.first.currency.backgroundColor
                                  ?.toColor() ??
                              const Color(0xFF3440EC),
                          textColor: state.wallets.first.currency.textColor
                                  ?.toColor() ??
                              Colors.white,
                        ),
                );
              }
              return const SizedBox(
                height: 120,
                child: Center(
                  child: TextWidget(
                    text: "No Wallet Found",
                    type: TextType.small,
                    weight: FontWeight.w400,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 123,
              height: 35,
              child: ButtonWidget(
                topPadding: 0,
                verticalPadding: 0,
                borderRadius: BorderRadius.circular(10),
                elevation: 2,
                color: Colors.white,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(Assets.images.svgs.walletLogo),
                    const SizedBox(width: 10),
                    const TextWidget(
                      text: 'Change Wallet',
                      fontSize: 12,
                      color: ColorName.primaryColor,
                    )
                  ],
                ),
                onPressed: () async {
                  final selectedWallet = await showChangeWalletModal(
                    context: context,
                    selectedWalletId: selectedWalletModel?.walletId,
                  );
                  if (selectedWallet != null) {
                    setState(() {
                      selectedWalletModel = selectedWallet;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }

  _buildCheckDetail() {
    return Visibility(
      visible: showFee,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: showFee ? 1 : 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: TextWidget(
                text: 'Check Details',
                weight: FontWeight.w700,
                type: TextType.small,
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: CardWidget(
                width: 100.sw,
                padding: const EdgeInsets.all(15),
                child: Container(
                  width: 100.sw,
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: ColorName.borderColor,
                    ),
                  ),
                  child: BlocBuilder<PaymentCardBloc, PaymentCardState>(
                    builder: (context, state) {
                      if (state is PaymentCardLoading) {
                        return Column(
                          children: [
                            CustomShimmer(
                              width: 100.sw,
                              height: 34,
                            ),
                            const Divider(
                              color: ColorName.borderColor,
                            ),
                            CustomShimmer(
                              width: 100.sw,
                              height: 34,
                            ),
                            const Divider(
                              color: ColorName.borderColor,
                            ),
                            CustomShimmer(
                              width: 100.sw,
                              height: 34,
                            ),
                          ],
                        );
                      } else if (state is PaymentCardSuccess) {
                        return Column(
                          children: [
                            for (var fee in state.paymentCards
                                .expand((card) => card.fees))
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          TextWidget(
                                            text: fee.label,
                                            fontSize: 14,
                                          ),
                                          Visibility(
                                            visible: fee.type == 'PERCENTAGE',
                                            child: TextWidget(
                                              text:
                                                  '  ${NumberFormat('##,###.##').format(fee.amount)}%',
                                              fontSize: 14,
                                              weight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          TextWidget(
                                            text:
                                                '\$${_calculateTotalFee(state).toStringAsFixed(2)}',
                                            fontSize: 16,
                                            weight: FontWeight.w700,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                            ),
                                          Icon(
                                            Icons.info_outline,
                                            color:
                                                ColorName.grey.withOpacity(0.5),
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    color: ColorName.borderColor,
                                    ),
                                ],
                              ),
                            SizedBox(
                              height: 34,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const TextWidget(
                                    text: 'Total Fee',
                                    fontSize: 16,
                                    weight: FontWeight.w500,
                                  ),
                                  BlocBuilder<FeeBloc, FeeState>(
                                    builder: (context, feeState) {
                                      return Row(
                                        children: [
                                          TextWidget(
                                            text:
                                                '\$${NumberFormat('##,###.##').format(_calculateTotalFee(state))}',
                                            fontSize: 16,
                                            weight: FontWeight.w700,
                                          ),
                                          const SizedBox(
                                            width: 5,
                                            ),
                                          Icon(
                                            Icons.info_outline,
                                            color:
                                                ColorName.grey.withOpacity(0.5),
                                            size: 20,
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                ],
                              ),
                            ),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  _buidPaymentMethods() {
    return Visibility(
      visible: (showFee && selectedAccountIndex == -1) == false,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 15,
        ),
        child: BlocBuilder<PlaidBloc, PlaidState>(
          builder: (context, plaidState) {
            return BlocBuilder<PaymentCardBloc, PaymentCardState>(
              builder: (context, state) {
                if (state is PaymentCardLoading) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      const TextWidget(
                        text: 'Payment Methods',
                        weight: FontWeight.w700,
                        type: TextType.small,
                      ),
                      const SizedBox(height: 10),
                      ...List.generate(4, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          child: CustomShimmer(
                            width: 100.sw,
                            height: 55,
                          ),
                        );
                      }),
                    ],
                  );
                }
                return Visibility(
                  visible: paymentCards.isNotEmpty,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),
                      const TextWidget(
                        text: 'Payment Methods',
                        weight: FontWeight.w700,
                        type: TextType.small,
                      ),
                      for (int i = 0; i < paymentCards.length; i++)
                        _buildPaymentMethodTile(
                          id: i,
                          iconPath: paymentCards[i].cardBrand == 'visa'
                              ? Assets.images.visaCard.path
                              : paymentCards[i].type == 'us_bank_account'
                                  ? Assets.images.svgs.bankLogo
                                  : Assets.images.masteredCard.path,
                          title: paymentCards[i].cardBrand ??
                              paymentCards[i].bankName ??
                              '',
                          subTitle:
                              '${paymentCards[i].cardBrand ?? ''} ending **${paymentCards[i].last4Digits}',
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  _buildPaymentMethodTile({
    required int id,
    required String iconPath,
    required String title,
    required String subTitle,
  }) {
    return Visibility(
      visible: (showFee && selectedAccountIndex != id) == false,
      child: Padding(
        padding: const EdgeInsets.only(top: 15),
        child: CardWidget(
            boxBorder: Border.all(
              color: selectedAccountIndex == id
                  ? ColorName.primaryColor
                  : Colors.transparent,
            ),
            width: 100.sw,
            borderRadius: BorderRadius.circular(14),
            child: ListTile(
              splashColor: Colors.white,
              onTap: () {
                if (selectedAccountIndex == id) {
                  setState(() {
                    selectedAccountIndex = -1;
                    showFee = false;
                  });
                } else {
                  setState(() {
                    selectedAccountIndex = id;
                  });
                }
              },
              leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconPath == Assets.images.svgs.bankLogo
                        ? ColorName.primaryColor
                        : null,
                    shape: BoxShape.circle,
                    image: iconPath == Assets.images.svgs.bankLogo
                        ? null
                        : DecorationImage(
                            image: AssetImage(iconPath), fit: BoxFit.cover),
                  ),
                  child: iconPath == Assets.images.svgs.bankLogo
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SvgPicture.asset(
                            iconPath,
                            fit: BoxFit.cover,
                          ),
                        )
                      : null),
              contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              trailing: Checkbox(
                activeColor: ColorName.primaryColor,
                shape: const CircleBorder(),
                value: selectedAccountIndex == id,
                onChanged: (value) {
                  if (selectedAccountIndex == id) {
                    setState(() {
                      selectedAccountIndex = -1;
                      showFee = false;
                    });
                  } else {
                    setState(() {
                      selectedAccountIndex = id;
                    });
                  }
                },
              ),
              title: TextWidget(
                text: title,
                fontSize: 15,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: subTitle,
                    fontSize: 11,
                    weight: FontWeight.w400,
                  ),
                  const SizedBox(height: 5),
                ],
              ),
            )),
      ),
    );
  }
}
