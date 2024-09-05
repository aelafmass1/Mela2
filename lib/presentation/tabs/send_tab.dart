// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/bank_fee/bank_fee_bloc.dart';
import 'package:transaction_mobile_app/bloc/banks/banks_bloc.dart';
import 'package:transaction_mobile_app/bloc/money_transfer/money_transfer_bloc.dart';
import 'package:transaction_mobile_app/bloc/payment_card/payment_card_bloc.dart';
import 'package:transaction_mobile_app/bloc/payment_intent/payment_intent_bloc.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../bloc/currency/currency_bloc.dart';
import '../../bloc/fee/fee_bloc.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/plaid/plaid_bloc.dart';
import '../../config/routing.dart';
import '../widgets/custom_shimmer.dart';

class SentTab extends StatefulWidget {
  const SentTab({super.key});

  @override
  State<SentTab> createState() => _SentTabState();
}

class _SentTabState extends State<SentTab> {
  int index = 0;
  String selectedBanks = '';

  double sliderWidth = 0;
  double contactListHeight = 250;

  bool isSearching = false;
  bool showBorder = true;
  bool isPermissionDenied = false;

  int selectedPaymentMethodIndex = 0;

  String whoPayFee = 'SENDER';
  String selectedBank = '';

  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];

  double exchangeRate = 0;

  final _exchangeRateFormKey = GlobalKey<FormState>();
  final _recipientSelectionFormKey = GlobalKey<FormState>();

  Contact? selectedContact;

  double percentageFee = 0;

  final searchContactController = TextEditingController();
  final receiverName = TextEditingController();
  final usdController = TextEditingController();
  final etbController = TextEditingController();
  final bankAcocuntController = TextEditingController();
  final phoneNumberController = TextEditingController();

  ReceiverInfo? receiverInfo;

  LinkConfiguration? _configuration;
  StreamSubscription<LinkEvent>? _streamEvent;
  StreamSubscription<LinkExit>? _streamExit;
  StreamSubscription<LinkSuccess>? _streamSuccess;
  String? publicToken;

  @override
  void dispose() {
    _streamEvent?.cancel();
    _streamExit?.cancel();
    _streamSuccess?.cancel();
    super.dispose();
  }

  void _createLinkTokenConfiguration(String linkToken) {
    setState(() {
      _configuration = LinkTokenConfiguration(
        token: linkToken,
      );
    });
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

  /// Fetches the user's contacts if permission is granted.
  ///
  /// If the user has not been asked for contact permission before,
  /// it requests permission and fetches contacts if granted.
  /// If permission has been asked before and denied, it sets [isPermissionDenied] to true.
  /// If permission has been granted, it fetches contacts and updates the [contacts] list.
  Future<void> _fetchContacts() async {
    if (await isPermissionAsked() == false) {
      // Permission has not been asked before
      if (await FlutterContacts.requestPermission(readonly: true)) {
        List<Contact> c =
            await FlutterContacts.getContacts(withProperties: true);
        setState(() {
          contacts = c;
        });
      }
      checkContactPermission();
    } else {
      // Permission has been asked before
      if (contacts.isEmpty) {
        // Permission was denied
        setState(() {
          isPermissionDenied = true;
        });
      }
    }
  }

  /// Checks the status of the contact permission and handles different scenarios.
  ///
  /// If permission is granted, logs a message.
  /// If permission is denied and it's the first time asking, navigates to a permission request screen.
  /// If permission is denied and it's not the first time asking, sets [isPermissionDenied] to true.
  /// If permission is permanently denied, sets [isPermissionDenied] to true and logs a message.
  void checkContactPermission() async {
    // Check if the contact permission is already granted
    PermissionStatus status = await Permission.contacts.status;

    if (status.isGranted) {
      log("Contact permission granted.");
    } else if (status.isDenied) {
      if (await isPermissionAsked() == false) {
        // Permission denied for the first time, navigate to permission request screen
        changePermissionAskedState(true);
        context.pushNamed(
          RouteName.contactPermission,
          extra: checkContactPermission,
        );
      } else {
        // Permission denied, not the first time
        setState(() {
          isPermissionDenied = true;
        });
      }
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied
      setState(() {
        isPermissionDenied = true;
      });
      log("Contact permission permanently denied.");
    }
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

      // Show a success message if the payment is successful
      showSnackbar(
        context,
        title: 'Success',
        description: 'Payment Successful!',
      );

      // Get the current user
      final auth = FirebaseAuth.instance;
      if (auth.currentUser != null) {
        // Create a ReceiverInfo object with the recipient's information
        receiverInfo = ReceiverInfo(
          senderUserId: auth.currentUser!.uid,
          receiverName: receiverName.text,
          receiverPhoneNumber: isPermissionDenied
              ? phoneNumberController.text
              : selectedContact!.phones.first.number,
          receiverBankName: selectedBank,
          receiverAccountNumber: bankAcocuntController.text,
          amount: double.parse(usdController.text),
          serviceChargePayer: whoPayFee,
        );
        // Add a SendMoney event to the MoneyTransferBloc to initiate the money transfer
        context.read<MoneyTransferBloc>().add(
              SendMoney(
                receiverInfo: receiverInfo!,
                paymentId: paymentIntent.id,
              ),
            );
      }
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
    _streamEvent = PlaidLink.onEvent.listen(_onEvent);
    _streamExit = PlaidLink.onExit.listen(_onExit);
    _streamSuccess = PlaidLink.onSuccess.listen(_onSuccess);
    final state = context.read<CurrencyBloc>().state;
    if (state is CurrencySuccess) {
      setState(() {
        exchangeRate =
            state.currencies.where((c) => c.currencyCode == 'USD').first.rate;
      });
    }
    final navState = context.read<NavigationBloc>().state;
    if (navState.moneyAmount != null) {
      usdController.text = navState.moneyAmount.toString();
      etbController.text = (navState.moneyAmount! * exchangeRate).toString();
    }

    context.read<CurrencyBloc>().add(FetchAllCurrencies());
    context.read<FeeBloc>().add(FetchFees());
    context.read<PaymentCardBloc>().add(FetchPaymentCards());
    context.read<BanksBloc>().add(FetchBanks());
    context.read<BankFeeBloc>().add(FetchBankFee());

    super.initState();
  }

  void clearSendInfo() {
    setState(() {
      index = 0;
      selectedBanks = '';
      sliderWidth = 0;
      contactListHeight = 250;
      isSearching = false;
      showBorder = true;
      selectedPaymentMethodIndex = 1;
      whoPayFee = 'SENDER';
      selectedBank = '';
      contacts = [];
      filteredContacts = [];
      searchContactController.text = '';
      receiverName.text = '';
      usdController.text = '';
      etbController.text = '';
      bankAcocuntController.text = '';
      receiverInfo = null;
      exchangeRate = 101.98;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leadingWidth: index == 0 ? 200 : null,
        centerTitle: true,
        toolbarHeight: 50,
        titleSpacing: 0,
        title: index == 1 || index == 2
            ? TextWidget(
                text: index == 1 ? 'Select Recipient' : 'Payment Method',
                fontSize: 20,
                weight: FontWeight.w700,
              )
            : null,
        leading: index == 0
            ? const Padding(
                padding: EdgeInsets.only(left: 15, top: 10),
                child: TextWidget(
                  text: 'Send Money',
                  fontSize: 20,
                ),
              )
            : index == 1 || index == 2
                ? IconButton(
                    onPressed: () {
                      if (index == 1) {
                        setState(() {
                          index = 0;
                        });
                      } else {
                        setState(() {
                          index = 1;
                        });
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                  )
                : null,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Stack(
          children: [
            _buildExchangeRate(),
            _buildRecipientSelection(),
            _builPaymentMethodSelection(),
          ],
        ),
      ),
    );
  }

  _buildExchangeRate() {
    return Visibility(
      visible: index == 0,
      child: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: ColorName.primaryColor,
              onRefresh: () async {
                context.read<CurrencyBloc>().add(FetchAllCurrencies());
                context.read<FeeBloc>().add(FetchFees());
                context.read<PaymentCardBloc>().add(FetchPaymentCards());
                context.read<BanksBloc>().add(FetchBanks());
                context.read<BankFeeBloc>().add(FetchBankFee());
                await Future.delayed(Durations.extralong1);
                //
              },
              child: SingleChildScrollView(
                child: Form(
                  key: _exchangeRateFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 100.sw,
                        height: 120,
                        child: Row(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100.sw,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      color: ColorName.primaryColor,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: SvgPicture.asset(
                                      Assets.images.svgs.cardPattern,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    left: 10,
                                    right: 10,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10),
                                          child: TextWidget(
                                            text: 'Current Trade rate',
                                            color: Colors.white,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Container(
                                          width: 100.sw,
                                          height: 52,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundImage: Assets
                                                        .images.usaFlag
                                                        .provider(),
                                                  ),
                                                  const SizedBox(width: 7),
                                                  const Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      TextWidget(
                                                        text: 'US Dollar',
                                                        fontSize: 9,
                                                        weight: FontWeight.w500,
                                                        color: ColorName
                                                            .primaryColor,
                                                      ),
                                                      TextWidget(
                                                        text: '1 USD',
                                                        fontSize: 14,
                                                        color: ColorName
                                                            .primaryColor,
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                              Container(
                                                width: 28,
                                                height: 28,
                                                padding:
                                                    const EdgeInsets.all(5),
                                                decoration: const BoxDecoration(
                                                  color: ColorName.primaryColor,
                                                  shape: BoxShape.circle,
                                                ),
                                                child: SvgPicture.asset(
                                                  Assets
                                                      .images.svgs.exchangeIcon,
                                                  // ignore: deprecated_member_use
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundImage: Assets
                                                        .images.ethiopianFlag
                                                        .provider(),
                                                  ),
                                                  const SizedBox(width: 7),
                                                  Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const TextWidget(
                                                        text: 'ET Birr',
                                                        fontSize: 9,
                                                        weight: FontWeight.w500,
                                                        color: ColorName
                                                            .primaryColor,
                                                      ),
                                                      BlocConsumer<CurrencyBloc,
                                                          CurrencyState>(
                                                        listener:
                                                            (context, state) {
                                                          if (state
                                                              is CurrencySuccess) {
                                                            setState(() {
                                                              exchangeRate = state
                                                                  .currencies
                                                                  .where((c) =>
                                                                      c.currencyCode ==
                                                                      'USD')
                                                                  .first
                                                                  .rate;
                                                            });
                                                          }
                                                        },
                                                        builder:
                                                            (context, state) {
                                                          if (state
                                                              is CurrencyLoading) {
                                                            return const Padding(
                                                              padding: EdgeInsets
                                                                  .only(top: 3),
                                                              child:
                                                                  CustomShimmer(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .zero,
                                                                width: 60,
                                                                height: 16,
                                                              ),
                                                            );
                                                          }
                                                          if (state
                                                              is CurrencySuccess) {
                                                            return TextWidget(
                                                              text:
                                                                  '${state.currencies.where((c) => c.currencyCode == 'USD').first.rate.toStringAsFixed(2)} ETB',
                                                              fontSize: 14,
                                                              color: ColorName
                                                                  .primaryColor,
                                                            );
                                                          }
                                                          return const TextWidget(
                                                            text: '--',
                                                            fontSize: 14,
                                                            color: ColorName
                                                                .primaryColor,
                                                          );
                                                        },
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      CardWidget(
                        width: 100.sw,
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const TextWidget(
                              text: 'Send Money',
                              fontSize: 14,
                            ),
                            const SizedBox(height: 10),
                            _buildExchangeInputs(),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 15),
                              child: Divider(
                                color: Colors.black12,
                              ),
                            ),
                            Container(
                              width: 100.sw,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 15, horizontal: 15),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: ColorName.borderColor,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const TextWidget(
                                    text:
                                        'Who’s going to pay the service charge?',
                                    fontSize: 14,
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          Radio(
                                              activeColor:
                                                  ColorName.primaryColor,
                                              value: 'SENDER',
                                              groupValue: whoPayFee,
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    whoPayFee = value;
                                                  });
                                                }
                                              }),
                                          const TextWidget(
                                            text: 'Me',
                                            fontSize: 13,
                                            weight: FontWeight.w300,
                                          )
                                        ],
                                      ),
                                      const SizedBox(width: 20),
                                      Row(
                                        children: [
                                          Radio(
                                              activeColor:
                                                  ColorName.primaryColor,
                                              value: 'RECEIVER',
                                              groupValue: whoPayFee,
                                              onChanged: (value) {
                                                if (value != null) {
                                                  setState(() {
                                                    whoPayFee = value;
                                                  });
                                                }
                                              }),
                                          const TextWidget(
                                            text: 'Recipient',
                                            fontSize: 13,
                                            weight: FontWeight.w300,
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                  BlocBuilder<FeeBloc, FeeState>(
                                    builder: (context, state) {
                                      if (state is FeeLoading) {
                                        return Column(
                                          children: [
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
                                            const Divider(
                                              color: ColorName.borderColor,
                                            ),
                                            CustomShimmer(
                                              width: 100.sw,
                                              height: 34,
                                            ),
                                          ],
                                        );
                                      }
                                      if (state is FeeSuccess) {
                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            for (var fee in state.fees)
                                              Column(
                                                key: ValueKey(fee.id),
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Divider(
                                                    color:
                                                        ColorName.borderColor,
                                                  ),
                                                  SizedBox(
                                                    height: 34,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        SizedBox(
                                                          width: 34.sw,
                                                          child: Row(
                                                            children: [
                                                              TextWidget(
                                                                text: fee.label,
                                                                color: const Color(
                                                                    0xFF7B7B7B),
                                                                fontSize: 14,
                                                                weight:
                                                                    FontWeight
                                                                        .w400,
                                                              ),
                                                              const SizedBox(
                                                                  width: 5),
                                                              Visibility(
                                                                visible: fee
                                                                        .type ==
                                                                    'PERCENTAGE',
                                                                child:
                                                                    TextWidget(
                                                                  text:
                                                                      '${fee.amount == fee.amount.toInt() ? fee.amount.toInt() : fee.amount}%',
                                                                  color: Colors
                                                                      .black87,
                                                                  fontSize: 14,
                                                                  weight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Visibility(
                                                          visible: fee.type ==
                                                              'FIXED',
                                                          replacement: Row(
                                                            children: [
                                                              Container(
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                width: 25.sw,
                                                                child:
                                                                    TextWidget(
                                                                  text: usdController
                                                                          .text
                                                                          .isEmpty
                                                                      ? '--'
                                                                      : '\$${((double.tryParse(usdController.text) ?? 0) * (fee.amount / 100)).toStringAsFixed(2)}',
                                                                  fontSize: 14,
                                                                  weight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                              IconButton(
                                                                style: IconButton
                                                                    .styleFrom(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                ),
                                                                onPressed: () {
                                                                  //
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .info_outline,
                                                                  color: Color(
                                                                      0xFFD0D0D0),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              TextWidget(
                                                                text:
                                                                    '\$${fee.amount}',
                                                                fontSize: 14,
                                                                weight:
                                                                    FontWeight
                                                                        .w500,
                                                              ),
                                                              IconButton(
                                                                style: IconButton
                                                                    .styleFrom(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .zero,
                                                                ),
                                                                onPressed: () {
                                                                  //
                                                                },
                                                                icon:
                                                                    const Icon(
                                                                  Icons
                                                                      .info_outline,
                                                                  color: Color(
                                                                      0xFFD0D0D0),
                                                                ),
                                                              )
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              )
                                          ],
                                        );
                                      }
                                      return const SizedBox.shrink();
                                    },
                                  ),
                                  const Divider(
                                    color: ColorName.borderColor,
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
                                          weight: FontWeight.w400,
                                        ),
                                        BlocBuilder<FeeBloc, FeeState>(
                                          builder: (context, state) {
                                            return Row(
                                              children: [
                                                if (state is FeeSuccess)
                                                  TextWidget(
                                                    text:
                                                        '\$${((state.fees.where((f) => f.type == 'FIXED').map((f) => f.amount).reduce((value, element) => value + element)) + (state.fees.where((f) => f.type == 'PERCENTAGE').map((f) => (((double.tryParse(usdController.text) ?? 0) * (f.amount / 100)))).reduce((value, element) => value + element))).toStringAsFixed(2)}',
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
                                                    color: Color(0xFFD0D0D0),
                                                  ),
                                                )
                                              ],
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ButtonWidget(
              child: const TextWidget(
                text: 'Next',
                type: TextType.small,
                color: Colors.white,
              ),
              onPressed: () {
                if (_exchangeRateFormKey.currentState!.validate()) {
                  _fetchContacts();
                  setState(() {
                    index = 1;
                  });
                }
              }),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  _buildRecipientSelection() {
    return Visibility(
      visible: index == 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: CardWidget(
          width: 100.sw,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
          child: Form(
            key: _recipientSelectionFormKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextWidget(
                    text: isPermissionDenied ? 'Phone Number' : 'To',
                    type: TextType.small,
                  ),
                  const SizedBox(height: 10),
                  Visibility(
                    visible: isPermissionDenied == false,
                    replacement: TextFieldWidget(
                      validator: (text) {
                        if (isPermissionDenied) {
                          if (text!.isEmpty) {
                            return 'Phone number is empty';
                          }
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      inputFormatters: <TextInputFormatter>[
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^[0-9]*[+]?[0-9]*$')),
                      ],
                      hintText: 'Enter phone number',
                      controller: phoneNumberController,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      onEnd: () {
                        if (contactListHeight != 250) {
                          setState(() {
                            showBorder = false;
                          });
                        }
                      },
                      height: contactListHeight,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: showBorder
                              ? Border.all(
                                  color: ColorName.borderColor,
                                )
                              : null),
                      child: Column(
                        children: [
                          TextFormField(
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'receiver is selected';
                              }
                              return null;
                            },
                            onChanged: (text) {
                              if (text.isEmpty) {
                                setState(() {
                                  isSearching = false;
                                });
                              } else {
                                setState(() {
                                  isSearching = true;
                                  filteredContacts = contacts
                                      .where((contact) => contact.displayName
                                          .toLowerCase()
                                          .contains(searchContactController.text
                                              .toLowerCase()))
                                      .toList();
                                });
                              }
                              setState(() {
                                contactListHeight = 250;
                                showBorder = true;
                              });
                            },
                            controller: searchContactController,
                            decoration: InputDecoration(
                              suffixIcon:
                                  searchContactController.text.isNotEmpty
                                      ? IconButton(
                                          style: IconButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                          ),
                                          icon: const Icon(
                                            Icons.close,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              searchContactController.text = '';
                                              isSearching = false;
                                              contactListHeight = 250;
                                              showBorder = true;
                                            });
                                          },
                                        )
                                      : null,
                              prefixIcon: const Icon(BoxIcons.bx_search),
                              focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black45),
                                  borderRadius: BorderRadius.circular(40)),
                              border: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.black45),
                                  borderRadius: BorderRadius.circular(40)),
                            ),
                          ),
                          Visibility(
                            visible: showBorder,
                            child: Expanded(
                              child: isSearching
                                  ? ListView.builder(
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          onTap: () {
                                            searchContactController.text =
                                                filteredContacts[index]
                                                    .displayName;
                                            setState(() {
                                              selectedContact =
                                                  filteredContacts[index];
                                              contactListHeight = 58;
                                            });
                                          },
                                          leading: contacts[index].photo == null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Container(
                                                    width: 36,
                                                    height: 36,
                                                    color:
                                                        ColorName.primaryColor,
                                                    alignment: Alignment.center,
                                                    child: TextWidget(
                                                      text: contacts[index]
                                                          .displayName[0],
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Image.memory(
                                                    contacts[index].photo!,
                                                    width: 36,
                                                    height: 36,
                                                    fit: BoxFit.cover,
                                                  )),
                                          title: TextWidget(
                                            text: filteredContacts[index]
                                                .displayName,
                                            fontSize: 13,
                                          ),
                                          subtitle: TextWidget(
                                            text: filteredContacts[index]
                                                .phones
                                                .first
                                                .number,
                                            fontSize: 13,
                                          ),
                                        );
                                      },
                                      itemCount: filteredContacts.length,
                                    )
                                  : ListView.builder(
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          onTap: () {
                                            searchContactController.text =
                                                contacts[index].displayName;
                                            setState(() {
                                              selectedContact = contacts[index];
                                              contactListHeight = 58;
                                            });
                                          },
                                          leading: contacts[index].photo == null
                                              ? ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Container(
                                                    width: 36,
                                                    height: 36,
                                                    color:
                                                        ColorName.primaryColor,
                                                    alignment: Alignment.center,
                                                    child: TextWidget(
                                                      text: contacts[index]
                                                          .displayName[0],
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Image.memory(
                                                    contacts[index].photo!,
                                                    width: 36,
                                                    height: 36,
                                                    fit: BoxFit.cover,
                                                  )),
                                          title: TextWidget(
                                            text: contacts[index].displayName,
                                            fontSize: 13,
                                          ),
                                          subtitle: TextWidget(
                                            text: contacts[index]
                                                .phones
                                                .first
                                                .number,
                                            fontSize: 13,
                                          ),
                                        );
                                      },
                                      itemCount: contacts.length,
                                    ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const TextWidget(
                    text: 'Bank',
                    type: TextType.small,
                  ),
                  const SizedBox(height: 5),
                  BlocBuilder<BanksBloc, BanksState>(
                    builder: (context, state) {
                      return DropdownButtonFormField(
                        validator: (value) {
                          if (selectedBank.isEmpty) {
                            return 'Bank not selected';
                          }
                          return null;
                        },
                        value: selectedBank.isEmpty ? null : selectedBank,
                        isExpanded: true,
                        hint: const TextWidget(
                          text: 'Select Bank',
                          fontSize: 14,
                          color: Color(0xFF8E8E8E),
                          weight: FontWeight.w500,
                        ),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(40),
                            borderSide: const BorderSide(
                              color: ColorName.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        items: [
                          if (state is BanksSuccess)
                            for (var bank in state.bankList)
                              DropdownMenuItem(
                                value: bank.bankName,
                                child: Row(
                                  children: [
                                    if (bank.bankLogo != null)
                                      CachedNetworkImage(
                                        imageUrl: bank.bankLogo!,
                                      )
                                    else
                                      const SizedBox(
                                        width: 24,
                                        height: 24,
                                      ),
                                    // Assets.images.cbeLogo.image(
                                    //   width: 24,
                                    // ),
                                    const SizedBox(width: 10),
                                    TextWidget(
                                      text: bank.bankName,
                                      type: TextType.small,
                                    ),
                                  ],
                                ),
                              )

                          // DropdownMenuItem(
                          //   value: 'Abyisinia Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.abysiniaLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Abyisinia Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Ahadu Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.ahaduLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Ahadu Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Abay Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.abayBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Abay Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Amhara Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.amaraBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Amhara Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Bank of Oromia',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.bankOfOromo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Bank of Oromia',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Awash Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.awashBank.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Awash Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Birhan Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.birhanBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Birhan Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Buna Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.bunaBank.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Buna Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Dashen Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.dashnBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Dashen Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Gedda Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.gedaBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Gedda Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Enat Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.enatBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Enat Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Global Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.globalBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Global Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Hibret Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.hibretBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Hibret Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Hijra Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.hijraBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Hijra Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Nib Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.nibBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Nib Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Oromia Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.oromiaBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Oromia Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Sinqe Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.sinqeBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Sinqe Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Tsedey Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.tsedeyBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Tsedey Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Tsehay Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.tsehayBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Tsehay Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Wegagen Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.wegagenBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Wegagen Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // DropdownMenuItem(
                          //   value: 'Zemen Bank',
                          //   child: Row(
                          //     children: [
                          //       Assets.images.zemenBankLogo.image(
                          //         width: 24,
                          //       ),
                          //       const SizedBox(width: 10),
                          //       const TextWidget(
                          //         text: 'Zemen Bank',
                          //         type: TextType.small,
                          //       ),
                          //     ],
                          //   ),
                          // ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedBank = value;
                            });
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  const TextWidget(
                    text: 'Receiver Full Name',
                    type: TextType.small,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: receiverName,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'receiver name is empty';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 17),
                      hintText: 'Select recipient Bank account',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black45),
                          borderRadius: BorderRadius.circular(40)),
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black45),
                          borderRadius: BorderRadius.circular(40)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const TextWidget(
                    text: 'Bank Account',
                    type: TextType.small,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: bankAcocuntController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'bank account is empty';
                      }
                      return null;
                    },
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^[0-9]*[]?[0-9]*$')),
                    ],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 17),
                      hintText: 'Enter recipient Bank account',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black45),
                          borderRadius: BorderRadius.circular(40)),
                      border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black45),
                          borderRadius: BorderRadius.circular(40)),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ButtonWidget(
                      child: const TextWidget(
                        text: 'Next',
                        type: TextType.small,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (_recipientSelectionFormKey.currentState!
                            .validate()) {
                          setState(() {
                            index = 2;
                          });
                        }
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _builPaymentMethodSelection() {
    return Visibility(
      visible: index == 2,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<PaymentCardBloc, PaymentCardState>(
                      builder: (context, state) {
                        return CardWidget(
                          width: 100.sw,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 30),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const TextWidget(
                                text: 'Select Payment Method',
                                type: TextType.small,
                              ),
                              const SizedBox(height: 10),
                              CardWidget(
                                  width: 100.sw,
                                  borderRadius: BorderRadius.circular(14),
                                  child: ListTile(
                                    onTap: () {
                                      setState(() {
                                        selectedPaymentMethodIndex = 0;
                                      });
                                    },
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: ColorName.primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: const Center(
                                        child: TextWidget(
                                          text: 'B',
                                          color: ColorName.white,
                                          weight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15),
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
                                          margin:
                                              const EdgeInsets.only(left: 10),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                              color: ColorName.green,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
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
                              const SizedBox(height: 15),
                              CardWidget(
                                  width: 100.sw,
                                  borderRadius: BorderRadius.circular(14),
                                  child: ListTile(
                                    onTap: () {
                                      setState(() {
                                        selectedPaymentMethodIndex = 1;
                                      });
                                    },
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: ColorName.primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: const Center(
                                        child: TextWidget(
                                          text: 'D',
                                          color: ColorName.white,
                                          weight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15),
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
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                    left: 10),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: TextWidget(
                                                  text:
                                                      '+${state.bankFees.where((bf) => bf.paymentMethod == 'DEBIT').first.amount}%',
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
                              const SizedBox(height: 15),

                              CardWidget(
                                  width: 100.sw,
                                  borderRadius: BorderRadius.circular(14),
                                  child: ListTile(
                                    onTap: () {
                                      setState(() {
                                        selectedPaymentMethodIndex = 2;
                                      });
                                    },
                                    leading: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: ColorName.primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(100),
                                      ),
                                      child: const Center(
                                        child: TextWidget(
                                          text: 'C',
                                          color: ColorName.white,
                                          weight: FontWeight.w400,
                                        ),
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 15),
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
                                              return Container(
                                                margin: const EdgeInsets.only(
                                                    left: 10),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 7,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                    color: Colors.grey
                                                        .withOpacity(0.4),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: TextWidget(
                                                  text:
                                                      '+${state.bankFees.where((bf) => bf.paymentMethod == 'CREDIT').first.amount}%',
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
                              // for (int i = 0;
                              //     i < state.paymentCards.length;
                              //     i++)
                              //   _buildPaymentMethodTile(
                              //     id: 0 + 3,
                              //     iconPath: Assets.images.masteredCard.path,
                              //     title: state.paymentCards[i].cardBrand,
                              //     subTitle:
                              //         '${state.paymentCards[i].cardBrand} ending   ** ${state.paymentCards[i].last4Digits}',
                              //   ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    CardWidget(
                      width: 100.sw,
                      padding: const EdgeInsets.all(15),
                      child: Container(
                        width: 100.sw,
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: ColorName.borderColor,
                          ),
                        ),
                        child: BlocBuilder<BankFeeBloc, BankFeeState>(
                          builder: (context, state) {
                            if (state is BankFeeSuccess) {
                              return Column(
                                children: [
                                  for (var bankFee in state.bankFees)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                                    color:
                                                        const Color(0xFF7B7B7B),
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
                                                        '\$${(double.parse(usdController.text) * (bankFee.amount / 100)).toStringAsFixed(2)}',
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
                                            return Row(
                                              children: [
                                                if (feeState is FeeSuccess)
                                                  TextWidget(
                                                    text:
                                                        '\$${((feeState.fees.where((f) => f.type == 'FIXED').map((f) => f.amount).reduce((value, element) => value + element)) + (feeState.fees.where((f) => f.type == 'PERCENTAGE').map((f) => (((double.tryParse(usdController.text) ?? 0) * (f.amount / 100)))).reduce((value, element) => value + element)) + (selectedPaymentMethodIndex == 1 ? ((double.tryParse(usdController.text) ?? 0) * (state.bankFees.where((bf) => bf.paymentMethod == 'DEBIT').first.amount / 100)) : selectedPaymentMethodIndex == 2 ? (state.bankFees.where((bf) => bf.paymentMethod == 'CREDIT').first.amount) : 0)).toStringAsFixed(2)}',
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            BlocConsumer<PaymentIntentBloc, PaymentIntentState>(
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
                  } catch (error) {
                    log(error.toString());
                  }
                }
              },
              builder: (context, paymentState) =>
                  BlocConsumer<MoneyTransferBloc, MoneyTransferState>(
                listener: (context, state) async {
                  if (state is MoneyTransferFail) {
                    showSnackbar(
                      context,
                      title: 'Error',
                      description: state.reason,
                    );
                  } else if (state is MoneyTransferSuccess) {
                    context.pushNamed(
                      RouteName.receipt,
                      extra: receiverInfo,
                    );

                    clearSendInfo();
                  }
                },
                builder: (context, state) {
                  return BlocConsumer<PlaidBloc, PlaidState>(
                    listener: (context, state) async {
                      if (state is PlaidLinkTokenFail) {
                        showSnackbar(
                          context,
                          title: 'Error',
                          description: state.reason,
                        );
                      } else if (state is PlaidLinkTokenSuccess) {
                        _createLinkTokenConfiguration(state.linkToken);
                        await PlaidLink.open(configuration: _configuration!);
                      } else if (state is PlaidPublicTokenFail) {
                        showSnackbar(
                          context,
                          title: 'Error',
                          description: state.reason,
                        );
                      } else if (state is PlaidPublicTokenSuccess) {
                        final auth = FirebaseAuth.instance;
                        receiverInfo = ReceiverInfo(
                          senderUserId: auth.currentUser!.uid,
                          receiverName: receiverName.text,
                          receiverPhoneNumber: isPermissionDenied
                              ? phoneNumberController.text
                              : selectedContact!.phones.first.number,
                          receiverBankName: selectedBank,
                          receiverAccountNumber: bankAcocuntController.text,
                          amount: double.parse(usdController.text),
                          serviceChargePayer: whoPayFee,
                        );
                        //                 final paymentIntent =
                        // await Stripe.instance.retrievePaymentIntent(clientSecret);
                        context.read<MoneyTransferBloc>().add(SendMoney(
                            receiverInfo: receiverInfo!, paymentId: ''));
                      }
                    },
                    builder: (context, plaidState) {
                      return ButtonWidget(
                        child: state is MoneyTransferLoading ||
                                paymentState is PaymentIntentLoading ||
                                plaidState is PlaidLinkTokenLoading ||
                                plaidState is PlaidPublicTokenLoading
                            ? const LoadingWidget()
                            : const TextWidget(
                                text: 'Next',
                                type: TextType.small,
                                color: Colors.white,
                              ),
                        onPressed: () async {
                          if (selectedPaymentMethodIndex != 0) {
                            context.read<PaymentIntentBloc>().add(
                                  FetchClientSecret(
                                      currency: 'USD',
                                      amount: double.parse(usdController.text)),
                                );
                          } else {
                            context.read<PlaidBloc>().add(CreateLinkToken());
                          }
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  _buildExchangeInputs() {
    return Stack(
      children: [
        Column(
          children: [
            TextFormField(
              controller: usdController,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Enter amount';
                }
                return null;
              },
              onChanged: (value) {
                try {
                  final money = double.parse(value);
                  etbController.text =
                      (money * exchangeRate).toStringAsFixed(3);
                } catch (error) {
                  etbController.text = '';
                }
                setState(() {});
              },
              style: const TextStyle(
                fontSize: 22,
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(
                    RegExp(r'^[0-9]*[.,]?[0-9]*$')),
              ],
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                hintText: '0.00',
                hintStyle: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFFD0D0D0),
                ),
                suffixIcon: Container(
                  width: 90,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      width: 1,
                      color: Colors.black45,
                    ),
                  ),
                  child: Center(
                    child: DropdownButton(
                        value: 'usd',
                        elevation: 0,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: [
                          DropdownMenuItem(
                            value: 'usd',
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Assets.images.usaFlag.image(
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const TextWidget(
                                  text: 'USD',
                                  fontSize: 12,
                                )
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'etb',
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Assets.images.ethiopianFlag.image(
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const TextWidget(
                                  text: 'ETB',
                                  fontSize: 12,
                                )
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          //
                        }),
                  ),
                ),
                errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black45),
                    borderRadius: BorderRadius.circular(40)),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black45),
                    borderRadius: BorderRadius.circular(40)),
                border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black45),
                    borderRadius: BorderRadius.circular(40)),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: etbController,
              // validator: (value) {
              //   if (value!.isEmpty) {
              //     return 'Enter amount';
              //   }
              //   return null;
              // },
              onChanged: (value) {
                try {
                  final money = double.parse(value);
                  usdController.text =
                      (money / exchangeRate).toStringAsFixed(3);
                } catch (error) {
                  usdController.text = '';
                }
                setState(() {});
              },
              style: const TextStyle(
                fontSize: 22,
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(
                    RegExp(r'^[0-9]*[.,]?[0-9]*$')),
              ],
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                hintText: '0.00',
                hintStyle: const TextStyle(
                  fontSize: 24,
                  color: Color(0xFFD0D0D0),
                ),
                suffixIcon: Container(
                  width: 90,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(40),
                    border: Border.all(
                      width: 1,
                      color: Colors.black45,
                    ),
                  ),
                  child: Center(
                    child: DropdownButton(
                        value: 'etb',
                        elevation: 0,
                        underline: const SizedBox.shrink(),
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: [
                          DropdownMenuItem(
                            value: 'usd',
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Assets.images.usaFlag.image(
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const TextWidget(
                                  text: 'USD',
                                  fontSize: 12,
                                )
                              ],
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'etb',
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Assets.images.ethiopianFlag.image(
                                    width: 20,
                                    height: 20,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const TextWidget(
                                  text: 'ETB',
                                  fontSize: 12,
                                )
                              ],
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          //
                        }),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black45),
                    borderRadius: BorderRadius.circular(40)),
                border: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.black45),
                    borderRadius: BorderRadius.circular(40)),
              ),
            )
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Align(
            child: SizedBox(
              width: 40,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(
                      side: BorderSide(
                    color: Color(0xFFE8E8E8),
                  )),
                ),
                onPressed: () {
                  //
                },
                child: Assets.images.transactionIcon.image(
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  _buildPaymentMethodTile({
    required int id,
    required String iconPath,
    required String title,
    required String subTitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: CardWidget(
          width: 100.sw,
          borderRadius: BorderRadius.circular(14),
          child: ListTile(
            onTap: () {
              setState(() {
                selectedPaymentMethodIndex = id;
              });
            },
            leading: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                image: DecorationImage(
                    image: AssetImage(iconPath), fit: BoxFit.cover),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 15),
            trailing: Checkbox(
              activeColor: ColorName.primaryColor,
              shape: const CircleBorder(),
              value: selectedPaymentMethodIndex == id,
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethodIndex = id;
                });
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
                const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: ColorName.yellow,
                      size: 12,
                    ),
                    SizedBox(width: 3),
                    TextWidget(
                      text: 'Additional charge is going to be included',
                      fontSize: 8,
                      weight: FontWeight.w400,
                      color: ColorName.yellow,
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}
