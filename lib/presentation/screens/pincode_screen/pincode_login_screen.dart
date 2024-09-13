import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';

import '../../../bloc/pincode/pincode_bloc.dart';
import '../../../core/utils/settings.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/button_widget.dart';
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
  final pin1Controller = TextEditingController();
  final pin2Controller = TextEditingController();
  final pin3Controller = TextEditingController();
  final pin4Controller = TextEditingController();
  final pin5Controller = TextEditingController();
  final pin6Controller = TextEditingController();
  bool isValid = false;
  bool isAuthenticated = false;

  String firstPincode = '';

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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // widget.result(isAuthenticated);
        }
      },
      child: Scaffold(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPinBox(controller: pin1Controller),
                    _buildPinBox(controller: pin2Controller),
                    _buildPinBox(controller: pin3Controller),
                    _buildPinBox(controller: pin4Controller),
                    _buildPinBox(controller: pin5Controller),
                    _buildPinBox(controller: pin6Controller),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 30),
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
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinBox({required TextEditingController controller}) {
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
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
        ],
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
