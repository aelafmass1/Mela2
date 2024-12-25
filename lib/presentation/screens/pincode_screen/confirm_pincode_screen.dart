import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';

import '../../../core/utils/show_snackbar.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/custom_keyboard.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/text_widget.dart';

class ConfirmPincodeScreen extends StatefulWidget {
  final UserModel user;
  final String pincode;
  const ConfirmPincodeScreen(
      {super.key, required this.user, required this.pincode});

  @override
  State<ConfirmPincodeScreen> createState() => _ConfirmPincodeScreenState();
}

class _ConfirmPincodeScreenState extends State<ConfirmPincodeScreen> {
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const TextWidget(
                text: 'Confirm your PIN',
                color: ColorName.primaryColor,
                fontSize: 20,
                weight: FontWeight.w700,
              ),
              const SizedBox(height: 5),
              const TextWidget(
                text: 'Please remember to keep it secure.',
                fontSize: 14,
                color: ColorName.grey,
                weight: FontWeight.w400,
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
                      if (state is RegisterUserFail) {
                        showSnackbar(
                          context,
                          title: 'Error',
                          description: state.reason,
                        );
                      } else if (state is RegisterUserSuccess) {
                        setIsLoggedIn(true);
                        setFirstTime(false);
                        context.goNamed(RouteName.home);
                      }
                    },
                    builder: (context, state) {
                      return ButtonWidget(
                          color: isValid
                              ? ColorName.primaryColor
                              : ColorName.grey.shade200,
                          child: state is RegisterUserLoaing
                              ? const LoadingWidget()
                              : const TextWidget(
                                  text: 'Set up PIN',
                                  type: TextType.small,
                                  color: Colors.white,
                                ),
                          onPressed: () {
                            if (isValid) {
                              if (pins == widget.pincode) {
                                context.read<AuthBloc>().add(
                                      CreateAccount(
                                        userModel: widget.user.copyWith(
                                          pinCode: pins,
                                        ),
                                      ),
                                    );
                              } else {
                                showSnackbar(context,
                                    title: 'Error',
                                    description: 'PIN is not the same');
                              }
                            }
                            //
                          });
                    },
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
