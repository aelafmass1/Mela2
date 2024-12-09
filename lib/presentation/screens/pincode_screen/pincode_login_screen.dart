import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/bloc/notification/notification_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/reset_app_state.dart';
import 'package:transaction_mobile_app/data/services/firebase/fcm_service.dart';

import '../../../core/utils/settings.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/text_widget.dart';

import 'package:transaction_mobile_app/data/services/api/api_service.dart';

import 'package:transaction_mobile_app/data/repository/kyc_repository.dart';
import 'package:jumio_mobile_sdk_flutter/jumio_mobile_sdk_flutter.dart';

class PincodeLoginScreen extends StatefulWidget {
  const PincodeLoginScreen({
    super.key,
  });

  @override
  State<PincodeLoginScreen> createState() => _PincodeLoginScreenState();
}

class _PincodeLoginScreenState extends State<PincodeLoginScreen> {
  late KycRepository kycRepository;

  bool showResendButton = false;
  final pin1Controller = TextEditingController();
  final pin2Controller = TextEditingController();
  final pin3Controller = TextEditingController();
  final pin4Controller = TextEditingController();
  final pin5Controller = TextEditingController();
  final pin6Controller = TextEditingController();

  final pin1Node = FocusNode();
  final pin2Node = FocusNode();
  final pin3Node = FocusNode();
  final pin4Node = FocusNode();
  final pin5Node = FocusNode();
  final pin6Node = FocusNode();

  bool isValid = false;
  bool isAuthenticated = false;

  String firstPincode = '';
  String displayName = '';

  List<String> getAllPins() {
    String pin1 = pin1Controller.text;
    String pin2 = pin2Controller.text;
    String pin3 = pin3Controller.text;
    String pin4 = pin4Controller.text;
    String pin5 = pin5Controller.text;
    String pin6 = pin6Controller.text;
    if (pin1.isNotEmpty &&
        pin2.isNotEmpty &&
        pin3.isNotEmpty &&
        pin4.isNotEmpty &&
        pin5.isNotEmpty &&
        pin6.isNotEmpty) {
      if (mounted) {
        setState(() {
          isValid = true;
        });
        context.read<AuthBloc>().add(
              LoginWithPincode(
                pincode: [pin1, pin2, pin3, pin4, pin5, pin6].join(),
              ),
            );
      }

      return [pin1, pin2, pin3, pin4, pin5, pin6];
    }
    if (mounted) {
      setState(() {
        isValid = false;
      });
    }

    return [];
  }

  /// Handles the key press event for the PIN code input fields.
  ///
  /// This method is responsible for updating the text in the appropriate PIN code
  /// input field based on the focus state of the input fields. It also requests
  /// focus on the next input field when a value is entered.
  ///
  /// After updating the input fields, it calls the `getAllPins()` method to
  /// retrieve the current values of all the PIN code input fields.
  ///
  /// Parameters:
  /// - `value`: The value of the key that was pressed.
  _onKeyPressed(String value) {
    if (pin1Node.hasFocus) {
      pin1Controller.text = value;
      pin2Node.requestFocus();
    } else if (pin2Node.hasFocus) {
      pin2Controller.text = value;
      pin3Node.requestFocus();
    } else if (pin3Node.hasFocus) {
      pin3Controller.text = value;
      pin4Node.requestFocus();
    } else if (pin4Node.hasFocus) {
      pin4Controller.text = value;
      pin5Node.requestFocus();
    } else if (pin5Node.hasFocus) {
      pin5Controller.text = value;
      pin6Node.requestFocus();
    } else if (pin6Node.hasFocus) {
      pin6Controller.text = value;
      if (pin1Controller.text.isEmpty) {
        pin1Node.requestFocus();
      } else {
        pin6Node.unfocus();
      }
    }

    getAllPins();
  }

  /// Handles the backspace key press event for the PIN code input fields.
  ///
  /// This method is responsible for clearing the text in the appropriate PIN code
  /// input field based on the focus state of the input fields. It also requests
  /// focus on the previous input field when a backspace is pressed.
  ///
  /// After updating the input fields, it calls the `getAllPins()` method to
  /// retrieve the current values of all the PIN code input fields.
  _onBackspace() {
    if (pin1Node.hasFocus) {
      pin1Controller.text = '';
    } else if (pin2Node.hasFocus) {
      pin2Controller.text = '';
      pin1Node.requestFocus();
    } else if (pin3Node.hasFocus) {
      pin3Controller.text = '';
      pin2Node.requestFocus();
    } else if (pin4Node.hasFocus) {
      pin4Controller.text = '';
      pin3Node.requestFocus();
    } else if (pin5Node.hasFocus) {
      pin5Controller.text = '';
      pin4Node.requestFocus();
    } else if (pin6Node.hasFocus) {
      pin6Controller.text = '';
      pin5Node.requestFocus();
    } else {
      pin5Node.requestFocus();
      pin6Controller.text = '';
    }
    getAllPins();
  }

  @override
  void initState() {
    getDisplayName().then((name) {
      final names = name?.trim().split(' ');
      if (names?.isNotEmpty == true) {
        setState(() {
          displayName = names?.first ?? '';
        });
      }
    });
    deleteToken();
    pin1Node.requestFocus();
    super.initState();
    kycRepository = KycRepository(client: ApiService().client);
  }

  @override
  void dispose() {
    pin1Controller.dispose();
    pin2Controller.dispose();
    pin3Controller.dispose();
    pin4Controller.dispose();
    pin5Controller.dispose();
    pin6Controller.dispose();

    //pincode dispose
    pin1Node.dispose();
    pin2Node.dispose();
    pin3Node.dispose();
    pin4Node.dispose();
    pin5Node.dispose();
    pin6Node.dispose();
    super.dispose();
  }

