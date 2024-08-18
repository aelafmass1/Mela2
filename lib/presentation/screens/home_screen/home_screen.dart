import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/tabs/account_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/equb_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/home_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/news_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/send_tab.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
  int selectedIndex = 0;
  @override
  void initState() {
    tabController = TabController(length: 5, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabBarView(controller: tabController, children: const [
        HomeTab(),
        EqubTab(),
        SentTab(),
        NewsTab(),
        AccountTab(),
      ]),
      bottomNavigationBar: Container(
        height: 68,
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Color(0xFFF0F0F0),
            ),
          ),
        ),
        child: TabBar(
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 10,
          ),
          controller: tabController,
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
                text: 'Home', iconPath: Assets.images.homeIcon.path, id: 0),
            _buildTab(
                text: 'Equb', iconPath: Assets.images.equbIcon.path, id: 1),
            _buildTab(
                text: 'Send', iconPath: Assets.images.sendIcon.path, id: 2),
            _buildTab(
                text: 'History',
                iconPath: Assets.images.historyIcon.path,
                id: 3),
            _buildTab(
                text: 'Account',
                iconPath: Assets.images.profileImage.path,
                isAccountTab: true,
                id: 4),
          ],
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
          ? CircleAvatar(
              radius: 13,
              backgroundImage: AssetImage(iconPath),
            )
          : Image.asset(
              iconPath,
              width: isAccountTab ? 24 : null,
              height: isAccountTab ? 24 : null,
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
