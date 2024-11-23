import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';

import '../../../config/routing.dart';
import '../../../core/utils/settings.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/text_widget.dart';

class NewPincodeScreen extends StatefulWidget {
  final UserModel userModel;
  const NewPincodeScreen({super.key, required this.userModel});

  @override
  State<NewPincodeScreen> createState() => _NewPincodeScreenState();
}

class _NewPincodeScreenState extends State<NewPincodeScreen> {
  bool showResendButton = false;
  final pin1Controller = TextEditingController();
  final pin2Controller = TextEditingController();
  final pin3Controller = TextEditingController();
  final pin4Controller = TextEditingController();
  final pin5Controller = TextEditingController();
  final pin6Controller = TextEditingController();
  bool isValid = false;

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
  void initState() {
    log(widget.userModel.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
              text: 'Enter New PIN',
              fontSize: 20,
              color: ColorName.primaryColor,
            ),
            const SizedBox(height: 7),
            const TextWidget(
              text: 'Please keep your PIN confidential & secure.',
              color: ColorName.grey,
              fontSize: 14,
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
              listener: (context, state) async {
                if (state is ResetFail) {
                  showSnackbar(
                    context,
                    description: state.reason,
                  );
                } else if (state is ResetSuccess) {
                  final token = await getToken();
                  log(token.toString());
                  context.goNamed(RouteName.home);
                }
              },
              builder: (context, state) {
                return ButtonWidget(
                    color: isValid
                        ? ColorName.primaryColor
                        : ColorName.grey.shade200,
                    child: state is ResetLoading
                        ? const LoadingWidget()
                        : const TextWidget(
                            text: 'Set PIN',
                            type: TextType.small,
                            color: Colors.white,
                          ),
                    onPressed: () {
                      if (isValid) {
                        final pins = getAllPins().join();
                        context.read<AuthBloc>().add(ResetPincode(
                              phoneNumber:
                                  int.tryParse(widget.userModel.phoneNumber!) ??
                                      0,
                              otp: widget.userModel.otp!,
                              countryCode: widget.userModel.countryCode!,
                              newPincode: pins,
                            ));
                      }
                      //
                    });
              },
            )
          ],
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
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
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
