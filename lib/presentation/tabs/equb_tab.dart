import 'package:flutter/material.dart';
import 'package:transaction_mobile_app/data/models/equb_detail_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';


class EqubTab extends StatefulWidget {
  const EqubTab({super.key});

  @override
  State<EqubTab> createState() => _EqubTabState();
}

class _EqubTabState extends State<EqubTab> {
  List<EqubDetailModel> yourEqubs = [];
  List<EqubDetailModel> invitedEqubs = [];
  List<EqubDetailModel> otherEqubs = [];
  @override
  void initState() {
    // context.read<EqubBloc>().add(FetchAllEqubs());
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
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: TextWidget(text: 'Equb'),
              ),
              const SizedBox(height: 10),
              Assets.images.equbImage.image(
                width: 150,
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
              const SizedBox(height: 35),
              // ButtonWidget(
              //     child: const TextWidget(
              //       text: 'Create Equb',
              //       color: Colors.white,
              //       type: TextType.small,
              //       weight: FontWeight.w500,
              //     ),
              //     onPressed: () {
              //       // context.pushNamed(RouteName.equbCreation);
              //     }),
              // const SizedBox(height: 20),
              // SvgPicture.asset(
              //   Assets.images.svgs.discovery,
              //   width: 150,
              // ),
              // const SizedBox(height: 20),
              // const TextWidget(
              //   text: 'Discover Equb',
              //   type: TextType.small,
              //   weight: FontWeight.w500,
              // ),
              // const SizedBox(height: 10),
              // const TextWidget(
              //   text:
              //       'Start exploring Equbs! Find Equbs that your contacts are participating in right here',
              //   fontSize: 12,
              //   weight: FontWeight.w300,
              //   textAlign: TextAlign.center,
              // ),
              // const Expanded(child: SizedBox()),
              // ButtonWidget(
              //     child: const TextWidget(
              //       text: 'Start Discovering',
              //       color: Colors.white,
              //       type: TextType.small,
              //       weight: FontWeight.w500,
              //     ),
              //     onPressed: () {
              //       //
              //     }),
              // const SizedBox(height: 10),
            ],
          ),
        )
        // body: BlocConsumer<EqubBloc, EqubState>(
        //   listener: (context, state) async {
        //     if (state is EqubFail) {
        //       showSnackbar(
        //         context,
        //         title: 'Error',
        //         description: state.reason,
        //       );
        //     } else if (state is EqubSuccess) {
        //       //
        //     }
        //   },
        //   builder: (context, state) {
        //     if (state is EqubLoading) {
        //       return Column(
        //         children: [
        //           Padding(
        //             padding: const EdgeInsets.symmetric(
        //               horizontal: 15,
        //             ),
        //             child: Row(
        //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //               children: [
        //                 const TextWidget(text: 'Equb'),
        //                 SizedBox(
        //                   width: 110,
        //                   height: 45,
        //                   child: ButtonWidget(
        //                       child: const TextWidget(
        //                         text: 'Create New',
        //                         fontSize: 14,
        //                         color: ColorName.white,
        //                       ),
        //                       onPressed: () {
        //                         context.pushNamed(RouteName.equbCreation);
        //                       }),
        //                 )
        //               ],
        //             ),
        //           ),
        //           const SizedBox(height: 25),
        //           const Expanded(
        //             child: Center(
        //               child: LoadingWidget(
        //                 color: ColorName.primaryColor,
        //               ),
        //             ),
        //           ),
        //         ],
        //       );
        //     }
        //     if (state.equbList.isEmpty) {
        //       return Padding(
        //         padding: const EdgeInsets.symmetric(
        //           horizontal: 20,
        //         ),
        //         child: Column(
        //           children: [
        //             const Align(
        //               alignment: Alignment.centerLeft,
        //               child: TextWidget(text: 'Equb'),
        //             ),
        //             const SizedBox(height: 10),
        //             Assets.images.equbImage.image(
        //               width: 150,
        //             ),
        //             const SizedBox(height: 10),
        //             const TextWidget(
        //               text: 'oops, You don’t have any Equb.',
        //               type: TextType.small,
        //               weight: FontWeight.w500,
        //             ),
        //             const SizedBox(height: 10),
        //             const TextWidget(
        //               text:
        //                   'Please create new Equb or you’ll see your active Equb when someone added you as a member',
        //               fontSize: 12,
        //               weight: FontWeight.w300,
        //               textAlign: TextAlign.center,
        //             ),
        //             const SizedBox(height: 35),
        //             ButtonWidget(
        //                 child: const TextWidget(
        //                   text: 'Create Equb',
        //                   color: Colors.white,
        //                   type: TextType.small,
        //                   weight: FontWeight.w500,
        //                 ),
        //                 onPressed: () {
        //                   context.pushNamed(RouteName.equbCreation);
        //                 }),
        //             const SizedBox(height: 20),
        //             SvgPicture.asset(
        //               Assets.images.svgs.discovery,
        //               width: 150,
        //             ),
        //             const SizedBox(height: 20),
        //             const TextWidget(
        //               text: 'Discover Equb',
        //               type: TextType.small,
        //               weight: FontWeight.w500,
        //             ),
        //             const SizedBox(height: 10),
        //             const TextWidget(
        //               text:
        //                   'Start exploring Equbs! Find Equbs that your contacts are participating in right here',
        //               fontSize: 12,
        //               weight: FontWeight.w300,
        //               textAlign: TextAlign.center,
        //             ),
        //             const Expanded(child: SizedBox()),
        //             ButtonWidget(
        //                 child: const TextWidget(
        //                   text: 'Start Discovering',
        //                   color: Colors.white,
        //                   type: TextType.small,
        //                   weight: FontWeight.w500,
        //                 ),
        //                 onPressed: () {
        //                   //
        //                 }),
        //             const SizedBox(height: 10),
        //           ],
        //         ),
        //       );
        //     }
        //     return Column(
        //       children: [
        //         Padding(
        //           padding: const EdgeInsets.symmetric(
        //             horizontal: 15,
        //           ),
        //           child: Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               const TextWidget(text: 'Equb'),
        //               SizedBox(
        //                 width: 110,
        //                 height: 45,
        //                 child: ButtonWidget(
        //                     child: const TextWidget(
        //                       text: 'Create New',
        //                       fontSize: 14,
        //                       color: ColorName.white,
        //                     ),
        //                     onPressed: () {
        //                       context.pushNamed(RouteName.equbCreation);
        //                     }),
        //               )
        //             ],
        //           ),
        //         ),
        //         Expanded(
        //           child: RefreshIndicator(
        //             color: ColorName.primaryColor,
        //             onRefresh: () async {
        //               await Future.delayed(Durations.extralong1);
        //               context.read<EqubBloc>().add(FetchAllEqubs());
        //             },
        //             child: SingleChildScrollView(
        //               child: Column(
        //                 children: [
        //                   const SizedBox(height: 10),
        //                   Container(
        //                       padding: const EdgeInsets.only(left: 15),
        //                       alignment: Alignment.centerLeft,
        //                       child: const TextWidget(
        //                         text: 'Your Equb',
        //                         color: ColorName.grey,
        //                         type: TextType.small,
        //                       )),
        //                   const SizedBox(height: 15),
        //                   if (state.equbList.length == 1)
        //                     EqubCard(equb: state.equbList.first)
        //                   else
        //                     Column(
        //                       children: [
        //                         for (var equb in state.equbList)
        //                           EqubCard(
        //                             equb: equb,
        //                           ),
        //                       ],
        //                     ),
        //                   Container(
        //                     padding: const EdgeInsets.only(left: 15, top: 15),
        //                     alignment: Alignment.centerLeft,
        //                     child: const TextWidget(
        //                       text: 'Other Equb',
        //                       color: ColorName.grey,
        //                       type: TextType.small,
        //                     ),
        //                   ),
        //                   EqubCard(
        //                     showJoinRequestButton: true,
        //                     onTab: () {
        //                       final detail = EqubDetailModel(
        //                         currency: 'USD',
        //                         id: -1,
        //                         name: 'Member Test Another',
        //                         numberOfMembers: 10,
        //                         contributionAmount: 250,
        //                         frequency: 'WEEKLY',
        //                         startDate: DateTime.now(),
        //                         members: [],
        //                         cycles: [],
        //                         invitees: [
        //                           EqubInviteeModel(
        //                             id: -1,
        //                             phoneNumber: '+251910101010',
        //                             status: '',
        //                             name: 'Abebe Kebede',
        //                           )
        //                         ],
        //                       );
        //                       context.goNamed(RouteName.equbMemberDetail,
        //                           extra: detail);
        //                     },
        //                     equb: EqubDetailModel(
        //                       currency: 'USD',
        //                       id: -1,
        //                       name: 'Member Test Another',
        //                       numberOfMembers: 10,
        //                       contributionAmount: 250,
        //                       frequency: 'WEEKLY',
        //                       startDate: DateTime.now(),
        //                       members: [],
        //                       cycles: [],
        //                       invitees: [
        //                         EqubInviteeModel(
        //                           id: -1,
        //                           phoneNumber: '+251910101010',
        //                           status: '',
        //                           name: 'Abebe Kebede',
        //                         )
        //                       ],
        //                     ),
        //                   ),
        //                 ],
        //               ),
        //             ),
        //           ),
        //         )
        //       ],
        //     );
        //   },
        // ),
        );
  }
}
