import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class RecentsSentUsersHorizontalList extends StatelessWidget {
  const RecentsSentUsersHorizontalList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: TextWidget(
            text: 'Recents',
            fontSize: 16,
            weight: FontWeight.w500,
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                        'https://via.placeholder.com/150',
                      ),
                    ),
                    TextWidget(
                      text: 'Beza',
                      fontSize: 12,
                      weight: FontWeight.w400,
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ],
    ));
  }
}
