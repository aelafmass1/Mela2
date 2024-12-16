import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/contact/contact_bloc.dart';
import 'package:transaction_mobile_app/bloc/equb/equb_bloc.dart';
import 'package:transaction_mobile_app/bloc/equb_currencies/equb_currencies_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/core/utils/show_cupertino_date_picker.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/equb_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../data/models/contact_model.dart';

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
  String selectedCurrencyCode = 'USD';
  Currency? selectedCurrency;
  String? selectedFrequency;
  String adminName = '';
  String? selectedCurrencyFlag;
  int index = 0;

  final _formKey = GlobalKey<FormState>();

  List<Contact> _contacts = [];
  List<Contact> selectedContacts = [];
  List<Contact> filteredContacts = [];

  List<String> melaMemberContacts = [];

  DateTime? startingDate;

  bool isSearching = false;
  bool agreeToTermAndCondition = false;
  bool isPermissionDenied = false;
  bool isWebviewLoading = false;

  late WebViewController _controller;

  Future<void> _fetchContacts() async {
    if (kIsWeb) return;
    if (await Permission.contacts.isDenied) {
      await Future.delayed(const Duration(seconds: 10));
    }
    if (await FlutterContacts.requestPermission(readonly: true)) {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        isPermissionDenied = false;
        _contacts = contacts;
      });
      // ignore: use_build_context_synchronously
      context.read<ContactBloc>().add(FetchContacts());
    } else {
      // context.pushNamed(RouteName.contactPermission, extra: () {
      //   setState(() {
      //     index = 0;
      //     sliderWidth = 30.sw;
      //   });
      // });
      setState(() {
        isPermissionDenied = true;
      });
    }
  }

  @override
  void initState() {
    context.read<EqubCurrenciesBloc>().add(FetchEqubCurrencies());
    getDisplayName().then((value) {
      setState(() {
        adminName = value ?? '';
      });
    });
    if (kIsWeb == false) {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..enableZoom(true)
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              if (progress == 100) {
                setState(() {
                  isWebviewLoading = false;
                });
              } else {
                setState(() {
                  isWebviewLoading = true;
                });
              }
            },
            onPageStarted: (String url) {},
            onPageFinished: (String url) {},
            onHttpError: (HttpResponseError error) {},
            onWebResourceError: (WebResourceError error) {},
            onNavigationRequest: (NavigationRequest request) {
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse('https://static.melafinance.com/TOS.html'));
    }

    super.initState();
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocListener<ContactBloc, ContactState>(
                listener: (context, state) {
                  if (state is ContactFilterSuccess) {
                    if (state.remoteContacts.isNotEmpty) {
                      setState(() {
                        melaMemberContacts = state.filteredContacts
                            .map((c) => c.contactId)
                            .toList();
                      });
                    }
                  }
                },
                child: TextWidget(
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
                  child: (index == 1 && isPermissionDenied)
                      ? const SizedBox.shrink()
                      : ButtonWidget(
                          onPressed:
                              (index == 1 && (selectedContacts.isEmpty)) ||
                                      (index == 2 &&
                                          agreeToTermAndCondition == false)
                                  ? null
                                  : () {
                                      if (_formKey.currentState!.validate()) {
                                        if (index == 0) {
                                          setState(() {
                                            index = 1;
                                            sliderWidth = 60.sw;
                                          });
                                          _fetchContacts();
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

  _buildTextFeild({
    required String hintText,
    required TextEditingController controller,
    Function()? onTab,
    Widget? suffix,
    bool? enabled,
    bool showOnlyNumber = false,
    String? Function(String? text)? validator,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      child: TextFormField(
        readOnly: readOnly,
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

  _buildEqubForm() {
    return Visibility(
      visible: index == 0,
      child: BlocBuilder<EqubCurrenciesBloc, EqubCurrenciesState>(
          builder: (context, state) {
        if (state is EqubCurrenciesSuccess) {
          return SingleChildScrollView(
            child: _buildEqubTextFeilds(
              state: state,
            ),
          );
        } else if (state is EqubCurrenciesLoading) {
          return const Center(
            child: LoadingWidget(
              color: ColorName.primaryColor,
            ),
          );
        }
        return const SizedBox.shrink();
      }),
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
              onTap: () {
                if (isPermissionDenied) {
                  _fetchContacts();
                }
              },
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(
                  text: 'All Contact (${_contacts.length} Contacts) ',
                  fontSize: 14,
                  weight: FontWeight.w500,
                ),
                TextWidget(
                  text:
                      '${selectedContacts.length}/${numberOfMembersController.text}',
                  fontSize: 14,
                  weight: FontWeight.w500,
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (isPermissionDenied)
              Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Assets.images.contactPageImage.image(
                      width: 200,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: TextWidget(
                      text: 'Enable Contact Permission',
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 80.sw,
                    child: const TextWidget(
                      text:
                          'This is going to be the settings path on the users device to enable the contact permission for our App.',
                      type: TextType.small,
                      textAlign: TextAlign.center,
                      fontSize: 12,
                      weight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 80.sw,
                    child: const TextWidget(
                      text:
                          'Go to Settings > Apps > Mela Fi > Contact > Select Full Access',
                      type: TextType.small,
                      textAlign: TextAlign.center,
                      fontSize: 12,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: 10,
                    ),
                    child: ButtonWidget(
                        child: const TextWidget(
                          text: 'Enable Permission',
                          type: TextType.small,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          await openAppSettings();
                        }),
                  )
                ],
              )
            else
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
                              textAlign: TextAlign.center,
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
                                contentPadding: EdgeInsets.zero,
                                value: isSelected,
                                secondary: contact.photo == null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
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
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.memory(
                                          contact.photo!,
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )),
                                title: Row(
                                  children: [
                                    TextWidget(
                                      text: contact.displayName,
                                      fontSize: 16,
                                      weight: FontWeight.w400,
                                    ),
                                    const SizedBox(width: 5),
                                    Visibility(
                                      visible: melaMemberContacts
                                          .contains(contact.id),
                                      child: SvgPicture.asset(
                                        Assets.images.svgs.checkmarkIcon,
                                        width: 18,
                                        height: 18,
                                      ),
                                    ),
                                  ],
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
                                      if (selectedContacts.length <
                                          (int.tryParse(
                                                  numberOfMembersController
                                                      .text) ??
                                              0)) {
                                        selectedContacts.add(contact);
                                      }
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
                            title: Row(
                              children: [
                                TextWidget(
                                  text: contact.displayName,
                                  fontSize: 16,
                                  weight: FontWeight.w400,
                                ),
                                const SizedBox(width: 5),
                                Visibility(
                                  visible:
                                      melaMemberContacts.contains(contact.id),
                                  child: SvgPicture.asset(
                                    Assets.images.svgs.checkmarkIcon,
                                    width: 18,
                                    height: 18,
                                  ),
                                ),
                              ],
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
                                  if (selectedContacts.length <
                                      (int.tryParse(
                                              numberOfMembersController.text) ??
                                          0)) {
                                    selectedContacts.add(contact);
                                  }
                                } else {
                                  selectedContacts.remove(contact);
                                }
                              });
                              setState(() {
                                selectedContacts = selectedContacts;
                              });
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
              child: isWebviewLoading
                  ? const Center(
                      child: LoadingWidget(
                        color: ColorName.primaryColor,
                      ),
                    )
                  : const SizedBox(),
              // Visibility(
              //     visible: kIsWeb == false,
              //     child: WebViewWidget(
              //       controller: _controller,
              //     ),
              //   ),
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
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        _buildReviewTop(),
                        // _buildEqubTextFeilds(isReviewPage: true),
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
                                  setState(() {
                                    index = 1;
                                    sliderWidth = 60.sw;
                                  });
                                })
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
                              setState(() {});
                            },
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
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
                  extra: nameController.text,
                );
              }
            },
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 0),
                child: ButtonWidget(
                  child: state is EqubLoading
                      ? const LoadingWidget()
                      : const TextWidget(
                          text: 'Confirm',
                          color: Colors.white,
                          type: TextType.small,
                        ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<EqubBloc>().add(
                            AddEqub(
                              currencyCode: selectedCurrencyCode,
                              equbModel: EqubModel(
                                name: nameController.text,
                                contributionAmount:
                                    double.tryParse(amountController.text) ?? 0,
                                frequency: selectedFrequency!,
                                numberOfMembers: int.tryParse(
                                        numberOfMembersController.text) ??
                                    0,
                                startDate: startingDate!,
                                members: selectedContacts
                                    .map((c) => ContactModel(
                                          contactId: c.id,
                                          name: c.displayName,
                                          phoneNumber: c.phones.first.number,
                                        ))
                                    .toList(),
                              ),
                            ),
                          );
                    }
                  },
                ),
              );
            },
          )
        ],
      ),
    );
  }

  _buildEqubTextFeilds(
      {bool isReviewPage = false, required EqubCurrenciesSuccess state}) {
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
                        currencyFilter: state.currencies,
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
                            '${selectedCurrency == null ? '🇺🇸' : CurrencyUtils.currencyToEmoji(selectedCurrency!)} $selectedCurrencyCode',
                        type: TextType.small,
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_outlined,
                      ),
                    ],
                  )),
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
          readOnly: true,
          controller: dateController,
          hintText: 'Select the Starting date for the Equb.',
          suffix: const Icon(
            Icons.date_range,
            color: Color(0xFF646464),
          ),
          onTab: () async {
            startingDate = await showCupertinoDatePicker(context);

            if (startingDate != null) {
              setState(() {
                dateController.text =
                    '${startingDate?.day}-${startingDate?.month}-${startingDate?.year}';
              });
            }
          },
        ),
      ],
    );
  }

  _buildReviewTop() {
    return Container(
      width: 100.sw,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 64,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(
              color: ColorName.primaryColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4776E6),
                        Color(0xFF8E54E9),
                      ],
                    ),
                  ),
                  child: Center(
                    child: nameController.text.isNotEmpty
                        ? TextWidget(
                            text: nameController.text.split(' ').length == 1
                                ? nameController.text
                                    .split('')
                                    .first
                                    .toUpperCase()
                                : nameController.text.split(' ').isNotEmpty
                                    ? nameController.text
                                        .split(' ')
                                        .map((e) => e[0])
                                        .join()
                                        .toUpperCase()
                                    : nameController.text[0],
                            color: Colors.white,
                            fontSize: 14,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget(
                      text: nameController.text.trim(),
                      color: Colors.white,
                    ),
                    TextWidget(
                      text:
                          'Created at ${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}',
                      color: Colors.white,
                      fontSize: 10,
                      weight: FontWeight.w400,
                    ),
                  ],
                ),
                const Expanded(child: SizedBox()),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                    ),
                    onPressed: () {
                      setState(() {
                        index = 0;
                        sliderWidth = 30.sw;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const TextWidget(
                          text: 'Edit',
                          fontSize: 12,
                          color: ColorName.primaryColor,
                        ),
                        const SizedBox(width: 3),
                        SvgPicture.asset(
                          Assets.images.svgs.editIcon,
                        ),
                      ],
                    ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(Assets.images.svgs.adminIcon),
                    const SizedBox(width: 10),
                    TextWidget(
                      text: adminName,
                      fontSize: 14,
                      color: const Color(0xfF6D6D6D),
                    ),
                    const Expanded(child: SizedBox()),
                    const Icon(
                      Icons.groups_outlined,
                      color: Color(0xfF6D6D6D),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    TextWidget(
                      text: 'Members : ${selectedContacts.length}',
                      fontSize: 14,
                      color: const Color(0xfF6D6D6D),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.images.svgs.endTimeIcon,
                      color: const Color(0xfF6D6D6D),
                    ),
                    const SizedBox(width: 10),
                    const TextWidget(
                      text: 'Start Date',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
                    ),
                    const Expanded(child: SizedBox()),
                    TextWidget(
                      text:
                          '${startingDate?.day}-${startingDate?.month}-${startingDate?.year}',
                      fontSize: 14,
                      color: const Color(0xfF6D6D6D),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.images.svgs.frequencyIcon,
                      color: const Color(0xfF6D6D6D),
                    ),
                    const SizedBox(width: 10),
                    const TextWidget(
                      text: 'Frequency',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
                    ),
                    const Expanded(child: SizedBox()),
                    TextWidget(
                      text: selectedFrequency ?? '',
                      fontSize: 14,
                      color: const Color(0xfF6D6D6D),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.images.svgs.equbIcon,
                      color: const Color(0xfF6D6D6D),
                      width: 14,
                      height: 14,
                    ),
                    const SizedBox(width: 10),
                    const TextWidget(
                      text: 'Contribution amount',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
                    ),
                    const Expanded(child: SizedBox()),
                    TextWidget(
                      text: '\$${amountController.text}',
                      fontSize: 14,
                      color: const Color(0xfF6D6D6D),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      Assets.images.svgs.amountIcon,
                      color: const Color(0xfF6D6D6D),
                    ),
                    const SizedBox(width: 10),
                    const TextWidget(
                      text: 'Total amount',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
                    ),
                    const Expanded(child: SizedBox()),
                    TextWidget(
                      text: numberOfMembersController.text.isNotEmpty
                          ? '\$${(int.tryParse(numberOfMembersController.text) ?? 0) * (int.tryParse(amountController.text) ?? 0)}'
                          : '',
                      fontSize: 14,
                      color: const Color(0xfF6D6D6D),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
