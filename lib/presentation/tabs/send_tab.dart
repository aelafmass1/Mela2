// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plaid_flutter/plaid_flutter.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/bank_fee/bank_fee_bloc.dart';
import 'package:transaction_mobile_app/bloc/banks/banks_bloc.dart';
import 'package:transaction_mobile_app/bloc/money_transfer/money_transfer_bloc.dart';
import 'package:transaction_mobile_app/bloc/payment_card/payment_card_bloc.dart';
import 'package:transaction_mobile_app/bloc/wallet_transaction/wallet_transaction_bloc.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/core/utils/show_wallet_receipt.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/%20money_transfer/utils/show_money_receiver_selection.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../bloc/check-details-bloc/check_details_bloc.dart';
import '../../bloc/currency/currency_bloc.dart';
import '../../bloc/fee/fee_bloc.dart';
import '../../bloc/navigation/navigation_bloc.dart';
import '../../bloc/plaid/plaid_bloc.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../config/routing.dart';
import '../../data/models/payment_card_model.dart';
import '../screens/add_money_screen/components/add_payment_method_widget.dart';
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

  bool isPermissionDenied = false;
  bool isScrolledDown = false;

  int selectedPaymentMethodIndex = -1;

  String whoPayFee = 'SENDER';
  String selectedBank = '';
  String selectedPaymentCardId = '';
  String fromCurrency = 'USD';
  String toCurrency = 'ETB';

  List<PaymentCardModel> paymentCards = [];
  String? selectedPhoneNumber;

  final scrollController = ScrollController();

  double exchangeRate = 0;

  final _exchangeRateFormKey = GlobalKey<FormState>();
  final _recipientSelectionFormKey = GlobalKey<FormState>();

  double percentageFee = 0;

  final searchContactController = TextEditingController();
  final receiverName = TextEditingController();
  final usdController = TextEditingController();
  final etbController = TextEditingController();
  final bankAcocuntController = TextEditingController();
  final phoneNumberController = TextEditingController();

  ReceiverInfo? receiverInfo;

  // LinkTokenConfiguration? _configuration;
  StreamSubscription<LinkEvent>? _streamEvent;
  StreamSubscription<LinkExit>? _streamExit;
  StreamSubscription<LinkSuccess>? _streamSuccess;
  String? publicToken;

  @override
  void dispose() {
    _streamEvent?.cancel();
    _streamExit?.cancel();
    _streamSuccess?.cancel();
    scrollController.dispose();
    super.dispose();
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
        .read<PaymentCardBloc>()
        .add(AddBankAccount(publicToken: event.publicToken));
  }

  void _onExit(LinkExit event) {
    final metadata = event.metadata.description();
    final error = event.error?.description();
    log("onExit metadata: $metadata, error: $error");
  }

  double _calculateSecondTotalFee(PaymentCardSuccess state) {
    double totalFee = 0;
    for (final card in state.paymentCards) {
      for (final fee in card.fees) {
        if (fee.type == "PERCENTAGE") {
          totalFee +=
              (fee.amount * (double.tryParse(usdController.text) ?? 0)) / 100;
        } else {
          totalFee += fee.amount;
        }
      }
    }
    return totalFee;
  }

  _calculateFirstTotalFee(CheckDetailsLoaded fee) {
    double totalFee = 0;
    for (final fee in fee.fees) {
      if (fee.type!.contains("PERCENTAGE")) {
        totalFee +=
            (fee.amount! * (double.tryParse(usdController.text) ?? 0)) / 100;
      } else {
        totalFee += fee.amount!;
      }
    }
    return totalFee;
  }

  /// Fetches the user's contacts if permission is granted.
  ///
  /// If the user has not been asked for contact permission before,
  /// it requests permission and fetches contacts if granted.
  /// If permission has been asked before and denied, it sets [isPermissionDenied] to true.
  /// If permission has been granted, it fetches contacts and updates the [contacts] list.
  Future<void> _fetchContacts() async {
    // if (await isPermissionAsked() == false) {
    // Permission has not been asked before
    if (await FlutterContacts.requestPermission(readonly: true)) {
      setState(() {
        isPermissionDenied = false;
      });
    } else {
      // Permission has been asked before
      // Permission was denied
      setState(() {
        isPermissionDenied = true;
      });
      checkContactPermission();
    }
  }

  /// Checks the status of the contact permission and handles different scenarios.
  ///
  /// If permission is denied and it's the first time asking, navigates to a permission request screen.
  /// If permission is denied and it's not the first time asking, sets [isPermissionDenied] to true.
  /// If permission is permanently denied, sets [isPermissionDenied] to true and logs a message.
  void checkContactPermission() async {
    // Check if the contact permission is already granted
    PermissionStatus status = await Permission.contacts.status;

    if (status.isDenied) {
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

  @override
  void initState() {
    if (kIsWeb) {
      isPermissionDenied = true;
    }
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
    context.read<FeeBloc>().add(FetchRemittanceExchangeRate());
    context.read<PaymentCardBloc>().add(FetchPaymentCards());
    context.read<BanksBloc>().add(FetchBanks());
    context.read<CheckDetailsBloc>().add(
          FetchTransferFeeFromCurrencies(
            toCurrency: toCurrency,
            fromCurrency: fromCurrency,
          ),
        );

    super.initState();
  }

  void clearSendInfo() {
    setState(() {
      index = 0;
      selectedBanks = '';
      sliderWidth = 0;
      selectedPaymentMethodIndex = 1;
      whoPayFee = 'SENDER';
      selectedBank = '';
      searchContactController.text = '';
      receiverName.text = '';
      usdController.text = '';
      etbController.text = '';
      bankAcocuntController.text = '';
      receiverInfo = null;
      exchangeRate = 101.98;
    });
  }

  scrollDown() {
    Future.delayed(const Duration(milliseconds: 300)).then((v) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  num _getExchangeRate(String fromCurrency, String toCurrency) {
    final state = context.read<FeeBloc>().state;
    if (state is RemittanceExchangeRateSuccess) {
      final exchangeRate = state.walletCurrencies
          .where((c) =>
              c.fromCurrency.code == fromCurrency &&
              c.toCurrency.code == toCurrency)
          .toList();
      log('Exchange Rate: $exchangeRate');
      if (exchangeRate.isNotEmpty) {
        return exchangeRate.first.rate;
      }
    }

    return 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leadingWidth: index == 0 ? 200 : null,
        centerTitle: true,
        toolbarHeight: 60,
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
                padding: EdgeInsets.only(left: 15, top: 15),
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
      body: Stack(
        children: [
          _buildExchangeRate(),
          _buildRecipientSelection(),
          _builPaymentMethodSelection(),
        ],
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
                context.read<FeeBloc>().add(FetchRemittanceExchangeRate());
                context.read<PaymentCardBloc>().add(FetchPaymentCards());
                context.read<CheckDetailsBloc>().add(
                      FetchTransferFeeFromCurrencies(
                        toCurrency: toCurrency,
                        fromCurrency: fromCurrency,
                      ),
                    );
                await Future.delayed(Durations.extralong1);
              },
              child: SingleChildScrollView(
                child: Form(
                  key: _exchangeRateFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        child: SizedBox(
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
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
                                                          weight:
                                                              FontWeight.w500,
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
                                                  decoration:
                                                      const BoxDecoration(
                                                    color:
                                                        ColorName.primaryColor,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: SvgPicture.asset(
                                                    Assets.images.svgs
                                                        .exchangeIcon,
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
                                                          weight:
                                                              FontWeight.w500,
                                                          color: ColorName
                                                              .primaryColor,
                                                        ),
                                                        BlocConsumer<
                                                            CurrencyBloc,
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
                                                                    .only(
                                                                        top: 3),
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
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 15),
                        child: CardWidget(
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
                                    BlocBuilder<CheckDetailsBloc,
                                        CheckDetailsState>(
                                      builder: (context, state) {
                                        if (state is CheckDetailsLoading) {
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
                                        if (state is CheckDetailsLoaded) {
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
                                                                  text:
                                                                      fee.label ??
                                                                          '',
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
                                                                        '${fee.amount == fee.amount?.toInt() ? fee.amount?.toInt() : fee.amount}%',
                                                                    color: Colors
                                                                        .black87,
                                                                    fontSize:
                                                                        14,
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
                                                                  alignment:
                                                                      Alignment
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
                                                                        : (fee.label == 'Service Fee' &&
                                                                                whoPayFee == 'RECEIVER')
                                                                            ? '\$0'
                                                                            : '\$${((double.tryParse(usdController.text) ?? 0) * ((fee.amount ?? 0) / 100)).toStringAsFixed(2)}',
                                                                    fontSize:
                                                                        14,
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
                                                                  onPressed:
                                                                      () {
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
                                                                  onPressed:
                                                                      () {
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
                                          BlocBuilder<CheckDetailsBloc,
                                              CheckDetailsState>(
                                            builder: (context, state) {
                                              return Row(
                                                children: [
                                                  if (state
                                                      is CheckDetailsLoaded)
                                                    TextWidget(
                                                      text:
                                                          '\$${_calculateFirstTotalFee(state).toStringAsFixed(2)}',
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: ButtonWidget(
                child: const TextWidget(
                  text: 'Next',
                  type: TextType.small,
                  color: Colors.white,
                ),
                onPressed: () async {
                  if (_exchangeRateFormKey.currentState!.validate()) {
                    _fetchContacts();
                    setState(() {
                      index = 1;
                    });
                  }
                }),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  _buildRecipientSelection() {
    return Visibility(
      visible: index == 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
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
                    child: TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Receiver not selected';
                        }
                        return null;
                      },
                      onTapOutside: (event) {
                        if (Platform.isIOS) {
                          Focus.of(context).unfocus();
                        }
                      },
                      onTap: () async {
                        final selectedContact =
                            await showMoneyReceiverSelection(context);

                        setState(() {
                          searchContactController.text =
                              selectedContact?.contactName ?? '';
                          selectedPhoneNumber = selectedContact
                              ?.contactPhoneNumber
                              ?.replaceAll(" ", "");
                        });
                        _recipientSelectionFormKey.currentState!.validate();
                      },
                      readOnly: true,
                      controller: searchContactController,
                      decoration: InputDecoration(
                        suffixIcon: searchContactController.text.isNotEmpty
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
                                    selectedPhoneNumber = null;
                                  });
                                  _recipientSelectionFormKey.currentState!
                                      .validate();
                                },
                              )
                            : null,
                        prefixIcon: const Icon(BoxIcons.bx_search),
                        focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black45),
                            borderRadius: BorderRadius.circular(40)),
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black45),
                            borderRadius: BorderRadius.circular(40)),
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
                                        width: 24,
                                        height: 24,
                                        imageUrl: bank.bankLogo ?? '',
                                        errorWidget: (context, x, y) =>
                                            const SizedBox(
                                          width: 24,
                                          height: 24,
                                        ),
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
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedBank = value;
                            });
                          }
                          _recipientSelectionFormKey.currentState!.validate();
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
                    onTapOutside: (event) {
                      if (Platform.isIOS) {
                        Focus.of(context).unfocus();
                      }
                    },
                    onChanged: (value) {
                      _recipientSelectionFormKey.currentState!.validate();
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
                    ],
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
                    onTapOutside: (event) {
                      if (Platform.isIOS) {
                        Focus.of(context).unfocus();
                      }
                    },
                    onChanged: (value) {
                      _recipientSelectionFormKey.currentState!.validate();
                    },
                    keyboardType: TextInputType.phone,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
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
                          context.read<BankFeeBloc>().add(FetchBankFee());
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

  _buidPaymentMethods() {
    return BlocBuilder<PaymentCardBloc, PaymentCardState>(
      builder: (context, state) {
        if (state is PaymentCardLoading) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
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
            ),
          );
        }
        return Visibility(
          visible: paymentCards.isNotEmpty,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextWidget(
                  text: 'Payment Methods',
                  weight: FontWeight.w700,
                  type: TextType.small,
                ),
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
  }

  _buildPaymentMethodTile({
    required int id,
    required String iconPath,
    required String title,
    required String subTitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
      child: CardWidget(
          boxBorder: Border.all(
            color: selectedPaymentMethodIndex == id
                ? ColorName.primaryColor
                : Colors.transparent,
          ),
          width: 100.sw,
          borderRadius: BorderRadius.circular(14),
          child: ListTile(
            splashColor: Colors.white,
            onTap: () {
              if (selectedPaymentMethodIndex == id) {
                setState(() {
                  selectedPaymentMethodIndex = -1;
                  isScrolledDown = false;
                });
              } else {
                setState(() {
                  selectedPaymentMethodIndex = id;
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
              value: selectedPaymentMethodIndex == id,
              onChanged: (value) {
                if (selectedPaymentMethodIndex == id) {
                  setState(() {
                    selectedPaymentMethodIndex = -1;
                  });
                } else {
                  setState(() {
                    selectedPaymentMethodIndex = id;
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
    );
  }

  _builPaymentMethodSelection() {
    return BlocListener<PaymentCardBloc, PaymentCardState>(
      listener: (context, state) {
        if (state is PaymentCardSuccess) {
          setState(() {
            paymentCards = state.paymentCards;
          });
        } else if (state is PaymentCardFail) {
          showSnackbar(
            context,
            description: state.reason,
          );
        }
      },
      child: Visibility(
        visible: index == 2,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buidPaymentMethods(),
                    _buildAddPaymentMethods(),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: CardWidget(
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
                                                    visible: fee.type ==
                                                        'PERCENTAGE',
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
                                                        '\$${_calculateSecondTotalFee(state).toStringAsFixed(2)}',
                                                    fontSize: 16,
                                                    weight: FontWeight.w700,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Icon(
                                                    Icons.info_outline,
                                                    color: ColorName.grey
                                                        .withOpacity(0.5),
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
                                                        '\$${NumberFormat('##,###.##').format(_calculateSecondTotalFee(state))}',
                                                    fontSize: 16,
                                                    weight: FontWeight.w700,
                                                  ),
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  Icon(
                                                    Icons.info_outline,
                                                    color: ColorName.grey
                                                        .withOpacity(0.5),
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            BlocConsumer<MoneyTransferBloc, MoneyTransferState>(
              listener: (context, state) async {
                if (state is MoneyTransferFail) {
                  showSnackbar(
                    context,
                    title: 'Error',
                    description: state.reason,
                  );
                } else if (state is MoneyTransferSuccess) {
                  String? lastDigit;
                  final cardState = context.read<PaymentCardBloc>().state;
                  if (cardState is PaymentCardSuccess) {
                    final card =
                        cardState.paymentCards[selectedPaymentMethodIndex];

                    lastDigit = card.last4Digits;
                  }
                  context.read<WalletBloc>().add(FetchWallets());
                  context
                      .read<WalletTransactionBloc>()
                      .add(FetchWalletTransaction());
                  // context.pushNamed(
                  //   RouteName.receipt,
                  //   extra: receiverInfo?.copyWith(
                  //     lastDigit: lastDigit,
                  //   ),
                  // );
                  showWalletReceipt(
                      context,
                      state.walletTransactionModel!
                          .copyWith(bankLastDigits: lastDigit));

                  clearSendInfo();
                }
              },
              builder: (context, state) {
                return BlocBuilder<PlaidBloc, PlaidState>(
                  builder: (context, plaidState) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      child: ButtonWidget(
                        child: state is MoneyTransferLoading
                            ? const LoadingWidget()
                            : TextWidget(
                                text:
                                    isScrolledDown ? 'Confirm Payment' : 'Next',
                                type: TextType.small,
                                color: Colors.white,
                              ),
                        onPressed: () async {
                          if (selectedPaymentMethodIndex != -1) {
                            if (isScrolledDown) {
                              final cards = context
                                  .read<PaymentCardBloc>()
                                  .state
                                  .paymentCards;
                              setState(() {
                                selectedPaymentCardId =
                                    cards[selectedPaymentMethodIndex].id;
                              });

                              receiverInfo = ReceiverInfo(
                                receiverName: receiverName.text,
                                receiverPhoneNumber: isPermissionDenied
                                    ? phoneNumberController.text.trim()
                                    : selectedPhoneNumber?.trim() ?? '',
                                receiverBankName: selectedBank,
                                receiverAccountNumber:
                                    bankAcocuntController.text,
                                paymentType: 'SAVED_PAYMENT',
                                amount: double.parse(usdController.text),
                                serviceChargePayer: whoPayFee,
                                publicToken: publicToken,
                              );
                              //                 final paymentIntent =
                              // await Stripe.instance.retrievePaymentIntent(clientSecret);
                              context.read<MoneyTransferBloc>().add(SendMoney(
                                    receiverInfo: receiverInfo!,
                                    paymentId: selectedPaymentCardId,
                                    savedPaymentId: selectedPaymentCardId,
                                  ));
                            } else {
                              scrollDown();
                              setState(() {
                                isScrolledDown = true;
                              });
                            }
                          } else {
                            showSnackbar(context,
                                description: 'Select Payment Method');
                          }
                        },
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
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
          Padding(
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
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
          const SizedBox(height: 20),
          Padding(
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
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
          const SizedBox(height: 20),
          Padding(
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
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
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  _buildExchangeInputs() {
    return Stack(
      children: [
        BlocBuilder<FeeBloc, FeeState>(
          builder: (context, state) {
            if (state is RemittanceExchangeRateLoading) {
              return Column(
                children: [
                  CustomShimmer(
                    borderRadius: BorderRadius.circular(20),
                    width: 100.sw,
                    height: 55,
                  ),
                  const SizedBox(height: 14),
                  CustomShimmer(
                    borderRadius: BorderRadius.circular(20),
                    width: 100.sw,
                    height: 55,
                  ),
                ],
              );
            }
            if (state is RemittanceExchangeRateSuccess) {
              return Column(
                children: [
                  TextFormField(
                    controller: usdController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Enter amount';
                      }
                      return null;
                    },
                    onTapOutside: (event) {
                      if (Platform.isIOS) {
                        Focus.of(context).unfocus();
                      }
                    },
                    onChanged: (value) {
                      try {
                        final money = double.parse(value);
                        etbController.text =
                            (money * _getExchangeRate(fromCurrency, toCurrency))
                                .toStringAsFixed(3);
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
                        RegExp(r'^[0-9]*[.,]?[0-9]*$'),
                      ),
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
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
                              value: fromCurrency,
                              elevation: 0,
                              underline: const SizedBox.shrink(),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: [
                                for (var currency in state.walletCurrencies
                                    .map((w) => w.fromCurrency)
                                    .toSet())
                                  DropdownMenuItem(
                                    value: currency.code,
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Image.asset(
                                            'icons/currency/${currency.code.toLowerCase()}.png',
                                            width: 20,
                                            height: 20,
                                            package: 'currency_icons',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        TextWidget(
                                          text: currency.code,
                                          fontSize: 12,
                                        )
                                      ],
                                    ),
                                  ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  fromCurrency = value ?? 'USD';
                                });
                                etbController.clear();
                                etbController.text =
                                    ((double.tryParse(usdController.text) ??
                                                0) *
                                            _getExchangeRate(
                                                fromCurrency, toCurrency))
                                        .toStringAsFixed(3);
                                context.read<CheckDetailsBloc>().add(
                                      FetchTransferFeeFromCurrencies(
                                        toCurrency: toCurrency,
                                        fromCurrency: fromCurrency,
                                      ),
                                    );
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
                    onTapOutside: (event) {
                      if (Platform.isIOS) {
                        Focus.of(context).unfocus();
                      }
                    },
                    onChanged: (value) {
                      try {
                        final money = double.parse(value);
                        usdController.text =
                            (money / _getExchangeRate(fromCurrency, toCurrency))
                                .toStringAsFixed(3);
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
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 0),
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
                              value: toCurrency,
                              elevation: 0,
                              underline: const SizedBox.shrink(),
                              icon: const Icon(Icons.keyboard_arrow_down),
                              items: [
                                for (var currency in state.walletCurrencies
                                    .map((w) => w.toCurrency)
                                    .toSet())
                                  DropdownMenuItem(
                                    value: currency.code,
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Image.asset(
                                            'icons/currency/${currency.code.toLowerCase()}.png',
                                            width: 20,
                                            height: 20,
                                            package: 'currency_icons',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        const SizedBox(width: 5),
                                        TextWidget(
                                          text: currency.code,
                                          fontSize: 12,
                                        )
                                      ],
                                    ),
                                  ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  toCurrency = value ?? 'ETB';
                                });
                                usdController.clear();
                                usdController.text =
                                    ((double.tryParse(etbController.text) ??
                                                0) /
                                            _getExchangeRate(
                                                fromCurrency, toCurrency))
                                        .round()
                                        .toStringAsFixed(1);
                                context.read<CheckDetailsBloc>().add(
                                      FetchTransferFeeFromCurrencies(
                                        toCurrency: toCurrency,
                                        fromCurrency: fromCurrency,
                                      ),
                                    );
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
              );
            }
            return const SizedBox.shrink();
          },
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
}
