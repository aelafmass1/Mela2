import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/auth/auth_bloc.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../config/routing.dart';
import '../../../core/utils/settings.dart';

class ProfileUploadScreen extends StatefulWidget {
  final UserModel userModel;
  const ProfileUploadScreen({super.key, required this.userModel});

  @override
  State<ProfileUploadScreen> createState() => _ProfileUploadScreenState();
}

class _ProfileUploadScreenState extends State<ProfileUploadScreen> {
  XFile? profilePicture;
  bool isSkipClicked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: SizedBox(
              width: 70,
              height: 32,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                            width: 1,
                            color: Colors.black87,
                          ))),
                  onPressed: () {
                    context.goNamed(RouteName.home);
                  },
                  child: const TextWidget(
                    text: 'Skip',
                    weight: FontWeight.w500,
                    type: TextType.small,
                    color: Colors.black,
                  )),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: const BoxDecoration(
                        color: ColorName.primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: profilePicture != null
                          ? ClipOval(
                              child: Image.file(
                                File(profilePicture!.path),
                                fit: BoxFit.cover,
                                width: 180,
                                height: 180,
                              ),
                            )
                          : Center(
                              child: SvgPicture.asset(
                                  Assets.images.svgs.cameraIcon),
                            ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const TextWidget(text: 'Upload  profile picture'),
                  const SizedBox(height: 5),
                  const TextWidget(
                    text: 'Select profile picture from Camera or Gallery',
                    type: TextType.small,
                    weight: FontWeight.w400,
                    color: ColorName.grey,
                  )
                ],
              ),
            ),
            SizedBox(
              width: 100.sw,
              height: 50,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: profilePicture != null
                          ? ColorName.primaryColor
                          : null,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side:
                              const BorderSide(color: ColorName.primaryColor))),
                  onPressed: () {
                    if (profilePicture == null) {
                      showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          )),
                          builder: (_) => _buildBottomModalSheet());
                    } else {
                      context.read<AuthBloc>().add(
                            UploadProfilePicture(
                              profilePicture: profilePicture!,
                              phoneNumber: widget.userModel.phoneNumber!,
                            ),
                          );
                    }
                  },
                  child: BlocConsumer<AuthBloc, AuthState>(
                    listener: (context, state) {
                      if (state is UploadProfileFail) {
                        showSnackbar(context,
                            title: 'Error', description: state.reason);
                      } else if (state is UploadProfileSuccess) {
                        setFirstTime(false);
                        context.goNamed(RouteName.home);
                      }
                    },
                    builder: (context, state) {
                      return state is UploadProfileLoading
                          ? const LoadingWidget()
                          : TextWidget(
                              text: profilePicture == null
                                  ? 'Upload profile'
                                  : 'Register',
                              type: TextType.small,
                              color: profilePicture == null
                                  ? ColorName.primaryColor
                                  : Colors.white,
                            );
                    },
                  )),
            ),
            const SizedBox(
              height: 20,
            )
          ],
        ),
      ),
    );
  }

  _buildBottomModalSheet() {
    return SizedBox(
      width: 100.sw,
      height: 30.sh,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 100,
                height: 8,
                margin: const EdgeInsets.only(top: 10, bottom: 25),
                decoration: BoxDecoration(
                    color: const Color(0xFFD0D0D0),
                    borderRadius: BorderRadius.circular(5)),
              ),
            ),
            const TextWidget(
              text: 'Upload Profile',
              type: TextType.small,
            ),
            const SizedBox(height: 20),
            ListTile(
              onTap: () async {
                profilePicture =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                // ignore: use_build_context_synchronously
                context.pop();
                if (profilePicture != null) {
                  setState(() {
                    profilePicture = profilePicture;
                  });
                }
              },
              leading: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: ColorName.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: const TextWidget(
                text: 'Take photo',
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),
            ListTile(
              onTap: () async {
                profilePicture =
                    await ImagePicker().pickImage(source: ImageSource.gallery);
                // ignore: use_build_context_synchronously
                context.pop();
                if (profilePicture != null) {
                  setState(() {
                    profilePicture = profilePicture;
                  });
                }
              },
              leading: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: Color(0xFFF8981F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              title: const TextWidget(
                text: 'Choose Photo',
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
