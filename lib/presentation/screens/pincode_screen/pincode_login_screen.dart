import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/presentation/widgets/pin_entry_widget.dart';

import '../../../core/utils/settings.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/keypad_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/text_widget.dart';

class PincodeLoginScreen extends StatefulWidget {
  const PincodeLoginScreen({
    super.key,
  });

  @override
  State<PincodeLoginScreen> createState() => _PincodeLoginScreenState();
}

class _PincodeLoginScreenState extends State<PincodeLoginScreen> {
  bool showResendButton = false;

  bool isValid = false;
  bool isAuthenticated = false;

  String firstPincode = '';
  validate() {
    final pins = getAllPins();
    final valid = pins.length == 6;

    setState(() {
      isValid = valid;
    });
  }

  List<String> getAllPins() {
    final pin = pinEntryWidgetKey.currentState?.getAllPins();
    return pin ?? <String>[];
  }

  clearPins() {
    pinEntryWidgetKey.currentState?.clearAll();
  }

  void insertPin(String pin) {
    pinEntryWidgetKey.currentState?.addPin(pin);
  }

  void removeLast() {
    pinEntryWidgetKey.currentState?.clearLast();
  }

  final pinEntryWidgetKey = GlobalKey<PinEntryWidgetState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 70,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: SvgPicture.asset(
              Assets.images.svgs.horizontalMelaLogo,
              width: 130,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TextWidget(
              text: 'Enter Your Pin',
              color: ColorName.primaryColor,
              fontSize: 20,
              weight: FontWeight.w700,
            ),
            const SizedBox(height: 5),
            const TextWidget(
              text: 'Enter your pin to confirm your Identity.',
              fontSize: 14,
              color: ColorName.grey,
              weight: FontWeight.w400,
            ),
            Padding(
                padding: const EdgeInsets.only(top: 40),
                child: PinEntryWidget(
                  key: pinEntryWidgetKey,
                )),
            const SizedBox(height: 40),
            BlocConsumer<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is LoginWithPincodeFail) {
                  showSnackbar(
                    context,
                    title: 'Error',
                    description: state.reason,
                  );
                } else if (state is LoginWithPincodeSuccess) {
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
              padding: const EdgeInsets.only(top: 20),
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
            const Spacer(),
            SafeArea(
              child: KeypadWidget(onBackPressed: () {
                removeLast();
                validate();
              }, onKeyPressed: (val) {
                insertPin(val);
                validate();
              }),
            )
          ],
        ),
      ),
    );
  }
}
