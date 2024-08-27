import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/responsive_util.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class AccountTab extends StatefulWidget {
  const AccountTab({super.key});

  @override
  State<AccountTab> createState() => _AccountTabState();
}

class _AccountTabState extends State<AccountTab> {
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (context.mounted) {
            if (state is AuthLoading) {
              showDialog(
                context: context,
                builder: (_) => const Align(child: LoadingWidget()),
              );
            } else if (state is AuthSuccess) {
              context.goNamed(RouteName.login);
            } else if (state is AuthFail) {
              context.pop();
              showSnackbar(
                context,
                title: 'Error',
                description: state.reason,
              );
            }
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 5),
              child: ResponsiveBuilder(builder: (context, sizingInfo) {
                return CircleAvatar(
                  radius: ResponsiveUtil.forScreen(
                    sizingInfo: sizingInfo,
                    mobile: 50,
                    tablet: 80,
                  ),
                  backgroundImage: auth.currentUser?.photoURL != null
                      ? CachedNetworkImageProvider(auth.currentUser!.photoURL!)
                      : Assets.images.profileImage.provider(),
                );
              }),
            ),
            TextWidget(text: auth.currentUser!.displayName ?? ''),
            TextWidget(
              text: 'Customer',
              fontSize: 15,
              color: const Color(0xFF4D4D4D).withOpacity(0.75),
            ),
            const SizedBox(height: 20),
            // _buildTab(
            //   icon: Icons.person_outline,
            //   title: 'Personal Information',
            //   onTab: () {
            //     //
            //   },
            // ),
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
            _buildTab(
              icon: Bootstrap.trash,
              title: 'Delete My Profile',
              isLogout: true,
              onTab: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const TextWidget(
                      text: 'Delete User',
                      type: TextType.small,
                    ),
                    content: const TextWidget(
                      text: 'Are you sure you want to delete your profile?',
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
                            context.read<AuthBloc>().add(DeleteUser());
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
              icon: Icons.logout,
              title: 'Logout',
              isLogout: true,
              onTab: () {
                FirebaseAuth.instance.signOut();
                context.goNamed(RouteName.login);
              },
            ),
          ],
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
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          width: ResponsiveUtil.forScreen(
              sizingInfo: sizingInfo, mobile: 100.sh, tablet: 50.sh),
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isLogout ? ColorName.red : Colors.black,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isLogout ? ColorName.red : const Color(0xFF666666),
              ),
              const SizedBox(width: 10),
              TextWidget(
                text: title,
                fontSize: 15,
                color: isLogout ? ColorName.red : const Color(0xFF666666),
                weight: FontWeight.w400,
              ),
              const Expanded(child: SizedBox()),
              Icon(
                Icons.keyboard_arrow_right,
                size: 24,
                color: isLogout ? ColorName.red : const Color(0xFF666666),
              )
            ],
          ),
        );
      }),
    );
  }
}
