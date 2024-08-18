import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/back_button.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/receit_page.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

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
  String whoPayFee = 'me';
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];

  Contact? selectedContact;
  TextEditingController searchContactController = TextEditingController();

  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      List<Contact> c = await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        contacts = c;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leadingWidth: index == 0 ? 200 : null,
          centerTitle: true,
          toolbarHeight: 50,
          title: index == 1 || index == 2
              ? TextWidget(
                  text: index == 1 ? 'Select Recipient' : 'Payment Method',
                  fontSize: 20,
                  weight: FontWeight.w700,
                )
              : null,
          leading: index == 0
              ? const Padding(
                  padding: EdgeInsets.only(left: 15),
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 100.sw,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFFFA800),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                      ),
                      SizedBox(width: 5),
                      TextWidget(
                        text: '1 USD = 101.98 ETB',
                        fontSize: 14,
                      ),
                    ],
                  ),
                  Container(
                    width: 84,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Assets.images.increaseArrow.image(
                          width: 20,
                          height: 20,
                        ),
                        const SizedBox(width: 5),
                        const TextWidget(
                          text: '+ 2.5%',
                          color: ColorName.green,
                          type: TextType.small,
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 5),
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
                          text: 'Who’s going to pay the service charge?',
                          fontSize: 14,
                        ),
                        Row(
                          children: [
                            Row(
                              children: [
                                Radio(
                                    activeColor: ColorName.primaryColor,
                                    value: 'me',
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
                                    value: 'recipient',
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const TextWidget(
                                text: 'Connected bank account (ACH) fee',
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  const SizedBox(height: 30),
                  ButtonWidget(
                      child: const TextWidget(
                        text: 'Next',
                        type: TextType.small,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _fetchContacts();
                        setState(() {
                          index = 1;
                        });
                      })
                ],
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.all(15),
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
                    TextField(
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
                            borderSide: const BorderSide(color: Colors.black45),
                            borderRadius: BorderRadius.circular(40)),
                        border: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.black45),
                            borderRadius: BorderRadius.circular(40)),
                      ),
                    ),
                    Expanded(
                      child: isSearching
                          ? ListView.builder(
                              itemBuilder: (context, index) {
                                return ListTile(
                                  onTap: () {
                                    searchContactController.text =
                                        filteredContacts[index].displayName;
                                    setState(() {
                                      selectedContact = filteredContacts[index];
                                      contactListHeight = 60;
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
                                    text: filteredContacts[index].displayName,
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
                                      contactListHeight = 60;
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
                                    text: contacts[index].phones.first.number,
                                    fontSize: 13,
                                  ),
                                );
                              },
                              itemCount: contacts.length,
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
              TextField(
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
                  hintText: 'Select Bank',
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
              TextField(
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
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
              ButtonWidget(
                  child: const TextWidget(
                    text: 'Next',
                    type: TextType.small,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      index = 2;
                    });
                  })
            ],
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CardWidget(
              width: 100.sw,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TextWidget(
                    text: 'Select Payment Method',
                    type: TextType.small,
                  ),
                  const SizedBox(height: 15),
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
            const SizedBox(height: 20),
            CardWidget(
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
                child: Column(
                  children: [
                    SizedBox(
                      height: 34,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            ButtonWidget(
                child: const TextWidget(
                  text: 'Next',
                  type: TextType.small,
                  color: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => const Dialog(
                      elevation: 0,
                      shape: BeveledRectangleBorder(),
                      insetPadding: EdgeInsets.zero,
                      child: ReceitPage(),
                    ),
                  );
                })
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
            SizedBox(
              height: 62,
              child: TextField(
                style: const TextStyle(
                  fontSize: 24,
                ),
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
                    height: 62,
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
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black45),
                      borderRadius: BorderRadius.circular(40)),
                  border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black45),
                      borderRadius: BorderRadius.circular(40)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 62,
              child: TextField(
                style: const TextStyle(
                  fontSize: 24,
                ),
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
                    height: 62,
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
                      fontSize: 9,
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
