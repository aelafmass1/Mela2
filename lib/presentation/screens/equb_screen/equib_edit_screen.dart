import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/equb/equb_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/equb_detail_model.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/equb_member_tile.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../core/utils/get_member_contact_info.dart';
import '../../../core/utils/show_add_member.dart';
import '../../../core/utils/show_cupertino_date_picker.dart';
import '../../../data/models/invitee_model.dart';

class EqubEditScreen extends StatefulWidget {
  final EqubDetailModel equb;
  const EqubEditScreen({super.key, required this.equb});

  @override
  State<EqubEditScreen> createState() => _EqubEditScreenState();
}

class _EqubEditScreenState extends State<EqubEditScreen> {
  String? selectedFrequency;
  String? selectedCurrencyCode;
  Currency? selectedCurrency;

  final equbNameController = TextEditingController();
  final amountController = TextEditingController();
  final numberOfMembersController = TextEditingController();
  final stringDateController = TextEditingController();
  final frequencyController = TextEditingController();

  List<Contact> _contacts = [];

  DateTime? startingDate;

  Future<void> _fetchContacts() async {
    if (kIsWeb) return;
    if (await FlutterContacts.requestPermission(readonly: true)) {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
      });
    } else {
      // ignore: use_build_context_synchronously
      context.pushNamed(RouteName.contactPermission, extra: () {});
    }
  }

  @override
  void initState() {
    equbNameController.text = widget.equb.name;
    amountController.text = widget.equb.contributionAmount.toString();
    numberOfMembersController.text = widget.equb.numberOfMembers.toString();
    stringDateController.text =
        '${widget.equb.startDate.day}-${widget.equb.startDate.month}-${widget.equb.startDate.year}';
    selectedFrequency = widget.equb.frequency;
    startingDate = widget.equb.startDate;
    setState(() {
      selectedCurrencyCode = widget.equb.currency;
    });
    _fetchContacts();
    super.initState();
  }

  @override
  void dispose() {
    equbNameController.dispose();
    amountController.dispose();
    numberOfMembersController.dispose();
    stringDateController.dispose();
    frequencyController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: ColorName.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(
                      height: 10,
                    ),
                    _buildEqubTextFeilds(isReviewPage: true),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TextWidget(
                          text: 'Members',
                          fontSize: 16,
                        ),
                        TextButton(
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.add,
                                  color: ColorName.primaryColor,
                                ),
                                SizedBox(width: 3),
                                TextWidget(
                                  text: 'Add Member',
                                  fontSize: 13,
                                  color: ColorName.primaryColor,
                                ),
                              ],
                            ),
                            onPressed: () async {
                              await _fetchContacts();

                              showAddMember(
                                // ignore: use_build_context_synchronously
                                context,
                                int.tryParse(numberOfMembersController.text) ??
                                    3,
                                _contacts,
                                widget.equb.id,
                              );
                            }),
                      ],
                    ),
                    const SizedBox(height: 15),
                    for (var member in widget.equb.members)
                      FutureBuilder(
                          future: getMemberContactInfo(
                            equbUser: member.user!,
                            contacts: _contacts,
                          ),
                          builder: (context, snapshot) {
                            return EqubMemberTile(
                              equbInviteeModel: EqubInviteeModel(
                                  id: member.userId ?? 0,
                                  phoneNumber: snapshot.data?.phoneNumber ??
                                      member.username ??
                                      '',
                                  status: member.status,
                                  name: snapshot.data?.displayName ??
                                      member.username ??
                                      ''),
                            );
                          })
                  ],
                ),
              ),
              const SizedBox(height: 10),
              BlocConsumer<EqubBloc, EqubState>(
                listener: (context, state) {
                  if (state is EqubFail) {
                    showSnackbar(
                      context,
                      title: 'Error',
                      description: state.reason,
                    );
                  } else if (state is EqubSuccess) {
                    context.pushNamed(
                      RouteName.completePage,
                      extra: "Name",
                    );
                  }
                },
                builder: (context, state) {
                  return ButtonWidget(
                      child: state is EqubLoading
                          ? const LoadingWidget()
                          : const TextWidget(
                              text: 'Confirm',
                              color: Colors.white,
                              type: TextType.small,
                            ),
                      onPressed: () {
                        // if (_formKey.currentState!.validate()) {
                        //   context.read<EqubBloc>().add(
                        //         AddEqub(
                        //           equbModel: EqubModel(
                        //             name: nameController.text,
                        //             contributionAmount: double.parse(amountController.text),
                        //             frequency: selectedFrequency!,
                        //             numberOfMembers: int.parse(numberOfMembersController.text),
                        //             startDate: startingDate!,
                        //             members: selectedContacts
                        //                 .map((c) => ContactModel(
                        //                       name: c.displayName,
                        //                       phoneNumber: c.phones.first.number,
                        //                     ))
                        //                 .toList(),
                        //           ),
                        //         ),
                        //       );
                        // }
                      });
                },
              ),
              const SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextWidget(
          text: "Review Your Equb",
          fontSize: 24,
          weight: FontWeight.w700,
        ),
        Padding(
          padding: EdgeInsets.only(top: 5, bottom: 15),
          child: TextWidget(
            text: "Please review your Equb details carefully.",
            weight: FontWeight.w400,
            fontSize: 14,
            color: Color(0xFF6D6D6D),
          ),
        )
      ],
    );
  }

  _buildEqubTextFeilds({bool isReviewPage = false}) {
    return Column(
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
          controller: equbNameController,
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
            height: 55,
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
            child: InkWell(
                onTap: () {
                  showCurrencyPicker(
                      context: context,
                      showFlag: true,
                      showCurrencyName: true,
                      showCurrencyCode: true,
                      theme: CurrencyPickerThemeData(
                          backgroundColor: Colors.white,
                          inputDecoration: InputDecoration(
                            prefixIcon: const Icon(
                              Bootstrap.search,
                              size: 20,
                            ),
                            hintText: 'Search Currency',
                            hintStyle: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF8E8E8E),
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(40),
                                borderSide: const BorderSide(
                                  color: ColorName.primaryColor,
                                  width: 2,
                                )),
                          )),
                      onSelect: (Currency currency) {
                        setState(() {
                          selectedCurrencyCode = currency.code;
                          selectedCurrency = currency;
                        });
                      });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      text:
                          '${selectedCurrency == null ? '' : CurrencyUtils.currencyToEmoji(selectedCurrency!)} $selectedCurrencyCode',
                      type: TextType.small,
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_outlined,
                    ),
                  ],
                )),
          ),
        ),
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
          readOnly: true,
          controller: stringDateController,
          hintText: 'Select the Starting date for the Equb.',
          suffix: const Icon(
            Icons.date_range,
            color: Color(0xFF646464),
          ),
          onTab: () async {
            startingDate = await showCupertinoDatePicker(context);

            if (startingDate != null) {
              setState(() {
                stringDateController.text =
                    '${startingDate?.day}-${startingDate?.month}-${startingDate?.year}';
              });
            }
          },
        ),
      ],
    );
  }

  _buildTextFeild({
    required String hintText,
    required TextEditingController controller,
    Function()? onTab,
    Widget? suffix,
    bool? enabled,
    bool showOnlyNumber = false,
    bool readOnly = false,
    String? Function(String? text)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: TextFormField(
        validator: validator,
        onTap: onTab,
        readOnly: readOnly,
        controller: controller,
        keyboardType: showOnlyNumber ? TextInputType.phone : null,
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
              const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
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

  _buildDropdownMenu(bool isReviewPage) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: SizedBox(
        width: 100.sh,
        child: DropdownButtonFormField(
          isDense: true,
          isExpanded: false,
          validator: (value) {
            if (value?.isEmpty ?? true) {
              return 'frequency not selected';
            }
            return null;
          },
          hint: const TextWidget(
            text: 'Select Fequency of the equb contribution',
            fontSize: 12,
            weight: FontWeight.w400,
          ),
          value: selectedFrequency,
          icon: const Icon(Icons.keyboard_arrow_down_outlined),
          decoration: InputDecoration(
              // suffixIcon: const Icon(Icons.keyboard_arrow_down_outlined),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
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
            // DropdownMenuItem(
            //   value: 'DAILY',
            //   child: TextWidget(
            //     text: 'Daily',
            //     type: TextType.small,
            //   ),
            // ),
            DropdownMenuItem(
              value: 'WEEKLY',
              child: TextWidget(
                text: 'Weekly',
                type: TextType.small,
              ),
            ),
            DropdownMenuItem(
              value: 'BIWEEKLY',
              child: TextWidget(
                text: 'Bi Weekly',
                type: TextType.small,
              ),
            ),
            DropdownMenuItem(
              value: 'MONTHLY',
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
}
