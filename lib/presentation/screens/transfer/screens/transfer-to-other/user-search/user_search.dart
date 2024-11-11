import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../../../gen/assets.gen.dart';
import '../../../../../../gen/colors.gen.dart';
import '../../../../../widgets/text_widget.dart';
import '../recents/recent_sent_user_vertical_list.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});
  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(3, 2),
                    ),
                  ],
                  color: ColorName.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 20,
                    ),
                    SvgPicture.asset(Assets.images.svgs.search),
                    const SizedBox(
                      width: 20,
                    ),
                    const Expanded(
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: '',
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        context.pop(context);
                      },
                      child: Container(
                        height: 60,
                        width: 100,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              spreadRadius: 3,
                              offset: const Offset(3, 4),
                            ),
                          ],
                          color: ColorName.white,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: const Center(
                          child: TextWidget(
                            text: 'Cancel',
                            color: ColorName.primaryColor,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Expanded(
            child: CustomScrollView(
              slivers: [
                RecentSentUserVerticallList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
