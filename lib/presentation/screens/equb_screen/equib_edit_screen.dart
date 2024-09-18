import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/equb/equb_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class EqubEditScreen extends StatefulWidget {
  const EqubEditScreen({super.key});

  @override
  State<EqubEditScreen> createState() => _EqubEditScreenState();
}

class _EqubEditScreenState extends State<EqubEditScreen> {
  String? selectedFrequency;
  String? selectedCurrency;

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
                            onPressed: () {
                              // setState(() {
                              //   index = 1;
                              //   sliderWidth = 60.sw;
                              // });
                            })
                      ],
                    ),
                    const SizedBox(height: 15),
                    for (var contact in [1, 2, 3, 4, 5, 6, 7, 8, 9])
                      CheckboxListTile(
                        activeColor: ColorName.primaryColor,
                        checkboxShape: const CircleBorder(),
                        contentPadding: EdgeInsets.zero,
                        value: true,
                        secondary: true
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  color: ColorName.primaryColor,
                                  alignment: Alignment.center,
                                  child: const TextWidget(
                                    text: "",
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.memory(
                                  Uint8List(0),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )),
                        title: const TextWidget(
                          text: "Name",
                          fontSize: 16,
                          weight: FontWeight.w400,
                        ),
                        subtitle: const TextWidget(
                          text: "+251912345678",
                          type: TextType.small,
                          fontSize: 14,
                          weight: FontWeight.w300,
                        ),
                        onChanged: (bool? selected) {
                          // setState(() {
                          //   if (selected == true) {
                          //     selectedContacts.add(contact);
                          //   } else {
                          //     selectedContacts.remove(contact);
                          //   }
                          // });
                          setState(() {});
                        },
                      ),
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
          padding: EdgeInsets.only(top: 5),
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
          controller: TextEditingController(),
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
          controller: TextEditingController(),
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
                  // if (value != null) {
                  //   setState(() {
                  //     selectedCurrency = value;
                  //   });
                  // }
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
          controller: TextEditingController(),
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
          controller: TextEditingController(),
          hintText: 'Select the Starting date for the Equb.',
          suffix: const Icon(
            Icons.date_range,
            color: Color(0xFF646464),
          ),
          onTab: () async {
            // startingDate = await showDatePicker(
            //   context: context,
            //   firstDate: DateTime.now(),
            //   lastDate: DateTime(3000),
            // );
            // if (startingDate != null) {
            //   setState(() {
            //     dateController.text = '${startingDate!.day}-${startingDate!.month}-${startingDate!.year}';
            //   });
            // }
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
    String? Function(String? text)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: TextFormField(
        validator: validator,
        onTap: onTab,
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
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
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
              hintStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              )),

          // width: isReviewPage ? 80.sw : 90.sw,
          onChanged: (value) {
            // setState(() {
            //   selectedFrequency = value;
            // });
          },
          items: const [
            DropdownMenuItem(
              value: 'DAILY',
              child: TextWidget(
                text: 'Daily',
                type: TextType.small,
              ),
            ),
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
