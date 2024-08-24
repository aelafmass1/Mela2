import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/money_transfer/money_transfer_bloc.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/receiver_info_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/receipt_page.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../config/routing.dart';

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

  int selectedPaymentMethodIndex = 1;

  String whoPayFee = 'SENDER';
  String selectedBank = '';

  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];

  double dollarToEtb = 111.98;

  final _exchangeRateFormKey = GlobalKey<FormState>();
  final _recipientSelectionFormKey = GlobalKey<FormState>();

  Contact? selectedContact;

  final searchContactController = TextEditingController();
  final receiverName = TextEditingController();
  final usdController = TextEditingController();
  final etbController = TextEditingController();
  final bankAcocuntController = TextEditingController();

  ReceiverInfo? receiverInfo;

  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      List<Contact> c = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        contacts = c;
      });
    }
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
      dollarToEtb = 101.98;
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
        ));
  }

  _buildExchangeRate() {
    return Visibility(
      visible: index == 0,
      child: Column(
        children: [
          Expanded(
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
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: TextWidget(
                                          text: 'Our promotional rate',
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
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
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
                                              padding: const EdgeInsets.all(5),
                                              decoration: const BoxDecoration(
                                                color: ColorName.primaryColor,
                                                shape: BoxShape.circle,
                                              ),
                                              child: SvgPicture.asset(
                                                Assets.images.svgs.exchangeIcon,
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
                                                const Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    TextWidget(
                                                      text: 'ET Birr',
                                                      fontSize: 9,
                                                      weight: FontWeight.w500,
                                                      color: ColorName
                                                          .primaryColor,
                                                    ),
                                                    TextWidget(
                                                      text: '111.98 ETB',
                                                      fontSize: 14,
                                                      color: ColorName
                                                          .primaryColor,
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
                                            activeColor: ColorName.primaryColor,
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
                                            activeColor: ColorName.primaryColor,
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
                                        text: 'Service fee',
                                        color: Color(0xFF7B7B7B),
                                        fontSize: 14,
                                        weight: FontWeight.w400,
                                      ),
                                      Row(
                                        children: [
                                          const TextWidget(
                                            text: '\$12.08',
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
                                SizedBox(
                                  height: 34,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const TextWidget(
                                        text:
                                            'Connected bank account (ACH) fee',
                                        color: Color(0xFF7B7B7B),
                                        fontSize: 13,
                                        weight: FontWeight.w400,
                                      ),
                                      Row(
                                        children: [
                                          const TextWidget(
                                            text: '\$2.97',
                                            fontSize: 13,
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
                                      )
                                    ],
                                  ),
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
                                        text: 'Reason 4 fee',
                                        color: Color(0xFF7B7B7B),
                                        fontSize: 13,
                                        weight: FontWeight.w400,
                                      ),
                                      Row(
                                        children: [
                                          const TextWidget(
                                            text: 'Free',
                                            fontSize: 13,
                                            color: ColorName.green,
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
                                      ),
                                    ],
                                  ),
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
                                      Row(
                                        children: [
                                          const TextWidget(
                                            text: '\$15.97',
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
                  const TextWidget(
                    text: 'To',
                    type: TextType.small,
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
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
                                                    BorderRadius.circular(100),
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  color: ColorName.primaryColor,
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
                                                    BorderRadius.circular(100),
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
                                                    BorderRadius.circular(100),
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  color: ColorName.primaryColor,
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
                                                    BorderRadius.circular(100),
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
                  const SizedBox(height: 30),
                  const TextWidget(
                    text: 'Bank',
                    type: TextType.small,
                  ),
                  const SizedBox(height: 5),
                  DropdownButtonFormField(
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
                      DropdownMenuItem(
                        value: 'CBE',
                        child: Row(
                          children: [
                            Assets.images.cbeLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'CBE',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Abyisinia Bank',
                        child: Row(
                          children: [
                            Assets.images.abysiniaLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Abyisinia Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Ahadu Bank',
                        child: Row(
                          children: [
                            Assets.images.ahaduLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Ahadu Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Abay Bank',
                        child: Row(
                          children: [
                            Assets.images.abayBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Abay Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Amhara Bank',
                        child: Row(
                          children: [
                            Assets.images.amaraBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Amhara Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Bank of Oromia',
                        child: Row(
                          children: [
                            Assets.images.bankOfOromo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Bank of Oromia',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Awash Bank',
                        child: Row(
                          children: [
                            Assets.images.awashBank.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Awash Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Birhan Bank',
                        child: Row(
                          children: [
                            Assets.images.birhanBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Birhan Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Buna Bank',
                        child: Row(
                          children: [
                            Assets.images.bunaBank.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Buna Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Dashen Bank',
                        child: Row(
                          children: [
                            Assets.images.dashnBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Dashen Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Gedda Bank',
                        child: Row(
                          children: [
                            Assets.images.gedaBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Gedda Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Enat Bank',
                        child: Row(
                          children: [
                            Assets.images.enatBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Enat Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Global Bank',
                        child: Row(
                          children: [
                            Assets.images.globalBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Global Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Hibret Bank',
                        child: Row(
                          children: [
                            Assets.images.hibretBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Hibret Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Hijra Bank',
                        child: Row(
                          children: [
                            Assets.images.hijraBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Hijra Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Nib Bank',
                        child: Row(
                          children: [
                            Assets.images.nibBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Nib Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Oromia Bank',
                        child: Row(
                          children: [
                            Assets.images.oromiaBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Oromia Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Sinqe Bank',
                        child: Row(
                          children: [
                            Assets.images.sinqeBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Sinqe Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Tsedey Bank',
                        child: Row(
                          children: [
                            Assets.images.tsedeyBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Tsedey Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Tsehay Bank',
                        child: Row(
                          children: [
                            Assets.images.tsehayBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Tsehay Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Wegagen Bank',
                        child: Row(
                          children: [
                            Assets.images.wegagenBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Wegagen Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Zemen Bank',
                        child: Row(
                          children: [
                            Assets.images.zemenBankLogo.image(
                              width: 24,
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'Zemen Bank',
                              type: TextType.small,
                            ),
                          ],
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedBank = value;
                        });
                      }
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
                    CardWidget(
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
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: const Center(
                                    child: TextWidget(
                                      text: 'B',
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
                                  value: selectedPaymentMethodIndex == 0,
                                  onChanged: (value) {
                                    //
                                  },
                                ),
                                title: const TextWidget(
                                  text: 'Bank Account',
                                  fontSize: 15,
                                ),
                                subtitle: const TextWidget(
                                  text: 'Free service charge ',
                                  fontSize: 11,
                                  weight: FontWeight.w400,
                                ),
                              )),
                          _buildPaymentMethodTile(
                            id: 1,
                            iconPath: Assets.images.masteredCard.path,
                            title: 'Credit Card',
                            subTitle: 'Mastercard ending   ** 1100',
                          ),
                          _buildPaymentMethodTile(
                            id: 2,
                            iconPath: Assets.images.masteredCard.path,
                            title: 'Debit Card',
                            subTitle: 'Mastercard ending   ** 1100',
                          ),
                          _buildPaymentMethodTile(
                            id: 3,
                            iconPath: Assets.images.visaCard.path,
                            title: 'Credit Card',
                            subTitle: 'Visacard ending   ** 1100',
                          ),
                        ],
                      ),
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
                        child: Column(
                          children: [
                            SizedBox(
                              height: 34,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextWidget(
                                        text: 'Bank fee',
                                        color: Color(0xFF7B7B7B),
                                        fontSize: 14,
                                        weight: FontWeight.w400,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: ColorName.yellow,
                                            size: 12,
                                          ),
                                          SizedBox(width: 3),
                                          TextWidget(
                                            text: 'Included by the bank',
                                            fontSize: 9,
                                            weight: FontWeight.w400,
                                            color: ColorName.yellow,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      const TextWidget(
                                        text: '\$82.8',
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
                                  Row(
                                    children: [
                                      const TextWidget(
                                        text: '\$15.97',
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
                                  )
                                ],
                              ),
                            ),
                          ],
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
                  context.pushNamed(
                    RouteName.receipt,
                    extra: receiverInfo,
                  );
                  // await showDialog(
                  //   context: context,
                  //   builder: (_) => ReceiptPage(
                  //     receiverInfo: receiverInfo!,
                  //   ),
                  // );
                  clearSendInfo();
                }
              },
              builder: (context, state) {
                return ButtonWidget(
                    child: state is MoneyTransferLoading
                        ? const LoadingWidget()
                        : const TextWidget(
                            text: 'Next',
                            type: TextType.small,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      final auth = FirebaseAuth.instance;
                      if (auth.currentUser != null) {
                        receiverInfo = ReceiverInfo(
                          senderUserId: auth.currentUser!.uid,
                          receiverName: receiverName.text,
                          receiverPhoneNumber:
                              selectedContact!.phones.first.number,
                          receiverBankName: selectedBank,
                          receiverAccountNumber: bankAcocuntController.text,
                          amount: double.parse(usdController.text),
                          serviceChargePayer: whoPayFee,
                        );
                        context.read<MoneyTransferBloc>().add(
                              SendMoney(
                                receiverInfo: receiverInfo!,
                              ),
                            );
                      }
                    });
              },
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
                  etbController.text = (money * dollarToEtb).toStringAsFixed(3);
                } catch (error) {
                  etbController.text = '';
                }
              },
              style: const TextStyle(
                fontSize: 22,
              ),
              keyboardType: TextInputType.number,
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
                  usdController.text = (money / dollarToEtb).toStringAsFixed(3);
                } catch (error) {
                  usdController.text = '';
                }
              },
              style: const TextStyle(
                fontSize: 22,
              ),
              keyboardType: TextInputType.number,
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
                //
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
