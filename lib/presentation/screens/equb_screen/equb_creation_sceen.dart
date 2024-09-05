import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/equb/equb_bloc.dart';
import 'package:transaction_mobile_app/data/models/equb_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/components/complete_page.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class EqubCreationScreen extends StatefulWidget {
  const EqubCreationScreen({super.key});

  @override
  State<EqubCreationScreen> createState() => _EqubCreationScreenState();
}

class _EqubCreationScreenState extends State<EqubCreationScreen> {
  double sliderWidth = 30.sw;
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final numberOfMembersController = TextEditingController();
  final dateController = TextEditingController();
  final searchingController = TextEditingController();
  String selectedCurrency = 'usd';
  String? selectedFrequency;
  int index = 0;

  final _formKey = GlobalKey<FormState>();

  List<Contact> _contacts = [];
  List<Contact> selectedContacts = [];
  List<Contact> filteredContacts = [];

  DateTime? startingDate;

  bool isSearching = false;
  bool agreeToTermAndCondition = false;

  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: ColorName.backgroundColor,
        elevation: 0,
        backgroundColor: ColorName.backgroundColor,
        leading: IconButton(
          onPressed: () {
            if (index == 0) {
              context.pop();
            } else if (index == 1) {
              setState(() {
                index = 0;
                sliderWidth = 30.sw;
              });
            } else if (index == 2) {
              setState(() {
                index = 1;
                sliderWidth = 60.sw;
              });
            } else if (index == 3) {
              setState(() {
                index = 2;
                sliderWidth = 100.sw;
              });
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: index == 0
                  ? 'Creating Equb'
                  : index == 1
                      ? 'Add Members'
                      : index == 2
                          ? 'Consent'
                          : 'Review your Equb',
              fontSize: 24,
              weight: FontWeight.w700,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: TextWidget(
                text: index == 0
                    ? 'Please fill the below form correctly.'
                    : index == 1
                        ? 'Share this Equb or Invite friend or family.'
                        : index == 2
                            ? 'Read the terms and conditions carefully.'
                            : 'Please review your Equb details carefully.',
                weight: FontWeight.w400,
                fontSize: 14,
                color: const Color(0xFF6D6D6D),
              ),
            ),
            Visibility(
              visible: index != 3,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextWidget(
                      text: '${index + 1}',
                      type: TextType.small,
                      color: ColorName.primaryColor,
                    ),
                    const TextWidget(
                      text: '/3',
                      type: TextType.small,
                    ),
                  ],
                ),
              ),
            ),
            Visibility(
              visible: index != 3,
              child: Stack(
                children: [
                  Container(
                    width: 100.sw,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6E6E6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    width: sliderWidth,
                    height: 10,
                    decoration: BoxDecoration(
                      color: ColorName.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: Stack(
                children: [
                  _buildEqubForm(),
                  _buildAddMember(),
                  _buildTermAndCondition(),
                  _buildReview(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Visibility(
                visible: index != 3,
                child: ButtonWidget(
                    onPressed: (index == 1 && selectedContacts.isEmpty) ||
                            (index == 2 && agreeToTermAndCondition == false)
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              if (index == 0) {
                                _fetchContacts();
                                setState(() {
                                  index = 1;
                                  sliderWidth = 60.sw;
                                });
                              } else if (index == 1) {
                                setState(() {
                                  index = 2;
                                  sliderWidth = 100.sw;
                                });
                              } else if (index == 2) {
                                setState(() {
                                  index = 3;
                                });
                              }
                            }
                          },
                    child: const TextWidget(
                      text: 'Next',
                      type: TextType.small,
                      color: Colors.white,
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }

  _buildDropdownMenu(bool isReviewPage) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: SizedBox(
        width: 100.sh,
        child: DropdownButtonFormField(
          validator: (value) {
            if (value!.isEmpty) {
              return 'frequency not selected';
            }
            return null;
          },
          hint: const TextWidget(
            text: 'Select Fequency of the equb contribution',
            type: TextType.small,
          ),
          value: selectedFrequency,
          decoration: InputDecoration(
              suffixIcon: const Icon(Icons.keyboard_arrow_down_outlined),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              hintStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              )),

          // width: isReviewPage ? 80.sw : 90.sw,
          onChanged: (value) {
            setState(() {
              selectedFrequency = value;
            });
          },
          items: const [
            DropdownMenuItem(
              value: 'daily',
              child: TextWidget(
                text: 'Daily',
                type: TextType.small,
              ),
            ),
            DropdownMenuItem(
              value: 'weekly',
              child: TextWidget(
                text: 'Weekly',
                type: TextType.small,
              ),
            ),
            DropdownMenuItem(
              value: 'bi-weekly',
              child: TextWidget(
                text: 'Bi Weekly',
                type: TextType.small,
              ),
            ),
            DropdownMenuItem(
              value: 'monthly',
              child: TextWidget(
                text: 'Monthly',
                type: TextType.small,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildTextFeild({
    required String hintText,
    required TextEditingController controller,
    Function()? onTab,
    Widget? suffix,
    bool? enabled,
    bool showOnlyNumber = false,
    String? Function(String? text)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: TextFormField(
        validator: validator,
        onTap: onTab,
        controller: controller,
        inputFormatters: showOnlyNumber
            ? [
                FilteringTextInputFormatter.digitsOnly,
              ]
            : null,
        decoration: InputDecoration(
          hintStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
          enabled: enabled ?? true,
          suffixIcon: suffix,
          hintText: hintText,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
    );
  }

  _buildEqubForm() {
    return Visibility(
      visible: index == 0,
      child: SingleChildScrollView(
        child: _buildEqubTextFeilds(),
      ),
    );
  }

  _buildAddMember() {
    return Visibility(
      visible: index == 1,
      child: SizedBox(
        width: 100.sw,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: 'Add Members',
              fontSize: 14,
              weight: FontWeight.w400,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: searchingController,
              onChanged: (value) {
                if (value.isEmpty) {
                  setState(() {
                    isSearching = false;
                    filteredContacts = [];
                  });
                } else {
                  filteredContacts = _contacts
                      .where((contact) => contact.displayName
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {
                    filteredContacts = filteredContacts;
                    isSearching = true;
                  });
                }
              },
              decoration: InputDecoration(
                hintText: 'Search name',
                hintStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: const Icon(
                  BoxIcons.bx_search,
                ),
                contentPadding: const EdgeInsets.only(left: 20),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextWidget(
              text: 'All Contact (${_contacts.length} Contacts) ',
              fontSize: 14,
              weight: FontWeight.w500,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isSearching
                  ? filteredContacts.isEmpty
                      ? Container(
                          margin: const EdgeInsets.only(top: 10),
                          alignment: Alignment.topCenter,
                          child: TextWidget(
                            text: '${searchingController.text} not Found',
                            type: TextType.small,
                            weight: FontWeight.w300,
                            color: const Color(0xFF6D6D6D),
                          ),
                        )
                      : ListView.builder(
                          itemCount: filteredContacts.length,
                          itemBuilder: (context, index) {
                            final contact = filteredContacts[index];
                            final isSelected =
                                selectedContacts.contains(contact);
                            return CheckboxListTile(
                              activeColor: ColorName.primaryColor,
                              checkboxShape: const CircleBorder(),
                              contentPadding: EdgeInsets.zero,
                              value: isSelected,
                              secondary: contact.photo == null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Container(
                                        width: 50,
                                        height: 50,
                                        color: ColorName.primaryColor,
                                        alignment: Alignment.center,
                                        child: TextWidget(
                                          text: contact.displayName[0],
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: Image.memory(
                                        contact.photo!,
                                        width: 50,
                                        height: 50,
                                        fit: BoxFit.cover,
                                      )),
                              title: TextWidget(
                                text: contact.displayName,
                                fontSize: 16,
                                weight: FontWeight.w400,
                              ),
                              subtitle: TextWidget(
                                text: contact.phones.first.number,
                                type: TextType.small,
                                fontSize: 14,
                                weight: FontWeight.w300,
                              ),
                              onChanged: (bool? selected) {
                                setState(() {
                                  if (selected == true) {
                                    selectedContacts.add(contact);
                                  } else {
                                    selectedContacts.remove(contact);
                                  }
                                });
                                setState(() {
                                  selectedContacts = selectedContacts;
                                });
                              },
                            );
                          })
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        final isSelected = selectedContacts.contains(contact);
                        return CheckboxListTile(
                          activeColor: ColorName.primaryColor,
                          checkboxShape: const CircleBorder(),
                          contentPadding: EdgeInsets.zero,
                          value: isSelected,
                          secondary: contact.photo == null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: ColorName.primaryColor,
                                    alignment: Alignment.center,
                                    child: TextWidget(
                                      text: contact.displayName[0],
                                      color: Colors.white,
                                    ),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child: Image.memory(
                                    contact.photo!,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit.cover,
                                  )),
                          title: TextWidget(
                            text: contact.displayName,
                            fontSize: 16,
                            weight: FontWeight.w400,
                          ),
                          subtitle: TextWidget(
                            text: contact.phones.first.number,
                            type: TextType.small,
                            fontSize: 14,
                            weight: FontWeight.w300,
                          ),
                          onChanged: (bool? selected) {
                            setState(() {
                              if (selected == true) {
                                selectedContacts.add(contact);
                              } else {
                                selectedContacts.remove(contact);
                              }
                            });
                            setState(() {
                              selectedContacts = selectedContacts;
                            });
                            log(selectedContacts.toString());
                          },
                        );
                      }),
            )
          ],
        ),
      ),
    );
  }

  _buildTermAndCondition() {
    return Visibility(
      visible: index == 2,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 100.sw,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(-2, -2),
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextWidget(
                      text: 'Terms and Conditions',
                      fontSize: 16,
                    ),
                    SizedBox(height: 10),
                    TextWidget(
                      text:
                          'Lorem ipsum dolor sit amet consectetur. Nullam imperdiet habitant nunc neque molestie tristique. Sed pulvinar lectus pharetra elit. Commodo lacus ipsum egestas penatibus velit amet. Viverra sit hendrerit tempus maecenas eu fusce turpis quam turpis. Nunc eleifend felis iaculis nibh blandit sit. Convallis interdum et et elit malesuada morbi euismod dolor viverra. Pretium facilisi sed mattis aliquet dapibus porttitor purus maecenas pellentesque. Ultrices id consectetur leo donec fringilla integer in. Lacinia neque quisque sit metus neque proin justo. Id nascetur nisi eget et varius in vivamus dolor. Leo vitae id eu enim sit eget. Sed felis sit nibh rhoncus hendrerit.\n\nLorem ipsum dolor sit amet consectetur. Nullam imperdiet habitant nunc neque molestie tristique. Sed pulvinar lectus pharetra elit. Commodo lacus ipsum egestas penatibus velit amet. Viverra sit hendrerit tempus maecenas eu fusce turpis quam turpis. Nunc eleifend felis iaculis nibh blandit sit. Convallis interdum et et elit malesuada morbi euismod dolor viverra. Pretium facilisi sed mattis aliquet dapibus porttitor purus maecenas pellentesque. Ultrices id consectetur leo donec fringilla integer in.',
                      color: Color(0xFF6D6D6D),
                      fontSize: 14,
                    )
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                  shape: const CircleBorder(),
                  activeColor: ColorName.primaryColor,
                  value: agreeToTermAndCondition,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        agreeToTermAndCondition = value;
                      });
                    }
                  }),
              const TextWidget(
                text: 'Yes, I agree to the terms and Conditions.',
                type: TextType.small,
                fontSize: 14,
              ),
            ],
          ),
          const SizedBox(height: 20)
        ],
      ),
    );
  }

  _buildReview() {
    return Visibility(
      visible: index == 3,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _buildEqubTextFeilds(isReviewPage: true),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextWidget(
                        text: 'Members',
                        fontSize: 16,
                      ),
                      SizedBox(
                        height: 45,
                        width: 100,
                        child: ButtonWidget(
                            topPadding: 0,
                            child: const TextWidget(
                              text: 'Add Member',
                              fontSize: 12,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                index = 1;
                                sliderWidth = 60.sw;
                              });
                            }),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  for (var contact in selectedContacts)
                    CheckboxListTile(
                      activeColor: ColorName.primaryColor,
                      checkboxShape: const CircleBorder(),
                      contentPadding: EdgeInsets.zero,
                      value: true,
                      secondary: contact.photo == null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                width: 50,
                                height: 50,
                                color: ColorName.primaryColor,
                                alignment: Alignment.center,
                                child: TextWidget(
                                  text: contact.displayName[0],
                                  color: Colors.white,
                                ),
                              ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.memory(
                                contact.photo!,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )),
                      title: TextWidget(
                        text: contact.displayName,
                        fontSize: 16,
                        weight: FontWeight.w400,
                      ),
                      subtitle: TextWidget(
                        text: contact.phones.first.number,
                        type: TextType.small,
                        fontSize: 14,
                        weight: FontWeight.w300,
                      ),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            selectedContacts.add(contact);
                          } else {
                            selectedContacts.remove(contact);
                          }
                        });
                        setState(() {
                          selectedContacts = selectedContacts;
                        });
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            ButtonWidget(
                child: const TextWidget(
                  text: 'Confirm',
                  color: Colors.white,
                  type: TextType.small,
                ),
                onPressed: () {
                  context.read<EqubBloc>().add(
                        AddEqub(
                          equbModel: EqubModel(
                            name: nameController.text,
                            amount: double.parse(amountController.text),
                            frequency: selectedFrequency!,
                            numberOfMembers:
                                int.parse(numberOfMembersController.text),
                            startingDate: startingDate!,
                            selectedContacts: selectedContacts,
                          ),
                        ),
                      );
                  showDialog(
                    context: context,
                    builder: (_) => const CompletePage(),
                  );
                })
          ],
        ),
      ),
    );
  }

  _buildEqubTextFeilds({bool isReviewPage = false}) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const TextWidget(
                text: 'Equb Name',
                fontSize: 14,
                weight: FontWeight.w400,
              ),
              const SizedBox(width: 10),
              Visibility(
                visible: isReviewPage,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                ),
              )
            ],
          ),
          _buildTextFeild(
            validator: (text) {
              if (text!.isEmpty) {
                return 'Equb Name is empty';
              }
              return null;
            },
            controller: nameController,
            hintText: 'Enter your Equb Group Name',
          ),
          Row(
            children: [
              const TextWidget(
                text: 'Set Amount',
                fontSize: 14,
                weight: FontWeight.w400,
              ),
              const SizedBox(width: 10),
              Visibility(
                visible: isReviewPage,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                ),
              )
            ],
          ),
          _buildTextFeild(
              validator: (text) {
                if (text!.isEmpty) {
                  return 'amount is empty';
                }
                return null;
              },
              controller: amountController,
              showOnlyNumber: true,
              hintText: 'Enter Equb per-member collections',
              suffix: Container(
                width: 105,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  border: const Border(
                    right: BorderSide(
                      width: 1,
                    ),
                    left: BorderSide(
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: DropdownButton(
                    padding: EdgeInsets.zero,
                    elevation: 0,
                    underline: const SizedBox.shrink(),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_outlined,
                    ),
                    value: selectedCurrency,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCurrency = value;
                        });
                      }
                    },
                    items: [
                      DropdownMenuItem(
                        value: 'etb',
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Assets.images.ethiopianFlag.image(
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'ETB',
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'usd',
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Assets.images.usaFlag.image(
                                width: 20,
                                height: 20,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const TextWidget(
                              text: 'USD',
                              fontSize: 12,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          Row(
            children: [
              const TextWidget(
                text: 'Frequency',
                fontSize: 14,
                weight: FontWeight.w400,
              ),
              const SizedBox(width: 10),
              Visibility(
                visible: isReviewPage,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                ),
              )
            ],
          ),
          _buildDropdownMenu(isReviewPage),
          Row(
            children: [
              const TextWidget(
                text: 'Number of Members',
                fontSize: 14,
                weight: FontWeight.w400,
              ),
              const SizedBox(width: 10),
              Visibility(
                visible: isReviewPage,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                ),
              )
            ],
          ),
          _buildTextFeild(
            validator: (text) {
              if (text!.isEmpty) {
                return 'number of members is empty';
              }
              return null;
            },
            controller: numberOfMembersController,
            hintText: 'Enter the number of members',
            showOnlyNumber: true,
          ),
          Row(
            children: [
              const TextWidget(
                text: 'Starting Date',
                fontSize: 14,
                weight: FontWeight.w400,
              ),
              const SizedBox(width: 10),
              Visibility(
                visible: isReviewPage,
                child: const Icon(
                  Icons.edit_outlined,
                  size: 16,
                ),
              )
            ],
          ),
          _buildTextFeild(
            validator: (text) {
              if (text!.isEmpty) {
                return 'start date is empty';
              }
              return null;
            },
            controller: dateController,
            hintText: 'Select the Starting date for the Equb.',
            suffix: const Icon(
              Icons.date_range,
              color: Color(0xFF646464),
            ),
            onTab: () async {
              startingDate = await showDatePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime(3000),
              );
              if (startingDate != null) {
                setState(() {
                  dateController.text =
                      '${startingDate!.day}-${startingDate!.month}-${startingDate!.year}';
                });
              }
            },
          ),
        ],
      ),
    );
  }
}
