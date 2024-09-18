import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/components/equb_card.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../bloc/equb/equb_bloc.dart';

class EqubTab extends StatefulWidget {
  const EqubTab({super.key});

  @override
  State<EqubTab> createState() => _EqubTabState();
}

class _EqubTabState extends State<EqubTab> {
  @override
  void initState() {
    context.read<EqubBloc>().add(FetchEqubs());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 30,
      ),
      body: BlocConsumer<EqubBloc, EqubState>(
        listener: (context, state) {
          if (state is EqubFail) {
            showSnackbar(
              context,
              title: 'Error',
              description: state.reason,
            );
          }
        },
        builder: (context, state) {
          if (state is EqubLoading) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextWidget(text: 'Equb'),
                      SizedBox(
                        width: 110,
                        height: 45,
                        child: ButtonWidget(
                            child: const TextWidget(
                              text: 'Create New',
                              fontSize: 14,
                              color: ColorName.white,
                            ),
                            onPressed: () {
                              context.pushNamed(RouteName.equbCreation);
                            }),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Expanded(
                  child: Center(
                    child: LoadingWidget(
                      color: ColorName.primaryColor,
                    ),
                  ),
                ),
              ],
            );
          }
          if (state is EqubSuccess) {
            if (state.equbList.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: TextWidget(text: 'Equb'),
                    ),
                    const SizedBox(height: 20),
                    Assets.images.equbImage.image(),
                    const SizedBox(height: 20),
                    const TextWidget(
                      text: 'oops, You don’t have any Equb.',
                      type: TextType.small,
                      weight: FontWeight.w500,
                    ),
                    const SizedBox(height: 10),
                    const TextWidget(
                      text:
                          'Please create new Equb or you’ll see your active Equb when someone added you as a member',
                      fontSize: 12,
                      weight: FontWeight.w300,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 35),
                    ButtonWidget(
                        child: const TextWidget(
                          text: 'Create Equb',
                          color: Colors.white,
                          type: TextType.small,
                          weight: FontWeight.w500,
                        ),
                        onPressed: () {
                          context.pushNamed(RouteName.equbCreation);
                        })
                  ],
                ),
              );
            }
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const TextWidget(text: 'Equb'),
                      SizedBox(
                        width: 110,
                        height: 45,
                        child: ButtonWidget(
                            child: const TextWidget(
                              text: 'Create New',
                              fontSize: 14,
                              color: ColorName.white,
                            ),
                            onPressed: () {
                              context.pushNamed(RouteName.equbCreation);
                            }),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Expanded(
                  child: RefreshIndicator(
                    color: ColorName.primaryColor,
                    onRefresh: () async {
                      await Future.delayed(Durations.extralong1);
                      context.read<EqubBloc>().add(FetchEqubs());
                    },
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var equb in state.equbList) EqubCard(equb: equb),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
