// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/wallet_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/core/utils/show_change_wallet_modal.dart';
import 'package:transaction_mobile_app/presentation/tabs/home_tab/widgets/wallet_card.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../bloc/bank_fee/bank_fee_bloc.dart';
import '../../../bloc/fee/fee_bloc.dart';
import '../../../bloc/payment_card/payment_card_bloc.dart';
import '../../../bloc/payment_intent/payment_intent_bloc.dart';
import '../../../bloc/plaid/plaid_bloc.dart';
import '../../../bloc/wallet/wallet_bloc.dart';
import '../../../bloc/wallet_currency/wallet_currency_bloc.dart';
import '../../../data/models/receiver_info_model.dart';
import '../../widgets/card_widget.dart';
import '../../widgets/custom_shimmer.dart';
import '../../widgets/payment_card_selection.dart';

class AddMoneyScreen extends StatefulWidget {
  const AddMoneyScreen({super.key});

  @override
  State<AddMoneyScreen> createState() => _AddMoneyScreenState();
}

class _AddMoneyScreenState extends State<AddMoneyScreen> {
  final amountController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String selectedCurrency = 'usd';
  int selectedPaymentMethodIndex = -1;
  bool showFee = false;
  bool isAnimationFinished = false;
  String whoPayFee = 'SENDER';
  String selectedPaymentCardId = '';
  final _formKey = GlobalKey<FormState>();
  final amonutFocus = FocusNode();

  ReceiverInfo? receiverInfo;

  LinkTokenConfiguration? _configuration;
  StreamSubscription<LinkEvent>? _streamEvent;
  StreamSubscription<LinkExit>? _streamExit;
  StreamSubscription<LinkSuccess>? _streamSuccess;
  String? publicToken;
  WalletModel? selectedWalletModel;

