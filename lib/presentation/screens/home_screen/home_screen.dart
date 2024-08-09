import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/tabs/account_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/equb_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/home_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/news_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/sent_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController tabController;
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
        color: ColorName.primaryColor,
        child: TabBar(
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 10,
          ),
          controller: tabController,
          indicator: const BoxDecoration(),
          labelColor: Colors.white,
          unselectedLabelColor: const Color(0xFFF0F0F3).withOpacity(0.5),
          tabs: const [
            Tab(
              icon: Icon(
                Icons.home,
                size: 27,
              ),
              text: 'Home',
              iconMargin: EdgeInsets.only(bottom: 5),
            ),
            Tab(
              icon: Icon(
                Icons.savings,
                size: 27,
              ),
              text: 'Equb',
              iconMargin: EdgeInsets.only(bottom: 5),
            ),
            Tab(
              icon: Icon(
                Icons.send,
                size: 27,
              ),
              text: 'Sent',
              iconMargin: EdgeInsets.only(bottom: 5),
            ),
            Tab(
              icon: Icon(
                Icons.newspaper,
                size: 27,
              ),
              text: 'News',
              iconMargin: EdgeInsets.only(bottom: 5),
            ),
            Tab(
              icon: Icon(
                Icons.person,
                size: 27,
              ),
              text: 'Account',
              iconMargin: EdgeInsets.only(bottom: 5),
            ),
          ],
        ),
      ),
    );
  }
}
