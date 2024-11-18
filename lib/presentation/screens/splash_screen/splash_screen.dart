// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';

import '../../../bloc/contact/contact_bloc.dart';
import '../../../core/utils/settings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  checkStatus() async {
    if (await Permission.contacts.isGranted == true) {
      if (await FlutterContacts.requestPermission(readonly: true)) {
        List<Contact> contacts =
            await FlutterContacts.getContacts(withProperties: true);
        if (mounted) {
          context.read<ContactBloc>().add(CheckMyContacts(contacts: contacts));
        }
      }
    }
    if (await isFirstTime() == false) {
      final isLoggedIN = await isLoggedIn();
      if (isLoggedIN) {
        context.goNamed(RouteName.loginPincode);
      } else {
        context.goNamed(RouteName.signup);
      }
    } else {
      context.goNamed(RouteName.welcome);
    }
  }

  @override
  void initState() {
    checkStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: ColorName.primaryColor,
      ),
      backgroundColor: ColorName.primaryColor,
      body: Center(
        child: Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
            ),
            child: SvgPicture.asset(
              Assets.images.svgs.melaLogo,
              color: ColorName.primaryColor,
              height: 50,
              width: 50,
            )),
      ),
    );
  }
}
