import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/circlular_dashed_border.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_field_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailNameController = TextEditingController();

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailNameController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final names = currentUser.displayName?.split(' ') ?? ['', ''];
      firstNameController.text = names.first;
      lastNameController.text = names.last;
      emailNameController.text = currentUser.email ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const TextWidget(
          text: 'Edit Profile',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Align(
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(0),
                              child: SizedBox(
                                width: 123,
                                height: 123,
                                child: CustomPaint(
                                  painter: CircularDashedBorderPainter(
                                    color: ColorName.primaryColor,
                                    dashSpace: 5,
                                  ),
                                  child: const Icon(
                                    Bootstrap.person,
                                    size: 43,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: SizedBox(
                                width: 32,
                                height: 32,
                                child: IconButton(
                                    style: IconButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      backgroundColor: ColorName.primaryColor,
                                      foregroundColor: ColorName.white,
                                    ),
                                    onPressed: () {
                                      //
                                    },
                                    icon: const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 18,
                                    )),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Padding(
                      padding: EdgeInsets.only(top: 10, bottom: 5),
                      child: TextWidget(
                        text: 'First Name',
                        fontSize: 12,
                      ),
                    ),
                    TextFieldWidget(
                      controller: firstNameController,
                      suffix: const Icon(
                        Icons.edit_outlined,
                        size: 17,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 5),
                      child: TextWidget(
                        text: 'Last Name',
                        fontSize: 12,
                      ),
                    ),
                    TextFieldWidget(
                      controller: lastNameController,
                      suffix: const Icon(
                        Icons.edit_outlined,
                        size: 17,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(top: 20, bottom: 5),
                      child: TextWidget(
                        text: 'Email',
                        fontSize: 12,
                      ),
                    ),
                    TextFieldWidget(
                      controller: emailNameController,
                      suffix: const Icon(
                        Icons.edit_outlined,
                        size: 17,
                      ),
                    ),
                    const SizedBox(height: 25),
                    // Align(
                    //   alignment: Alignment.center,
                    //   child: SizedBox(
                    //     width: 250,
                    //     height: 46,
                    //     child: ButtonWidget(
                    //         verticalPadding: 0,
                    //         child: const TextWidget(
                    //           text: 'Change Password',
                    //           type: TextType.small,
                    //           color: Colors.white,
                    //         ),
                    //         onPressed: () {
                    //           // context.pushNamed(RouteName.passwordEdit);
                    //         }),
                    //   ),
                    // ),
                    // const SizedBox(height: 15),
                  ],
                ),
              ),
            ),
            ButtonWidget(
              child: const TextWidget(
                text: 'Save Changes',
                type: TextType.small,
                color: Colors.white,
              ),
              onPressed: () {
                //
              },
            ),
            const SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
