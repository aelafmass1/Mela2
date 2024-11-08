import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../../gen/assets.gen.dart';
import '../../../../gen/colors.gen.dart';
import '../../../widgets/text_widget.dart';
import '../components/recents/recent_sent_user_vertical_list.dart';
import 'components/search_cancel_input.dart';

class UserSearchScreen extends StatefulWidget {
  const UserSearchScreen({super.key});
  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: SearchCancelInput(),
            ),
          ),
          Expanded(
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
