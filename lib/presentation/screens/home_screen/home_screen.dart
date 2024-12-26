import 'dart:io' show Platform;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_upgrade_version/flutter_upgrade_version.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:transaction_mobile_app/core/utils/contact_utils.dart';
import 'package:transaction_mobile_app/core/utils/settings.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/tabs/account_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/equb_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/home_tab/home_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/history_tab.dart';
import 'package:transaction_mobile_app/presentation/tabs/send_tab.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../bloc/navigation/navigation_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int selectedIndex = 0;
  String? imageUrl;
  PackageInfo _packageInfo = PackageInfo();

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getPackageData() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    _packageInfo = await PackageManager.getPackageInfo();
    setState(() {});
  }

  Future<void> _checkForUpdate() async {
    try {
      if (Platform.isAndroid) {
        InAppUpdateManager manager = InAppUpdateManager();
        AppUpdateInfo? appUpdateInfo = await manager.checkForUpdate();
        if (appUpdateInfo == null) return;

        if (appUpdateInfo.updateAvailability ==
            UpdateAvailability.developerTriggeredUpdateInProgress) {
          ///If an in-app update is already running, resume the update.
          String? message =
              await manager.startAnUpdate(type: AppUpdateType.immediate);

          ///message return null when run update success
        } else if (appUpdateInfo.updateAvailability ==
            UpdateAvailability.updateAvailable) {
          ///Update available
          if (appUpdateInfo.immediateAllowed) {
            String? message =
                await manager.startAnUpdate(type: AppUpdateType.immediate);

            ///message return null when run update success
          } else if (appUpdateInfo.flexibleAllowed) {
            String? message =
                await manager.startAnUpdate(type: AppUpdateType.flexible);

            ///message return null when run update success
          } else {}
        }
      } else if (Platform.isIOS) {
        VersionInfo? versionInfo = await UpgradeVersion.getiOSStoreVersion(
          packageInfo: _packageInfo,
        );
        if (versionInfo.canUpdate) {
          _showUpdateBottomSheet(versionInfo.appStoreLink);
        }
      }
    } catch (e) {}
  }

  // Method to show the BottomSheet
  void _showUpdateBottomSheet(String storeLink) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "New Update Available",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Align(
                      alignment: Alignment.centerRight,
                      child: SvgPicture.asset(
                        Assets.images.svgs.melaLogo,
                        width: 40,
                        height: 40,
                        color: ColorName.primaryColor,
                      )),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                "A newer version of the Mela Fi is available. Please update for the best experience.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 40,
                width: 100,
                child: ButtonWidget(
                  onPressed: () async {
                    context.pop(); // Close the BottomSheet
                    await launchUrl(Uri.parse(storeLink));
                  },
                  child: const TextWidget(
                    text: "Update Now",
                    type: TextType.small,
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close the BottomSheet
                },
                child: const TextWidget(
                  text: "Later",
                  color: ColorName.primaryColor,
                  type: TextType.small,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  reviewTheApp() async {
    final InAppReview inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      inAppReview.requestReview();
    }
  }

  @override
  void initState() {
    super.initState();
    getImageUrl().then((value) {
      imageUrl = value;
    });
    reviewTheApp();
    context.read<NavigationBloc>().add(NavigateTo(index: 0));
    fetchContacts(context);
    // getPackageData().then((value) {
    //   _checkForUpdate();
    // });
  }

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
          ? imageUrl != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: imageUrl!,
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
