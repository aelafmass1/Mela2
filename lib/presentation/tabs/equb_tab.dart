import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/equb_detail_model.dart';
import 'package:transaction_mobile_app/data/models/invitee_model.dart';
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
  List<EqubDetailModel> yourEqubs = [];
  List<EqubDetailModel> invitedEqubs = [];
  List<EqubDetailModel> otherEqubs = [];
  bool? isDescoveryEqubFound;
  List<Contact> _contacts = [];

  Future<void> _fetchContacts() async {
    if (await Permission.contacts.isDenied) {
      await Future.delayed(const Duration(seconds: 10));
    }
    if (await FlutterContacts.requestPermission(readonly: true)) {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
      });
    }
    setState(() {
      isDescoveryEqubFound = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    context.read<EqubBloc>().add(FetchAllEqubs());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        toolbarHeight: 20,
      ),
      body: BlocConsumer<EqubBloc, EqubState>(
        listener: (context, state) async {
          if (state is EqubFail) {
            showSnackbar(
              context,
              title: 'Error',
              description: state.reason,
            );
          } else if (state is EqubSuccess) {
            setState(() {
              yourEqubs = state.equbList.where((e) => e.isAdmin).toList();
              invitedEqubs =
                  state.equbList.where((e) => e.isAdmin == false).toList();
            });
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
                      const TextWidget(
                        text: 'Equb',
                        weight: FontWeight.w700,
                      ),
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

          if (state.equbList.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: TextWidget(
                        text: 'Equb',
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Assets.images.equbImage.image(
                      width: 250,
                    ),
                    const SizedBox(height: 10),
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
                    const SizedBox(height: 20),
                    ButtonWidget(
                        child: const TextWidget(
                          text: 'Create Equb',
                          color: Colors.white,
                          type: TextType.small,
                          weight: FontWeight.w500,
                        ),
                        onPressed: () {
                          context.pushNamed(RouteName.equbCreation);
                        }),
                    const SizedBox(height: 10),
                    if (isDescoveryEqubFound == false)
                      Column(
                        children: [
                          const SizedBox(height: 30),
                          SvgPicture.asset(Assets.images.svgs.noEqub),
                          const SizedBox(height: 20),
                          const TextWidget(
                            text: 'Opps, Couldn’t find any Equb',
                            type: TextType.small,
                            weight: FontWeight.w600,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 15),
                          const TextWidget(
                            text:
                                "We couldn't find any Equb groups that your contacts are currently participating in.",
                            fontSize: 12,
                            color: ColorName.grey,
                            weight: FontWeight.w400,
                            textAlign: TextAlign.center,
                          )
                        ],
                      )
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            Assets.images.svgs.discovery,
                            width: 150,
                          ),
                          const SizedBox(height: 20),
                          const TextWidget(
                            text: 'Discover Equb',
                            type: TextType.small,
                            weight: FontWeight.w500,
                          ),
                          const TextWidget(
                            text:
                                'Start exploring Equbs! Find Equbs that your contacts are participating in right here',
                            fontSize: 12,
                            weight: FontWeight.w300,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ButtonWidget(
                              child: const TextWidget(
                                text: 'Start Discovering',
                                color: Colors.white,
                                type: TextType.small,
                                weight: FontWeight.w500,
                              ),
                              onPressed: () {
                                _fetchContacts();
                              }),
                          const SizedBox(height: 10),
                        ],
                      )
                  ],
                ),
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
                    const TextWidget(
                      text: 'Equb',
                      weight: FontWeight.w700,
                    ),
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
              Expanded(
                child: RefreshIndicator(
                  color: ColorName.primaryColor,
                  onRefresh: () async {
                    await Future.delayed(Durations.extralong1);
                    context.read<EqubBloc>().add(FetchAllEqubs());
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Container(
                            padding: const EdgeInsets.only(left: 15),
                            alignment: Alignment.centerLeft,
                            child: const TextWidget(
                              text: 'Your Equb',
                              color: ColorName.grey,
                              type: TextType.small,
                            )),
                        const SizedBox(height: 15),
                        Column(
                          children: [
                            for (var equb in yourEqubs)
                              EqubCard(
                                equb: equb,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Visibility(
                          visible: invitedEqubs.isNotEmpty,
                          child: Container(
                              padding: const EdgeInsets.only(left: 15),
                              alignment: Alignment.centerLeft,
                              child: const TextWidget(
                                text: 'Invitation Equb',
                                color: ColorName.grey,
                                type: TextType.small,
                              )),
                        ),
                        Visibility(
                          visible: invitedEqubs.isNotEmpty,
                          child: const SizedBox(height: 15),
                        ),
                        Column(
                          children: [
                            for (var equb in invitedEqubs)
                              EqubCard(
                                showJoinRequestButton: true,
                                blurTexts: true,
                                equb: equb,
                                onTab: () {
                                  context.goNamed(
                                    RouteName.equbMemberDetail,
                                    extra: equb,
                                  );
                                },
                              ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 15, top: 15),
                          alignment: Alignment.centerLeft,
                          child: const TextWidget(
                            text: 'Other Equb',
                            color: ColorName.grey,
                            type: TextType.small,
                          ),
                        ),
                        EqubCard(
                          showJoinRequestButton: true,
                          blurTexts: true,
                          onTab: () {
                            final detail = EqubDetailModel(
                              isAdmin: false,
                              currency: 'USD',
                              id: -1,
                              name: 'Member Test Another',
                              numberOfMembers: 10,
                              contributionAmount: 250,
                              frequency: 'WEEKLY',
                              startDate: DateTime.now(),
                              members: [],
                              cycles: [],
                              invitees: [
                                EqubInviteeModel(
                                  id: -1,
                                  phoneNumber: '+251910101010',
                                  status: '',
                                  name: 'Abebe Kebede',
                                )
                              ],
                            );
                            context.goNamed(RouteName.equbMemberDetail,
                                extra: detail);
                          },
                          equb: EqubDetailModel(
                            isAdmin: false,
                            currency: 'USD',
                            id: -1,
                            name: 'Member Test Another',
                            numberOfMembers: 10,
                            contributionAmount: 250,
                            frequency: 'WEEKLY',
                            startDate: DateTime.now(),
                            members: [],
                            cycles: [],
                            invitees: [
                              EqubInviteeModel(
                                id: -1,
                                phoneNumber: '+251910101010',
                                status: '',
                                name: 'Abebe Kebede',
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
