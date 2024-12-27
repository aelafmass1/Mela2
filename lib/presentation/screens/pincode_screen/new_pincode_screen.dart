import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';

import '../../../config/routing.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/custom_keyboard.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/text_widget.dart';

class NewPincodeScreen extends StatefulWidget {
  final UserModel userModel;
  const NewPincodeScreen({super.key, required this.userModel});

  @override
  State<NewPincodeScreen> createState() => _NewPincodeScreenState();
}

class _NewPincodeScreenState extends State<NewPincodeScreen> {
  bool isValid = false;

  String pins = '';

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
            CustomKeyboard(
              onComplete: (p) {
                if (p.length == 6) {
                  setState(() {
                    pins = p;
                    isValid = true;
                  });
                } else {
                  setState(() {
                    pins = p;
                    isValid = false;
                  });
                }
              },
              buttonWidget: BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is ResetFail) {
                    showSnackbar(
                      context,
                      description: state.reason,
                    );
                  } else if (state is ResetSuccess) {
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
                          context.read<AuthBloc>().add(ResetPincode(
                                phoneNumber: int.tryParse(
                                        widget.userModel.phoneNumber!) ??
                                    0,
                                otp: widget.userModel.otp!,
                                countryCode: widget.userModel.countryCode!,
                                newPincode: pins,
                              ));
                        }
                        //
                      });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
