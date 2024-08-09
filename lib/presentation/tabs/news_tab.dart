import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';

class NewsTab extends StatelessWidget {
  const NewsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Assets.images.newsBackground.image(),
      ),
    );
  }
}