  _addFundToWallet(
      {required String intentId,
      required String publicToken,
      String? paymentType}) {
    final feeState = context.read<FeeBloc>().state;
    final bankState = context.read<BankFeeBloc>().state;
    final wallets = context.read<WalletBloc>().state.wallets;
    double totalFee = 0;
    if (feeState is FeeSuccess && bankState is BankFeeSuccess) {
      final creditCardAmount = bankState.bankFees
              .where((bf) => bf.label == 'Credit Card fee')
              .isEmpty
          ? 0
          : bankState.bankFees
              .where((bf) => bf.label == 'Credit Card fee')
              .first
              .amount;
      final debitCardAmount =
          bankState.bankFees.where((bf) => bf.label == 'Debit Card fee').isEmpty
              ? 0
              : bankState.bankFees
                  .where((bf) => bf.label == 'Debit Card fee')
                  .first
                  .amount;
      totalFee = ((selectedPaymentMethodIndex == 1
              ? (double.tryParse(amountController.text) ?? 0) *
                  (debitCardAmount / 100)
              : selectedPaymentMethodIndex == 2
                  ? (double.tryParse(amountController.text) ?? 0) *
                      (creditCardAmount / 100)
                  : 0))
          .toDouble();

      context.read<WalletBloc>().add(
            AddFundToWallet(
              amount: double.parse(amountController.text) + totalFee,
              paymentType: paymentType ??
                  (selectedPaymentMethodIndex == 1
                      ? 'STRIPE_DEBIT'
                      : 'STRIPE_CREDIT'),
              publicToken: publicToken,
              savedPaymentId: selectedPaymentCardId,
              paymentIntentId: selectedPaymentCardId.isEmpty ? intentId : '',
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
    log("onEvent: $name, metadata: $metadata");
  }

  void _onSuccess(LinkSuccess event) {
    final token = event.publicToken;
    final metadata = event.metadata.description();
    log("onSuccess: $token, metadata: $metadata");
    setState(() => publicToken = event.publicToken);
    context
        .read<PlaidBloc>()
        .add(ExchangePublicToken(publicToken: publicToken!));
  }

  void _onExit(LinkExit event) {
    final metadata = event.metadata.description();
    final error = event.error?.description();
    log("onExit metadata: $metadata, error: $error");
  }

  void _createLinkTokenConfiguration(String linkToken) {
    setState(() {
      _configuration = LinkTokenConfiguration(
        token: linkToken,
      );
    });
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

  @override
  void initState() {
    context.read<BankFeeBloc>().add(FetchBankFee());
    context.read<WalletCurrencyBloc>().add(FetchWalletCurrency());
    context.read<PaymentCardBloc>().add(FetchPaymentCards());

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
      body: BlocConsumer<WalletCurrencyBloc, WalletCurrencyState>(
        listener: (context, state) {
          if (state is FetchWalletCurrencyFail) {
            showSnackbar(context, description: state.reason);
          }
        },
        builder: (context, state) {
          if (state is FetchWalletCurrencyLoading) {
            return const Center(
                child: LoadingWidget(
              color: ColorName.primaryColor,
            ));
          } else if (state is FetchWalletCurrencySuccess) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTop(),
                        _buildAmountTextInput(state.currencies),
                        _buildAddMoneyFrom(),
                        _buildCheckDetail(),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  child: BlocBuilder<PlaidBloc, PlaidState>(
                    builder: (context, plaidState) {
                      return BlocBuilder<PaymentIntentBloc, PaymentIntentState>(
                        builder: (context, paymentState) {
                          return BlocBuilder<WalletBloc, WalletState>(
                            builder: (context, state) {
                              return ButtonWidget(
                                  child: paymentState is PaymentIntentLoading ||
                                          plaidState is PlaidLinkTokenLoading ||
                                          plaidState
                                              is PlaidPublicTokenLoading ||
                                          state is AddFundToWalletLoading
                                      ? const LoadingWidget()
                                      : TextWidget(
                                          text: showFee
                                              ? 'Confirm Payment'
                                              : 'Add Money',
                                          color: Colors.white,
                                          type: TextType.small,
                                        ),
                                  onPressed: () async {
                                    amonutFocus.unfocus();
                                    if (showFee == false) {
                                      if (_formKey.currentState?.validate() ==
                                          true) {
                                        if (selectedPaymentMethodIndex == -1) {
                                          showSnackbar(context,
                                              description:
                                                  'Select Payment Method');
                                        } else {
                                          setState(() {
                                            showFee = true;
                                          });
                                          context
                                              .read<FeeBloc>()
                                              .add(FetchFees());

                                          // Add scroll animation after a brief delay to allow fee content to render
                                          Future.delayed(
                                              const Duration(milliseconds: 100),
                                              () {
                                            scrollController.animateTo(
                                              scrollController
                                                  .position.maxScrollExtent,
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              curve: Curves.easeOut,
                                            );
                                          });
                                        }
                                      }
                                    } else {
                                      // final isCorrect = await showPincode(context);
                                      final paymentCardState =
                                          context.read<PaymentCardBloc>().state;
                                      if (selectedPaymentMethodIndex != 0) {
                                        final feeState =
                                            context.read<FeeBloc>().state;
                                        final bankState =
                                            context.read<BankFeeBloc>().state;
                                        double totalFee = 0;
                                        if (feeState is FeeSuccess &&
                                            bankState is BankFeeSuccess) {
                                          final creditCardAmount = bankState
                                                  .bankFees
                                                  .where((bf) =>
                                                      bf.label ==
                                                      'Credit Card fee')
                                                  .isEmpty
                                              ? 0
                                              : bankState.bankFees
                                                  .where((bf) =>
                                                      bf.label ==
                                                      'Credit Card fee')
                                                  .first
                                                  .amount;
                                          final debitCardAmount = bankState
                                                  .bankFees
                                                  .where((bf) =>
                                                      bf.label ==
                                                      'Debit Card fee')
                                                  .isEmpty
                                              ? 0
                                              : bankState.bankFees
                                                  .where((bf) =>
                                                      bf.label ==
                                                      'Debit Card fee')
                                                  .first
                                                  .amount;
                                          totalFee = ((selectedPaymentMethodIndex ==
                                                      1
                                                  ? ((double.tryParse(
                                                              amountController
                                                                  .text) ??
                                                          0) *
                                                      (debitCardAmount / 100))
                                                  : selectedPaymentMethodIndex ==
                                                          2
                                                      ? (double.tryParse(
                                                                  amountController
                                                                      .text) ??
                                                              0) *
                                                          (creditCardAmount /
                                                              100)
                                                      : 0))
                                              .toDouble();
                                          if (paymentCardState
                                              .paymentCards.isEmpty) {
                                            context
                                                .read<PaymentIntentBloc>()
                                                .add(
                                                  FetchClientSecret(
                                                    currency: selectedCurrency
                                                        .toUpperCase(),
                                                    amount: double.parse(
                                                            amountController
                                                                .text) +
                                                        totalFee,
                                                  ),
                                                );
                                          } else {
                                            showModalBottomSheet(
                                              context: context,
                                              backgroundColor: Colors.white,
                                              isScrollControlled: true,
                                              shape:
                                                  const ContinuousRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                topRight: Radius.circular(30),
                                              )),
                                              builder: (_) =>
                                                  PaymentCardSelection(
                                                onTab: (selectedPaymentCard) {
                                                  setState(() {
                                                    selectedPaymentCardId =
                                                        selectedPaymentCard.id;
                                                  });
                                                  context
                                                      .read<PaymentIntentBloc>()
                                                      .add(
                                                        FetchClientSecret(
                                                          currency:
                                                              selectedCurrency
                                                                  .toUpperCase(),
                                                          amount: double.parse(
                                                                  amountController
                                                                      .text) +
                                                              totalFee,
                                                        ),
                                                      );
                                                  context.pop();
                                                },
                                                paymentCards: paymentCardState
                                                    .paymentCards,
                                                onAddNewCardPressed: () {
                                                  context
                                                      .read<PaymentIntentBloc>()
                                                      .add(
                                                        FetchClientSecret(
                                                          currency:
                                                              selectedCurrency
                                                                  .toUpperCase(),
                                                          amount: double.parse(
                                                                  amountController
                                                                      .text) +
                                                              totalFee,
                                                        ),
                                                      );
                                                  setState(() {
                                                    selectedPaymentCardId = '';
                                                  });
                                                },
                                              ),
                                            );
                                          }
                                        }
                                      } else {
                                        context
                                            .read<PlaidBloc>()
                                            .add(CreateLinkToken());
                                      }
                                    }
                                  });
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }

  _buildAddMoneyFrom() {
    return MultiBlocListener(
      listeners: [
        BlocListener<PaymentIntentBloc, PaymentIntentState>(
            listener: (context, paymentState) async {
          if (paymentState is PaymentIntentFail) {
            showSnackbar(context,
                title: 'Error', description: paymentState.reason);
          } else if (paymentState is PaymentIntentSuccess) {
            /// Initializes and presents a Stripe payment sheet for processing a payment.
            ///
            /// Retrieves the `clientSecret` and `customerId` from the `paymentState`.
            /// Initializes the Stripe payment sheet with the retrieved information and merchant display name.
            /// Calls `displayPaymentSheet()` to present the payment sheet to the user.
            /// Logs any errors encountered during the process.
            try {
              final clientSecret = paymentState.clientSecret;

              if (selectedPaymentCardId.isEmpty) {
                await Stripe.instance.initPaymentSheet(
                  paymentSheetParameters: SetupPaymentSheetParameters(
                      paymentIntentClientSecret: clientSecret,
                      customerId: paymentState.customerId,
                      merchantDisplayName: 'Mela Fi',
                      appearance: const PaymentSheetAppearance(
                        colors: PaymentSheetAppearanceColors(
                          primary: ColorName.primaryColor,
                        ),
                      )),
                );

                displayPaymentSheet(clientSecret);
              } else {
                _addFundToWallet(
                    intentId: '',
                    publicToken: '',
                    paymentType: 'SAVED_PAYMENT');
              }
            } catch (error) {
              log(error.toString());
            }
          }
        }),
        BlocListener<PlaidBloc, PlaidState>(listener: (context, state) async {
          if (state is PlaidLinkTokenFail) {
            showSnackbar(
              context,
              title: 'Error',
              description: state.reason,
            );
          } else if (state is PlaidLinkTokenSuccess) {
            _createLinkTokenConfiguration(state.linkToken);
            await PlaidLink.create(configuration: _configuration!);
            await PlaidLink.open();
          } else if (state is PlaidPublicTokenFail) {
            showSnackbar(
              context,
              title: 'Error',
              description: state.reason,
            );
          } else if (state is PlaidPublicTokenSuccess) {
            _addFundToWallet(
              intentId: '',
              publicToken: publicToken ?? '',
              paymentType: 'PLAID_ACH',
            );
          }
        }),
        BlocListener<WalletBloc, WalletState>(listener: (context, state) {
          if (state is AddFundToWalletFail) {
            showSnackbar(context, description: state.reason);
          } else if (state is AddFundToWalletSuccess) {
            context.read<WalletBloc>().add(FetchWallets());
            context.pop();
          }
        }),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: TextWidget(
              text: 'Add Money From',
              weight: FontWeight.w700,
              type: TextType.small,
            ),
          ),
          const SizedBox(height: 15),
          AnimatedOpacity(
            opacity:
                (showFee == true && selectedPaymentMethodIndex != 0) ? 0 : 1,
            duration: const Duration(milliseconds: 400),
            onEnd: () {
              if (showFee == true) {
                setState(() {
                  isAnimationFinished = true;
                });
              }
            },
            child: Visibility(
              visible:
                  (isAnimationFinished && selectedPaymentMethodIndex != 0) ==
                      false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: CardWidget(
                    boxBorder: Border.all(
                        color: selectedPaymentMethodIndex == 0
                            ? ColorName.primaryColor
                            : Colors.transparent),
                    width: 100.sw,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      onTap: () {
                        if (selectedPaymentMethodIndex == 0) {
                          setState(() {
                            showFee = false;
                            isAnimationFinished = false;
                            selectedPaymentMethodIndex = -1;
                          });
                        } else {
                          setState(() {
                            selectedPaymentMethodIndex = 0;
                          });
                        }
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
                      trailing: Checkbox(
                        activeColor: ColorName.primaryColor,
                        shape: const CircleBorder(),
                        value: selectedPaymentMethodIndex == 0,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethodIndex = 0;
                          });
                        },
                      ),
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
          ),
          AnimatedOpacity(
            opacity:
                (showFee == true && selectedPaymentMethodIndex != 1) ? 0 : 1,
            duration: const Duration(milliseconds: 400),
            onEnd: () {
              if (showFee == true) {
                setState(() {
                  isAnimationFinished = true;
                });
              }
            },
            child: Visibility(
              visible:
                  (isAnimationFinished && selectedPaymentMethodIndex != 1) ==
                      false,
              child: Padding(
                padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                child: CardWidget(
                    boxBorder: Border.all(
                        color: selectedPaymentMethodIndex == 1
                            ? ColorName.primaryColor
                            : Colors.transparent),
                    width: 100.sw,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      onTap: () {
                        if (selectedPaymentMethodIndex == 1) {
                          setState(() {
                            showFee = false;
                            isAnimationFinished = false;
                            selectedPaymentMethodIndex = -1;
                          });
                        } else {
                          setState(() {
                            selectedPaymentMethodIndex = 1;
                          });
                        }
                      },
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: ColorName.primaryColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Center(
                          child: TextWidget(
                            text: 'D',
                            color: ColorName.white,
                            weight: FontWeight.w400,
                          ),
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      trailing: Checkbox(
                        activeColor: ColorName.primaryColor,
                        shape: const CircleBorder(),
                        value: selectedPaymentMethodIndex == 1,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethodIndex = 1;
                          });
                        },
                      ),
                      title: Row(
                        children: [
                          const TextWidget(
                            text: 'Debit Card',
                            fontSize: 15,
                          ),
                          BlocBuilder<BankFeeBloc, BankFeeState>(
                            builder: (context, state) {
                              if (state is BankFeeSuccess) {
                                return state.bankFees
                                        .where((bf) =>
                                            bf.label == 'Debit Card fee')
                                        .isEmpty
                                    ? const SizedBox.shrink()
                                    : Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: TextWidget(
                                          text:
                                              '+${state.bankFees.where((bf) => bf.label == 'Debit Card fee').first.amount}%',
                                          fontSize: 11,
                                          color: ColorName.primaryColor,
                                          weight: FontWeight.w400,
                                        ),
                                      );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                      subtitle: const TextWidget(
                        text: '',
                        fontSize: 11,
                        weight: FontWeight.w400,
                      ),
                    )),
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: (showFee == true && selectedPaymentMethodIndex != 2)
                ? 0.0
                : 1.0,
            duration: const Duration(milliseconds: 400),
            onEnd: () {
              if (showFee == true) {
                setState(() {
                  isAnimationFinished = true;
                });
              }
            },
            child: Visibility(
              visible:
                  (isAnimationFinished && selectedPaymentMethodIndex != 2) ==
                      false,
              child: Padding(
                padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
                child: CardWidget(
                    boxBorder: Border.all(
                        color: selectedPaymentMethodIndex == 2
                            ? ColorName.primaryColor
                            : Colors.transparent),
                    width: 100.sw,
                    borderRadius: BorderRadius.circular(14),
                    child: ListTile(
                      shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      onTap: () {
                        if (selectedPaymentMethodIndex == 2) {
                          setState(() {
                            showFee = false;
                            isAnimationFinished = false;
                            selectedPaymentMethodIndex = -1;
                          });
                        } else {
                          setState(() {
                            selectedPaymentMethodIndex = 2;
                          });
                        }
                      },
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: ColorName.primaryColor,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: const Center(
                          child: TextWidget(
                            text: 'C',
                            color: ColorName.white,
                            weight: FontWeight.w400,
                          ),
                        ),
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 15),
                      trailing: Checkbox(
                        activeColor: ColorName.primaryColor,
                        shape: const CircleBorder(),
                        value: selectedPaymentMethodIndex == 2,
                        onChanged: (value) {
                          setState(() {
                            selectedPaymentMethodIndex = 2;
                          });
                        },
                      ),
                      title: Row(
                        children: [
                          const TextWidget(
                            text: 'Credit Card',
                            fontSize: 15,
                          ),
                          BlocBuilder<BankFeeBloc, BankFeeState>(
                            builder: (context, state) {
                              if (state is BankFeeSuccess) {
                                return state.bankFees
                                        .where((bf) =>
                                            bf.label == 'Credit Card fee')
                                        .isEmpty
                                    ? const SizedBox.shrink()
                                    : Container(
                                        margin: const EdgeInsets.only(left: 10),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.4),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: TextWidget(
                                          text:
                                              '+${state.bankFees.where((bf) => bf.label == 'Credit Card fee').first.amount}%',
                                          fontSize: 11,
                                          color: ColorName.primaryColor,
                                          weight: FontWeight.w400,
                                        ),
                                      );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                      subtitle: const TextWidget(
                        text: '',
                        fontSize: 11,
                        weight: FontWeight.w400,
                      ),
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildAmountTextInput(List currencies) {
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
            TextFieldWidget(
              focusNode: amonutFocus,
              onChanged: (p0) {
                if (p0.isNotEmpty) {
                  setState(() {});
                }
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              validator: (text) {
                if (text?.isEmpty == true) {
                  return 'Amount is Empty';
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
              suffix: Container(
                margin: const EdgeInsets.only(right: 3, top: 3, bottom: 3),
                width: 102,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(
                    30,
                  ),
                ),
                child: currencies.isNotEmpty
                    ? DropdownButton(
                        underline: const SizedBox.shrink(),
                        value: selectedCurrency,
                        items: [
                          for (var currency in currencies)
                            DropdownMenuItem(
                              value: currency.toLowerCase(),
                              alignment: Alignment.center,
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
                                      'icons/currency/${currency.toLowerCase()}.png',
                                      fit: BoxFit.cover,
                                      package: 'currency_icons',
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  TextWidget(
                                    text: currency,
                                    fontSize: 12,
                                    weight: FontWeight.w700,
                                  ),
                                ],
                              ),
                            )
                        ],
                        onChanged: (value) {
                          if (value is String?) {
                            setState(() {
                              selectedCurrency = value ?? 'usd';
                            });
                          }
                        })
                    : const SizedBox.shrink(),
              ),
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
                          walletName: '${selectedWalletModel!.currency} Wallet',
                          logo:
                              'icons/currency/${selectedWalletModel!.currency.toLowerCase()}.png',
                          amount: selectedWalletModel!.balance.toDouble(),
                          color: const Color(0xFF3440EC),
                        )
                      : WalletCard(
                          height: 120,
                          showPattern: true,
                          walletName: '${state.wallets.first.currency} Wallet',
                          logo:
                              'icons/currency/${state.wallets.first.currency.toLowerCase()}.png',
                          amount: state.wallets.first.balance.toDouble(),
                          color: const Color(0xFF3440EC),
                        ),
                );
              }
              return const SizedBox(
                height: 120,
                child: Center(
                  child: TextWidget(text: "No Wallet Found"),
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
                  final selectedWallet =
                      await showChangeWalletModal(context: context);
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
            const SizedBox(height: 30),
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
                  child: BlocBuilder<BankFeeBloc, BankFeeState>(
                    builder: (context, state) {
                      if (state is BankFeeLoading) {
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
                      } else if (state is BankFeeSuccess) {
                        return Column(
                          children: [
                            for (var bankFee in state.bankFees)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 34,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextWidget(
                                              text: bankFee.label,
                                              color: const Color(0xFF7B7B7B),
                                              fontSize: 14,
                                              weight: FontWeight.w400,
                                            ),
                                            // const Row(
                                            //   children: [
                                            //     Icon(
                                            //       Icons.info_outline,
                                            //       color: ColorName.yellow,
                                            //       size: 12,
                                            //     ),
                                            //     SizedBox(width: 3),
                                            //     TextWidget(
                                            //       text:
                                            //           'Included by the bank',
                                            //       fontSize: 9,
                                            //       weight: FontWeight.w400,
                                            //       color: ColorName.yellow,
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            TextWidget(
                                              text:
                                                  '\$${((double.tryParse(amountController.text) ?? 0) * (bankFee.amount / 100)).toStringAsFixed(2)}',
                                              fontSize: 14,
                                              weight: FontWeight.w500,
                                            ),
                                            IconButton(
                                              style: IconButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                              ),
                                              onPressed: () {
                                                //
                                              },
                                              icon: const Icon(
                                                Icons.info_outline,
                                                size: 17,
                                                color: Color(0xFFD0D0D0),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    ),
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
                                      var creditCardAmount = state.bankFees
                                              .where((bf) =>
                                                  bf.label == 'Credit Card fee')
                                              .isEmpty
                                          ? 0
                                          : state.bankFees
                                              .where((bf) =>
                                                  bf.label == 'Credit Card fee')
                                              .first
                                              .amount;
                                      var debitCardAmount = state.bankFees
                                              .where((bf) =>
                                                  bf.label == 'Debit Card fee')
                                              .isEmpty
                                          ? 0
                                          : state.bankFees
                                              .where((bf) =>
                                                  bf.label == 'Debit Card fee')
                                              .first
                                              .amount;

                                      log('credit: $creditCardAmount');
                                      log('debit: $debitCardAmount');

                                      return Row(
                                        children: [
                                          if (feeState is FeeSuccess)
                                            TextWidget(
                                              text:
                                                  '\$${((selectedPaymentMethodIndex == 1 ? ((double.tryParse(amountController.text) ?? 0) * (debitCardAmount / 100)) : selectedPaymentMethodIndex == 2 ? ((double.tryParse(amountController.text) ?? 0) * (creditCardAmount / 100)) : 0)).toStringAsFixed(2)}',
                                              fontSize: 16,
                                              weight: FontWeight.w500,
                                            )
                                          else
                                            const TextWidget(
                                              text: '\$--',
                                              fontSize: 16,
                                              weight: FontWeight.w500,
                                            ),
                                          IconButton(
                                            style: IconButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                            ),
                                            onPressed: () {
                                              //
                                            },
                                            icon: const Icon(
                                              Icons.info_outline,
                                              size: 17,
                                              color: Color(0xFFD0D0D0),
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
}