  void startJumioKYC(String jwt) async {
    try {
      final token = await kycRepository.fetchAuthorizationToken(jwt);
      if (token is String) {
        await Jumio.init(token, "US");
        Jumio.start();
      } else {
        showSnackbar(context,
            title: 'KYC Error', description: 'Invalid authorization token.');
      }
    } catch (e) {
      showSnackbar(context,
          title: 'Error', description: 'An unexpected error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 70,
        leading: const SizedBox.shrink(),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: TextButton(
                child: const TextWidget(
                  text: 'Logout',
                  type: TextType.small,
                  color: ColorName.primaryColor,
                ),
                onPressed: () {
                  resetAppState(context);
                  deleteToken();
                  deleteDisplayName();
                  deletePhoneNumber();
                  deleteLogInStatus();
                  deleteCountryCode();
                  context.goNamed(RouteName.signup);
                }),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              Align(
                alignment: Alignment.center,
                child: TextWidget(
                  text: 'Hi, welcome $displayName',
                  fontSize: 24,
                  weight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPinBox(
                        controller: pin1Controller, focusNode: pin1Node),
                    _buildPinBox(
                        controller: pin2Controller, focusNode: pin2Node),
                    _buildPinBox(
                        controller: pin3Controller, focusNode: pin3Node),
                    _buildPinBox(
                        controller: pin4Controller, focusNode: pin4Node),
                    _buildPinBox(
                        controller: pin5Controller, focusNode: pin5Node),
                    _buildPinBox(
                        controller: pin6Controller, focusNode: pin6Node),
                  ],
                ),
              ),
              const SizedBox(height: 60),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) async {
                  if (state is LoginWithPincodeFail) {
                    showSnackbar(
                      context,
                      title: 'Error',
                      description: state.reason,
                    );
                  } else if (state is LoginWithPincodeSuccess) {
                    // Retrieve the jwt from secure storage or AuthBloc
                    final jwt = await getToken();
                    if (jwt != null && jwt.isNotEmpty) {
                      startJumioKYC(jwt);
                    } else {
                      showSnackbar(context,
                          title: 'Error', description: 'JWT not found.');
                    }
                    if (FCMService.fcmToken.isNotEmpty) {
                      context.read<NotificationBloc>().add(
                            SaveFCMToken(
                              fcmToken: FCMService.fcmToken,
                            ),
                          );
                    }
                    setIsLoggedIn(true);
                    context.goNamed(RouteName.home);
                  }
                },
                builder: (context, state) {
                  return ButtonWidget(
                      color: isValid
                          ? ColorName.primaryColor
                          : ColorName.grey.shade200,
                      child: state is LoginWithPincodeLoading
                          ? const LoadingWidget()
                          : const TextWidget(
                              text: 'Continue',
                              type: TextType.small,
                              color: Colors.white,
                            ),
                      onPressed: () {
                        if (isValid) {
                          final pins = getAllPins();
                          context.read<AuthBloc>().add(
                                LoginWithPincode(
                                  pincode: pins.join(),
                                ),
                              );
                        }
                      });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const TextWidget(
                      text: 'Forgot my PIN?',
                      fontSize: 15,
                      weight: FontWeight.w300,
                    ),
                    TextButton(
                      onPressed: () {
                        context.pushNamed(
                          RouteName.forgetPassword,
                          extra: RouteName.newPincode,
                        );
                      },
                      child: const TextWidget(
                        text: 'Reset',
                        fontSize: 18,
                        color: ColorName.primaryColor,
                        weight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ),
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }

  // Build the custom numeric keypad
  Widget _buildKeypad() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['1', '2', '3'].map((number) {
              return _buildKey(number);
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['4', '5', '6'].map((number) {
              return _buildKey(number);
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ['7', '8', '9'].map((number) {
              return _buildKey(number);
            }).toList(),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 100,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Center(
                      child: Icon(
                    Icons.fingerprint_outlined,
                    size: 30,
                  )),
                ),
              ),
              _buildKey('0'),
              GestureDetector(
                onTap: _onBackspace,
                onLongPress: () {
                  pin1Controller.clear();
                  pin2Controller.clear();
                  pin3Controller.clear();
                  pin4Controller.clear();
                  pin5Controller.clear();
                  pin6Controller.clear();
                  pin1Node.requestFocus();
                  getAllPins();
                },
                child: Container(
                  width: 100,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                      child: SvgPicture.asset(
                    Assets.images.svgs.backSpace,
                    width: 30,
                  )),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // Build each button of the keypad
  Widget _buildKey(String value) {
    return SizedBox(
      width: 105,
      height: 65,
      child: GestureDetector(
        onTap: () => _onKeyPressed(value),
        onVerticalDragStart: (e) => _onKeyPressed(value),
        onHorizontalDragStart: (e) => _onKeyPressed(value),
        child: ButtonWidget(
          elevation: 0,
          horizontalPadding: 0,
          topPadding: 0,
          verticalPadding: 0,
          color: Colors.grey[100],
          onPressed: null,
          child: TextWidget(
            text: value,
            fontSize: 25,
          ),
        ),
      ),
    );
  }

  Widget _buildPinBox(
      {required TextEditingController controller,
      required FocusNode focusNode}) {
    return SizedBox(
      height: 70,
      width: 13.sw,
      child: TextFormField(
        controller: controller,
        onChanged: (value) {
          getAllPins();
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: ColorName.primaryColor,
              // color: isValid ? Colors.white : Colors.black,
            ),
        textAlign: TextAlign.center,
        readOnly: kIsWeb ? false : true,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          LengthLimitingTextInputFormatter(1),
        ],
        focusNode: focusNode,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: ColorName.primaryColor,
                width: 2,
              )),
        ),
      ),
    );
  }
}
