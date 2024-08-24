import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/data/models/user_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class ProfileUploadScreen extends StatefulWidget {
  final UserModel userModel;
  const ProfileUploadScreen({super.key, required this.userModel});

  @override
  State<ProfileUploadScreen> createState() => _ProfileUploadScreenState();
}

class _ProfileUploadScreenState extends State<ProfileUploadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15),
            child: SizedBox(
              width: 70,
              height: 28,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xFFD0D0D0),
                          ))),
                  onPressed: () {
                    //
                  },
                  child: const TextWidget(
                    text: 'Skip',
                    weight: FontWeight.w500,
                    type: TextType.small,
                    color: Color(0xFFD0D0D0),
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
                      child: Center(
                        child: SvgPicture.asset(Assets.images.svgs.cameraIcon),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side:
                              const BorderSide(color: ColorName.primaryColor))),
                  onPressed: () {
                    showModalBottomSheet(
                        context: context,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                        )),
                        builder: (_) => _buildBottomModalSheet());
                  },
                  child: const TextWidget(
                    text: 'Upload profile',
                    type: TextType.small,
                    color: ColorName.primaryColor,
                  )),
            ),
            const SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  _buildBottomModalSheet() {
    return SizedBox(
      width: 100.sw,
      height: 40.sh,
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
              onTap: () {
                //
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
            ListTile(
              onTap: () {
                //
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
            ListTile(
              onTap: () {
                //
              },
              leading: Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: ColorName.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline,
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
