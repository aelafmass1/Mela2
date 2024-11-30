import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/bloc/notification/notification_bloc.dart';
import 'package:transaction_mobile_app/bloc/payment_card/payment_card_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/reset_app_state.dart';
import 'package:transaction_mobile_app/core/utils/responsive_util.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/services/firebase/fcm_service.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  String? displayName;
  String? imageUrl;
  String? email;
  String? phoneNumber;
  @override
  void initState() {
    getDisplayName().then((value) {
      setState(() {
        displayName = value;
      });
    });
    getImageUrl().then((value) {
      setState(() {
        imageUrl = value;
      });
    });
    getPhoneNumber().then((value) {
      getCountryCode().then((countrycode) {
        setState(() {
          phoneNumber = '+$countrycode $value';
        });
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 50,
        elevation: 0,
        title: const TextWidget(text: 'Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (mounted) {
                  if (context.mounted) {
                    if (state is DeleteUserLoading) {
                      showDialog(
                        context: context,
                        builder: (_) => const Align(
                          child: LoadingWidget(),
                        ),
                      );
                    } else if (state is DeleteUserSucess) {
                      resetAppState(context);
                      deleteToken();
                      deleteDisplayName();
                      deletePhoneNumber();
                      deleteLogInStatus();
                      deleteCountryCode();
                      context.goNamed(RouteName.signup);
                    } else if (state is DeleteUserFail) {
                      context.pop();
                      showSnackbar(
                        context,
                        title: 'Error',
                        description: state.reason,
                      );
                    }
                  }
                }
              },
            ),
            BlocListener<NotificationBloc, NotificationState>(
              listener: (context, state) {
                if (state is DeleteFcmTokenLoading) {
                  showDialog(
                    context: context,
                    builder: (_) => const Align(
                      child: LoadingWidget(),
                    ),
                  );
                } else if (state is DeleteFcmTokenSuccess) {
                  context.read<PaymentCardBloc>().add(ResetPaymentCard());

                  context.pop();
                  deleteToken();
                  deleteDisplayName();
                  deletePhoneNumber();
                  deleteLogInStatus();
                  deleteCountryCode();
                  context.goNamed(RouteName.signup);
                } else if (state is DeleteFcmTokenFailure) {
                  context.pop();
                  showSnackbar(
                    context,
                    description: state.reason,
                  );
                }
              },
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 10),
                  child: CardWidget(
                    width: 100.sw,
                    padding: const EdgeInsets.all(20),
                    borderRadius: BorderRadius.circular(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ResponsiveBuilder(builder: (context, sizingInfo) {
                          return CircleAvatar(
                            radius: ResponsiveUtil.forScreen(
                              sizingInfo: sizingInfo,
                              mobile: 30,
                              tablet: 35,
                            ),
                            backgroundImage: imageUrl != null
                                ? CachedNetworkImageProvider(imageUrl!)
                                : Assets.images.profileImage.provider(),
                          );
                        }),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextWidget(text: displayName ?? ''),
                            TextWidget(
                              text: phoneNumber ?? '',
                              fontSize: 15,
                              color: const Color(0xFF4D4D4D).withOpacity(0.75),
                            ),
                            Container(
                              width: 107,
                              height: 24,
                              margin: const EdgeInsets.only(top: 5),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 7),
                              decoration: BoxDecoration(
                                  color: ColorName.green,
                                  borderRadius: BorderRadius.circular(30)),
                              child: const Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Icon(
                                    Icons.verified_outlined,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  TextWidget(
                                    text: 'Verified User',
                                    fontSize: 12,
                                    weight: FontWeight.w300,
                                    color: Colors.white,
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const Expanded(child: SizedBox()),
                        Column(
                          children: [
                            InkWell(
                              onTap: () {
                                context.pushNamed(RouteName.profileEdit);
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: ColorName.primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_outlined,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 3),
                            const TextWidget(
                              text: 'Edit',
                              fontSize: 12,
                              weight: FontWeight.w300,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // _buildTab(
                //   icon: Icons.settings_outlined,
                //   title: 'Account Setting',
                //   onTab: () {
                //     //
                //   },
                // ),
                // _buildTab(
                //   icon: Icons.lock_outlined,
                //   title: 'Security Setting',
                //   onTab: () {
                //     //
                //   },
                // ),
                // _buildTab(
                //   icon: Icons.edit_outlined,
                //   title: 'Edit Account',
                //   onTab: () {
                //     //
                //   },
                // ),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: TextWidget(
                    text: 'Account setting',
                    fontSize: 16,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 15),
                CardWidget(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  width: 100.sw,
                  child: Column(
                    children: [
                      _buildTab(
                        icon: Icons.person_outline,
                        title: 'Personal Info',
                        onTab: () {
                          context.pushNamed(RouteName.profileEdit);
                        },
                      ),
                      _buildTab(
                        icon: Icons.delete_outline,
                        title: 'Delete My Profile',
                        isLogout: false,
                        onTab: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const TextWidget(
                                text: 'Delete User',
                                type: TextType.small,
                              ),
                              content: const TextWidget(
                                text:
                                    'Are you sure you want to delete your profile?',
                                fontSize: 15,
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      context.pop();
                                    },
                                    child: const TextWidget(
                                      text: 'cancel',
                                      type: TextType.small,
                                    )),
                                TextButton(
                                    onPressed: () {
                                      context.pop();
                                      context
                                          .read<AuthBloc>()
                                          .add(DeleteUser());
                                    },
                                    child: const TextWidget(
                                      text: 'ok',
                                      type: TextType.small,
                                      color: ColorName.red,
                                    )),
                              ],
                            ),
                          );
                        },
                      ),
                      _buildTab(
                        icon: Icons.power_settings_new_outlined,
                        title: 'Logout',
                        isLogout: true,
                        onTab: () {
                          context.read<NotificationBloc>().add(
                                DeleteFCMToken(
                                  fcmToken: FCMService.fcmToken,
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTab(
      {required IconData icon,
      required String title,
      required Function() onTab,
      bool isLogout = false}) {
    return GestureDetector(
      onTap: onTab,
      child: ResponsiveBuilder(builder: (context, sizingInfo) {
        return ListTile(
          title: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: isLogout ? ColorName.red : const Color(0xFF666666),
              ),
              const SizedBox(width: 10),
              TextWidget(
                text: title,
                fontSize: 15,
                color: isLogout ? ColorName.red : const Color(0xFF666666),
                weight: FontWeight.w400,
              ),
            ],
          ),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            size: 24,
            color: isLogout ? ColorName.red : const Color(0xFF666666),
          ),
        );
      }),
    );
  }
}
