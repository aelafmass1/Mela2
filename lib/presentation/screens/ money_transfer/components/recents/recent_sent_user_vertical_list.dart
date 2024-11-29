import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';

import '../../../../widgets/text_widget.dart';

class RecentSentUserVerticallList extends StatefulWidget {
  const RecentSentUserVerticallList({super.key});

  @override
  State<RecentSentUserVerticallList> createState() =>
      _RecentSentUserVerticallListState();
}

class _RecentSentUserVerticallListState
    extends State<RecentSentUserVerticallList> {
  @override
  Widget build(BuildContext context) {
    return SliverMainAxisGroup(slivers: [
      SliverPersistentHeader(
        pinned: true,
        floating: true,
        delegate: _SliverAppBarDelegate(),
      ),
      SliverList.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 2),
            child: Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.1),
              color: ColorName.white,
              child: ListTile(
                leading: CircleAvatar(
                  radius: 24,
                  backgroundImage:
                      NetworkImage('https://picsum.photos/${150 + index}'),
                ),
                title: const Text('Beza'),
                subtitle: const Text('+251 912 345 678'),
                onTap: () {
                  context.pop("user");
                },
              ),
            ),
          );
        },
      ),
    ]);
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      height: maxExtent,
      color: Theme.of(context).scaffoldBackgroundColor,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: '   Recents',
              fontSize: 16,
              weight: FontWeight.w500,
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  @override
  double get maxExtent => 40;

  @override
  double get minExtent => 40;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
