import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/tabs/account_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/equb_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/home_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/history_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/send_tab.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../bloc/navigation/navigation_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<NavigationBloc, NavigationState>(
        listener: (context, state) {
          setState(() {
            selectedIndex = state.index;
          });
        },
        builder: (context, state) {
          return TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              controller: state.tabController,
              children: const [
                HomeTab(),
                EqubTab(),
                SentTab(),
                HistoryTab(),
                AccountTab(),
              ]);
        },
      ),
      bottomNavigationBar: Container(
        height: 68,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFF0F0F0),
            ),
          ),
        ),
        child: ColoredBox(
          color: Colors.white,
          child: BlocBuilder<NavigationBloc, NavigationState>(
            builder: (context, state) {
              return TabBar(
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 10,
                ),
                controller: state.tabController,
                indicator: const BoxDecoration(),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFFF0F0F3).withOpacity(0.5),
                onTap: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
                  if (value == 0) {
                    analytics.logEvent(name: 'Home Tab Clicked');
                  } else if (value == 1) {
                    analytics.logEvent(name: 'Equb Tab Clicked');
                  } else if (value == 2) {
                    analytics.logEvent(name: 'Send Tab Clicked');
                  } else if (value == 2) {
                    analytics.logEvent(name: 'Send Tab Clicked');
                  } else if (value == 3) {
                    analytics.logEvent(name: 'News Tab Clicked');
                  } else if (value == 4) {
                    analytics.logEvent(name: 'Account Tab Clicked');
                  }
                },
                tabs: [
                  _buildTab(
                      text: 'Home',
                      iconPath: Assets.images.svgs.homeIcon,
                      id: 0),
                  _buildTab(
                      text: 'Equb',
                      iconPath: Assets.images.svgs.equbIcon,
                      id: 1),
                  _buildTab(
                      text: 'Send',
                      iconPath: Assets.images.svgs.sendIcon,
                      id: 2),
                  _buildTab(
                      text: 'History',
                      iconPath: Assets.images.svgs.historyIcon,
                      id: 3),
                  _buildTab(
                      text: 'Account',
                      iconPath: Assets.images.profileImage.path,
                      isAccountTab: true,
                      id: 4),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  _buildTab(
      {required String text,
      required String iconPath,
      required int id,
      bool isAccountTab = false}) {
    return Tab(
      icon: isAccountTab
          ? FirebaseAuth.instance.currentUser?.photoURL != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: FirebaseAuth.instance.currentUser!.photoURL!,
                    progressIndicatorBuilder: (context, url, progress) {
                      return const SizedBox(
                        width: 25,
                        height: 25,
                      );
                    },
                    width: 25,
                    height: 25,
                    fit: BoxFit.cover,
                  ),
                )
              : CircleAvatar(
                  radius: 13,
                  backgroundImage: AssetImage(iconPath),
                )
          : SvgPicture.asset(
              iconPath,
              width: isAccountTab ? 24 : null,
              height: isAccountTab ? 24 : null,
              // ignore: deprecated_member_use
              color: selectedIndex == id ? ColorName.primaryColor : null,
            ),
      iconMargin: const EdgeInsets.only(bottom: 5),
      child: TextWidget(
        text: text,
        fontSize: 10,
        color: selectedIndex == id ? ColorName.primaryColor : null,
      ),
    );
  }
}
