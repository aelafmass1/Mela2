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
import 'package:transaction_mobile_app/data/services/api/api_service.dart';
import 'package:transaction_mobile_app/data/services/firebase/fcm_service.dart';
import 'package:transaction_mobile_app/data/repository/kyc_repository.dart';

import '../../../bloc/payment_card/payment_card_bloc.dart';
import '../../../core/utils/settings.dart';
import '../../../core/utils/show_snackbar.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/button_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/text_widget.dart';

import 'package:jumio_mobile_sdk_flutter/jumio_mobile_sdk_flutter.dart';

class PincodeLoginScreen extends StatefulWidget {
  const PincodeLoginScreen({super.key});

  @override
  State<PincodeLoginScreen> createState() => _PincodeLoginScreenState();
}

class _PincodeLoginScreenState extends State<PincodeLoginScreen> {
  late KycRepository kycRepository;

  final pinControllers = List.generate(6, (_) => TextEditingController());
  final pinNodes = List.generate(6, (_) => FocusNode());

  bool isValid = false;
  String displayName = '';

  @override
  void initState() {
    super.initState();
    kycRepository = KycRepository(client: ApiService().client);

    getDisplayName().then((name) {
      setState(() {
        displayName = name?.trim().split(' ').first ?? '';
      });
    });

    pinNodes.first.requestFocus();
    deleteToken(); // Reset token during initialization if needed.
  }

  @override
  void dispose() {
    for (var controller in pinControllers) {
      controller.dispose();
    }
    for (var node in pinNodes) {
      node.dispose();
    }
    super.dispose();
  }

  List<String> _getPinValues() {
    return pinControllers.map((controller) => controller.text).toList();
  }

  void _validatePins() {
    final pins = _getPinValues();
    final allFilled = pins.every((pin) => pin.isNotEmpty);

    setState(() {
      isValid = allFilled;
    });

    if (allFilled) {
      final joinedPin = pins.join();
      context.read<AuthBloc>().add(LoginWithPincode(pincode: joinedPin));
    }
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
              onPressed: () {
                resetAppState(context);
                deleteToken();
                deleteDisplayName();
                deletePhoneNumber();
                deleteLogInStatus();
                deleteCountryCode();
                context.goNamed(RouteName.signup);
              },
              child: const TextWidget(
                text: 'Logout',
                type: TextType.small,
                color: ColorName.primaryColor,
              ),
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
                  children: List.generate(
                    6,
                    (index) => _buildPinBox(
                      controller: pinControllers[index],
                      focusNode: pinNodes[index],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 60),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) async {
                  if (state is LoginWithPincodeFail) {
                    showSnackbar(context,
                        title: 'Error', description: state.reason);
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
                            SaveFCMToken(fcmToken: FCMService.fcmToken),
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
                    onPressed: isValid
                        ? () {
                            final joinedPin = _getPinValues().join();
                            context
                                .read<AuthBloc>()
                                .add(LoginWithPincode(pincode: joinedPin));
                          }
                        : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPinBox({
    required TextEditingController controller,
    required FocusNode focusNode,
  }) {
    return SizedBox(
      height: 70,
      width: 13.sw,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: ColorName.primaryColor,
            ),
        keyboardType: TextInputType.phone,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
          _validatePins();
        },
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
            ),
          ),
        ),
      ),
    );
  }
}
