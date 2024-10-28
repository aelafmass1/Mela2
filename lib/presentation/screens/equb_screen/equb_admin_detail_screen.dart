import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:transaction_mobile_app/bloc/equb/equb_bloc.dart';
import 'package:transaction_mobile_app/bloc/equb_member/equb_member_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/utils/responsive_util.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/invitee_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/components/equb_cycle_widget.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/components/equb_payment_card.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/dto/complete_page_dto.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/equb_member_shimmer.dart';
import 'package:transaction_mobile_app/presentation/widgets/equb_member_tile.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../core/utils/get_member_bottom_sheet.dart';
import '../../../core/utils/get_member_contact_info.dart';
import '../../../core/utils/show_add_member.dart';
import '../../../data/models/equb_detail_model.dart';

class EqubAdminDetailScreen extends StatefulWidget {
  final EqubDetailModel equbDetailModel;
  const EqubAdminDetailScreen({super.key, required this.equbDetailModel});

  @override
  State<EqubAdminDetailScreen> createState() => _EqubAdminDetailScreenState();
}

class _EqubAdminDetailScreenState extends State<EqubAdminDetailScreen>
    with TickerProviderStateMixin {
  List<int> members = List.generate(10, (index) => index);
  List<int> requests = List.generate(10, (index) => index);

  // Create a TabController to manage the TabBar and TabBarView
  late TabController _tabController;
  late TabController _requestTabController;

  int activeIndex = -1;
  int requestIndex = 0;
  int round = -1;

  final numberOfMembersController = TextEditingController();
  final searchingController = TextEditingController();

  Map<int, int> winnerMembers = {};

  List<Contact> _contacts = [];
  List<Contact> selectedContacts = [];
  List<Contact> filteredContacts = [];

  bool isPermissionDenied = false;

  Future<void> _fetchContacts() async {
    if (await FlutterContacts.requestPermission(readonly: true)) {
      List<Contact> contacts =
          await FlutterContacts.getContacts(withProperties: true);
      setState(() {
        _contacts = contacts;
      });
    } else {
      // ignore: use_build_context_synchronously
      context.pushNamed(RouteName.contactPermission, extra: () {});
      setState(() {
        isPermissionDenied = true;
      });
    }
  }

  int? getFrequencyDay(String frequency) {
    switch (frequency) {
      case 'WEEKLY':
        return 7;
      case 'BIWEEKLY':
        return 15;
      case 'MONTHLY':
        return 30;
      default:
        return null;
    }
  }

  int? getRemainingDate() {
    final startDate = widget.equbDetailModel.startDate;
    final freqencyInDay = getFrequencyDay(widget.equbDetailModel.frequency);
    if (freqencyInDay == null) return null;
    final endDay = startDate.day + freqencyInDay;
    final currentDay = DateTime.now().day;

    return endDay - currentDay;
  }

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
    _requestTabController = TabController(length: 2, vsync: this);

    final equbId = widget.equbDetailModel.id;
    context.read<EqubBloc>().add(
          FetchEqub(
            equbId: equbId,
          ),
        );
    _fetchContacts();
    // context.read<EqubBloc>().add(FetchEqubMembers(equbId: equbId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorName.white,
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 70,
        backgroundColor: ColorName.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            context.pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: ResponsiveBuilder(builder: (context, sizingInfo) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  expandedHeight: ResponsiveUtil.forScreen(
                    sizingInfo: sizingInfo,
                    small: 66.sh,
                    mobile: 447,
                    tablet: 447,
                  ),
                  pinned: true,
                  backgroundColor: ColorName.white,
                  surfaceTintColor: ColorName.white,
                  leading: const SizedBox.shrink(),
                  flexibleSpace: FlexibleSpaceBar(
                    expandedTitleScale: 1,
                    collapseMode: CollapseMode.parallax,
                    titlePadding: EdgeInsets.zero,
                    title: Container(
                      color: Colors.white,
                      child: TabBar(
                        controller: _tabController,
                        labelColor: ColorName.primaryColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: ColorName.primaryColor,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        tabs: [
                          const Tab(text: 'Members'),
                          _buildTabWithNotification("Winners"),
                          _buildTabWithNotification("Payment"),
                          _buildTabWithNotification("Requests", count: 10),
                        ],
                      ),
                    ),
                    background: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTop(),
                        // _buildReminder(
                        //     'Please select the winner for the second round in August.'),
                        const SizedBox(height: 10),
                        _buildTitle(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: _buildTabs(),
          ),
        );
      }),
    );
  }

  _buildReminder(String text) {
    return Container(
      width: 100.sw,
      height: 30,
      decoration: BoxDecoration(
        color: ColorName.yellow,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              size: 15,
            ),
            const SizedBox(width: 5),
            TextWidget(
              text: text,
              fontSize: 12,
            ),
          ],
        ),
      ),
    );
  }

  _buildTop() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: CardWidget(
        width: 100.sw,
        child: Container(
          width: 100.sw,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          // padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 64,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                  color: ColorName.primaryColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4776E6),
                            Color(0xFF8E54E9),
                          ],
                        ),
                      ),
                      child: Center(
                        child: widget.equbDetailModel.name.isNotEmpty
                            ? TextWidget(
                                text: widget.equbDetailModel.name
                                            .trim()
                                            .split(' ')
                                            .length ==
                                        1
                                    ? widget.equbDetailModel.name
                                        .split('')
                                        .first
                                        .trim()
                                    : '${widget.equbDetailModel.name.trim().split(' ').first[0]}${widget.equbDetailModel.name.trim().split(' ').last[0]}',
                                color: Colors.white,
                                fontSize: 14,
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextWidget(
                          text: widget.equbDetailModel.name,
                          color: Colors.white,
                        ),
                        TextWidget(
                          text:
                              'Created at ${DateFormat('dd-MM-yyyy').format(widget.equbDetailModel.startDate)}',
                          color: Colors.white,
                          fontSize: 10,
                          weight: FontWeight.w400,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 3,
                          color: Colors.white,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextWidget(
                            text: round == -1
                                ? '--'
                                : round.toString().padLeft(2, '0'),
                            color: Colors.white,
                            fontSize: 13,
                          ),
                          const TextWidget(
                            text: 'Rounds',
                            color: Colors.white,
                            fontSize: 6,
                            weight: FontWeight.w200,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(Assets.images.svgs.adminIcon),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 45.sw,
                          child: TextWidget(
                            text:
                                "Admin: ${widget.equbDetailModel.createdBy.firstName} ${widget.equbDetailModel.createdBy.lastName}",
                            fontSize: 14,
                            color: const Color(0xfF6D6D6D),
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.groups_outlined,
                          color: Color(0xfF6D6D6D),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        TextWidget(
                          text:
                              'Members : ${widget.equbDetailModel.members.length}',
                          fontSize: 14,
                          color: const Color(0xfF6D6D6D),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Assets.images.svgs.endTimeIcon,
                          color: const Color(0xfF6D6D6D),
                        ),
                        const SizedBox(width: 10),
                        const TextWidget(
                          text: 'Start Date',
                          fontSize: 14,
                          color: Color(0xfF6D6D6D),
                        ),
                        const Expanded(child: SizedBox()),
                        TextWidget(
                          text:
                              '${widget.equbDetailModel.startDate.day.toString().padLeft(2, '0')}-${widget.equbDetailModel.startDate.month.toString().padLeft(2, '0')}-${widget.equbDetailModel.startDate.year}',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Assets.images.svgs.frequencyIcon,
                          color: const Color(0xfF6D6D6D),
                        ),
                        const SizedBox(width: 10),
                        const TextWidget(
                          text: 'Frequency',
                          fontSize: 14,
                          color: Color(0xfF6D6D6D),
                        ),
                        const Expanded(child: SizedBox()),
                        TextWidget(
                          text: widget.equbDetailModel.frequency,
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Assets.images.svgs.equbIcon,
                          color: const Color(0xfF6D6D6D),
                          width: 14,
                          height: 14,
                        ),
                        const SizedBox(width: 10),
                        const TextWidget(
                          text: 'Contribution amount',
                          fontSize: 14,
                          color: Color(0xfF6D6D6D),
                        ),
                        const Expanded(child: SizedBox()),
                        TextWidget(
                          text:
                              '${widget.equbDetailModel.contributionAmount} ${widget.equbDetailModel.currency}',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Assets.images.svgs.amountIcon,
                          color: const Color(0xfF6D6D6D),
                        ),
                        const SizedBox(width: 10),
                        const TextWidget(
                          text: 'Total amount',
                          fontSize: 14,
                          color: Color(0xfF6D6D6D),
                        ),
                        const Expanded(child: SizedBox()),
                        TextWidget(
                          text:
                              '${(widget.equbDetailModel.numberOfMembers * widget.equbDetailModel.contributionAmount).toStringAsFixed(2)} ${widget.equbDetailModel.currency}',
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if ((getRemainingDate() ?? 0) <= 0)
                          SizedBox(
                            width: 83,
                            height: 30,
                            child: ButtonWidget(
                                color: ColorName.yellow,
                                horizontalPadding: 5,
                                verticalPadding: 0,
                                child: const TextWidget(
                                  text: 'Make Payment',
                                  type: TextType.small,
                                  fontSize: 10,
                                  color: Colors.white,
                                ),
                                onPressed: () {}),
                          )
                        else
                          SizedBox(
                            width: 35,
                            height: 35,
                            child: SimpleCircularProgressBar(
                              valueNotifier: ValueNotifier(
                                  (getRemainingDate() ?? 0).toDouble()),
                              progressStrokeWidth: 5,
                              backStrokeWidth: 5,
                              maxValue: (getFrequencyDay(
                                          widget.equbDetailModel.frequency) ??
                                      0)
                                  .toDouble(),
                              animationDuration: 3,
                              mergeMode: true,
                              onGetText: (value) {
                                return Text(
                                  '${value.toInt()}\n${((getRemainingDate() ?? 0) == 1 || (getRemainingDate() ?? 0) == 0) ? 'Day' : 'Days'}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleSmall!
                                      .copyWith(
                                        fontSize: 9,
                                      ),
                                );
                              },
                              progressColors: [
                                ((getRemainingDate() ?? 0) <= 3)
                                    ? ColorName.red
                                    : ColorName.primaryColor,
                              ],
                              backColor: Colors.black.withOpacity(0.2),
                            ),
                          ),
                        ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                            ),
                            onPressed: () {
                              // setState(() {
                              //   index = 0;
                              // });
                              context.pushNamed(
                                RouteName.equbEdit,
                                extra: widget.equbDetailModel,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const TextWidget(
                                  text: 'Edit',
                                  fontSize: 12,
                                  color: ColorName.primaryColor,
                                ),
                                const SizedBox(width: 3),
                                SvgPicture.asset(
                                  Assets.images.svgs.editIcon,
                                ),
                              ],
                            )),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  _buildTitle() {
    return SizedBox(
      height: 80,
      width: 100.sw,
      child: const Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextWidget(
              text: "Equb Group Settings",
              fontSize: 24,
              weight: FontWeight.w700,
            ),
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: TextWidget(
                text: "Please review your Equb details carefully.",
                weight: FontWeight.w400,
                fontSize: 14,
                color: Color(0xFF6D6D6D),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMembersContent(), // Tab 1 content
              _buildWinnersContent(), // Tab 2 content
              _buildPaymentContent(), // Tab 3 content
              _buildRequestsContent(), // Tab 4 content
            ],
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTabWithNotification(String text, {int count = 0}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            Tab(text: text),
            // if (count != 0)
            //   Container(
            //     margin: const EdgeInsets.only(left: 3),
            //     padding:
            //         const EdgeInsets.symmetric(vertical: 2.5, horizontal: 4),
            //     decoration: BoxDecoration(
            //       color: ColorName.yellow,
            //       borderRadius: BorderRadius.circular(10),
            //     ),
            //     child: Text(
            //       count.toString(),
            //       style: const TextStyle(
            //         fontSize: 10,
            //         color: ColorName.white,
            //       ),
            //     ),
            //   ),
          ],
        ),
        // if (count == 0)
        //   Positioned(
        //     top: 15,
        //     right: -10, // You can adjust this based on your design
        //     child: Container(
        //       width: 5,
        //       height: 5,
        //       decoration: const BoxDecoration(
        //         color: Colors.red,
        //         shape: BoxShape.circle,
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _buildMembersContent() {
    return SingleChildScrollView(
      child: BlocConsumer<EqubBloc, EqubState>(
        listener: (context, state) {
          if (state is EqubSuccess) {
            if (state.selectedEqub != null) {
              final cycle = state.selectedEqub!.cycles
                  .where((c) => c.status == 'CURRENT');
              if (cycle.isNotEmpty) {
                setState(() {
                  round = cycle.first.cycleNumber;
                });
              } else {
                setState(() {
                  round = 1;
                });
              }
              if (state.selectedEqub?.cycles.isNotEmpty == true) {
                // state.selectedEqub!.cycles.sort((a, b) => a.cycleNumber.compareTo(b.cycleNumber));

                final winnerCycles = state.selectedEqub!.cycles
                    .where((c) => c.winner != null)
                    .toList();

                for (var cycle in winnerCycles) {
                  if (cycle.winner != null) {
                    winnerMembers[cycle.winner?.user?.phoneNumber ?? 0] =
                        cycle.cycleNumber;
                  }
                }
                setState(() {
                  winnerMembers = winnerMembers;
                });
              }
            }
          }
        },
        builder: (context, state) {
          if (state is EqubLoading) {
            return Column(
              children: [
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TextWidget(
                      text: 'All Members (--)',
                      fontSize: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 0)),
                      onPressed: null,
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: ColorName.primaryColor,
                          ),
                          SizedBox(width: 3),
                          TextWidget(
                            text: 'Add Member',
                            fontSize: 13,
                            color: ColorName.primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                const EqubMemberShimmer(),
                const EqubMemberShimmer(),
                const EqubMemberShimmer(),
                const EqubMemberShimmer(),
              ],
            );
          }
          if (state is EqubSuccess && state.selectedEqub != null) {
            return Column(
              children: [
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextWidget(
                      text:
                          'All Members (${state.selectedEqub!.members.length})',
                      fontSize: 16,
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 0)),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: ColorName.primaryColor,
                          ),
                          SizedBox(width: 3),
                          TextWidget(
                            text: 'Add Member',
                            fontSize: 13,
                            color: ColorName.primaryColor,
                          ),
                        ],
                      ),
                      onPressed: () async {
                        await _fetchContacts();

                        if (isPermissionDenied == false) {
                          showAddMember(
                            // ignore: use_build_context_synchronously
                            context,
                            int.tryParse(numberOfMembersController.text) ?? 3,
                            _contacts,
                            widget.equbDetailModel.id,
                          );
                        }
                      },
                    ),
                  ],
                ),
                if (state.selectedEqub?.members.isEmpty == true)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: TextWidget(
                      text: 'No Member Found',
                      type: TextType.small,
                      weight: FontWeight.w300,
                    ),
                  )
                else
                  for (var member in state.selectedEqub!.members)
                    FutureBuilder(
                        future: getMemberContactInfo(
                          equbUser: member.user!,
                          contacts: _contacts,
                        ),
                        builder: (context, snapshot) {
                          return EqubMemberTile(
                            onOptionPressed: () {
                              showDetailBottomSheet(context);
                            },
                            equbInviteeModel: EqubInviteeModel(
                              id: member.userId ?? 0,
                              phoneNumber: snapshot.data?.phoneNumber ??
                                  member.username ??
                                  'PENDING USER',
                              status: member.status,
                              name: snapshot.data?.displayName ??
                                  member.username ??
                                  'PENDING USER',
                            ),
                          );
                        })
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildWinnersContent() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: BlocBuilder<EqubBloc, EqubState>(
            builder: (context, state) {
              if (state is EqubLoading) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const TextWidget(
                          text: 'All Members (--)',
                          fontSize: 16,
                        ),
                        TextButton(
                          onPressed: null,
                          child: Row(
                            children: [
                              SvgPicture.asset(Assets.images.svgs.spinWheel),
                              const SizedBox(width: 5),
                              const TextWidget(
                                text: 'Auto Pick',
                                fontSize: 13,
                                color: ColorName.green,
                              ),
                            ],
                          ),
                        ),
                        const EqubMemberShimmer(),
                        const EqubMemberShimmer(),
                        const EqubMemberShimmer(),
                        const EqubMemberShimmer(),
                      ],
                    ),
                  ],
                );
              }
              if (state is EqubSuccess && state.selectedEqub != null) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextWidget(
                          text:
                              'All Members (${state.selectedEqub?.members.length ?? 0})',
                          fontSize: 16,
                        ),
                        BlocBuilder<EqubMemberBloc, EqubMemberState>(
                          builder: (context, equbMemberState) {
                            return TextButton(
                              onPressed: () {
                                if (state.selectedEqub!.members.isNotEmpty) {
                                  context.read<EqubMemberBloc>().add(
                                        EqubAutoPickWinner(
                                          cycleId: state.selectedEqub!.cycles
                                              .first.cycleId,
                                        ),
                                      );
                                }
                              },
                              child: equbMemberState is EqubAutoWinnerLoading
                                  ? const LoadingWidget(
                                      color: ColorName.primaryColor,
                                    )
                                  : Row(
                                      children: [
                                        SvgPicture.asset(
                                            Assets.images.svgs.spinWheel),
                                        const SizedBox(width: 5),
                                        const TextWidget(
                                          text: 'Auto Pick',
                                          fontSize: 13,
                                          color: ColorName.green,
                                        ),
                                      ],
                                    ),
                            );
                          },
                        ),
                      ],
                    ),
                    if (state.selectedEqub?.members.isEmpty == true)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: TextWidget(
                          text: 'No Member Found',
                          type: TextType.small,
                          weight: FontWeight.w300,
                        ),
                      )
                    else
                      for (int i = 0;
                          i < (state.selectedEqub?.members ?? []).length;
                          i++)
                        FutureBuilder(
                            future: getMemberContactInfo(
                              equbUser: state.selectedEqub!.members[i].user!,
                              contacts: _contacts,
                            ),
                            builder: (context, snapshot) {
                              return EqubMemberTile(
                                trailingWidget: winnerMembers.containsKey(state
                                        .selectedEqub
                                        ?.members[i]
                                        .user
                                        ?.phoneNumber)
                                    ? Container(
                                        height: 30,
                                        width: 100,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: ColorName.grey,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(30),
                                        ),
                                        child: TextWidget(
                                          text:
                                              ' Round ${winnerMembers[state.selectedEqub!.members[i].user?.phoneNumber]} winner',
                                          fontSize: 11,
                                          color: ColorName.grey,
                                        ),
                                      )
                                    : SizedBox(
                                        width: 70,
                                        height: 35,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                              backgroundColor: activeIndex == i
                                                  ? ColorName.primaryColor
                                                  : ColorName.white,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(30),
                                                  side: activeIndex == i
                                                      ? BorderSide.none
                                                      : const BorderSide(
                                                          color: ColorName
                                                              .primaryColor,
                                                          width: 1,
                                                        )),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                activeIndex = i;
                                              });
                                            },
                                            child: TextWidget(
                                              text: activeIndex == i
                                                  ? 'Selected'
                                                  : 'Select',
                                              color: activeIndex == i
                                                  ? ColorName.white
                                                  : ColorName.primaryColor,
                                              fontSize: 12,
                                            )),
                                      ),
                                equbInviteeModel: EqubInviteeModel(
                                  id: state.selectedEqub!.members[i].userId ??
                                      0,
                                  phoneNumber: snapshot.data?.phoneNumber ??
                                      state.selectedEqub!.members[i].username ??
                                      'PENDING USER',
                                  status: state.selectedEqub!.members[i].status,
                                  name: snapshot.data?.displayName ??
                                      state.selectedEqub!.members[i].username ??
                                      'PENDING USER',
                                ),
                              );
                            }),

                    // ListView.builder(
                    //   shrinkWrap: true,
                    //   physics: const NeverScrollableScrollPhysics(),
                    //   itemCount: 9, // Example list item count
                    //   itemBuilder: (context, index) {
                    //     return GestureDetector(
                    //       onTap: () {
                    //         setState(() {
                    //           debugPrint("Selected index - $index");
                    //           activeIndex = index;
                    //         });
                    //       },
                    //       child: EqubWinnersCard(
                    //         index: index,
                    //         isActive: index == activeIndex,
                    //       ),
                    //     );
                    //   },
                    // ),
                    const SizedBox(
                      height: 75,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        Positioned(
          bottom: 0,
          child: Container(
            color: activeIndex != -1 ? ColorName.white : null,
            child: SizedBox(
              width: 100.sw - 30,
              child: BlocBuilder<EqubBloc, EqubState>(
                builder: (context, state) {
                  return BlocConsumer<EqubMemberBloc, EqubMemberState>(
                    listener: (context, equbMemberState) {
                      if (equbMemberState is EqubManualWinnerFail) {
                        showSnackbar(context,
                            description: equbMemberState.reason);
                      } else if (equbMemberState is EqubManualWinnerSuccess) {
                        context.pushNamed(RouteName.win, extra: [
                          '${equbMemberState.cycleNumber}',
                          EqubInviteeModel(
                            id: -1,
                            phoneNumber: equbMemberState.phoneNumber,
                            status: equbMemberState.role ?? '',
                            name:
                                '${equbMemberState.firstName} ${equbMemberState.lastName}',
                          ),
                        ]);
                      } else if (equbMemberState is EqubAutoWinnerFail) {
                        showSnackbar(context,
                            description: equbMemberState.reason);
                      } else if (equbMemberState is EqubAutoWinnerSuccess) {
                        context.pushNamed(RouteName.win, extra: [
                          '${equbMemberState.cycleNumber}',
                          EqubInviteeModel(
                            id: -1,
                            phoneNumber: equbMemberState.phoneNumber,
                            status: equbMemberState.role ?? '',
                            name:
                                '${equbMemberState.firstName} ${equbMemberState.lastName}',
                          ),
                        ]);
                      }
                    },
                    builder: (context, equbMemberState) {
                      return ButtonWidget(
                        color: activeIndex != -1
                            ? ColorName.primaryColor
                            : ColorName.grey.shade200.withOpacity(0.5),
                        onPressed: activeIndex != -1
                            ? () {
                                if (state is EqubSuccess &&
                                    state.selectedEqub != null) {
                                  log(state.selectedEqub!.members[activeIndex]
                                          .username ??
                                      '');
                                  final cycle = state.selectedEqub!.cycles
                                      .where((c) => c.status == 'CURRENT');
                                  int cycleId = 0;
                                  if (cycle.isNotEmpty) {
                                    cycleId = cycle.first.cycleId;
                                  } else {
                                    cycleId = state.selectedEqub!.cycles
                                        .where((c) => c.cycleNumber == 1)
                                        .first
                                        .cycleId;
                                  }
                                  final memberId = state
                                      .selectedEqub!.members[activeIndex].id;

                                  context.read<EqubMemberBloc>().add(
                                        EqubAssignWinner(
                                          cycleId: cycleId,
                                          memberId: memberId,
                                        ),
                                      );
                                }
                              }
                            : null,
                        child: equbMemberState is EqubManualWinnerLoading
                            ? const LoadingWidget()
                            : const TextWidget(
                                text: 'Confirm',
                                type: TextType.small,
                                color: Colors.white,
                              ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildPaymentContent() {
    return Stack(
      children: [
        BlocBuilder<EqubBloc, EqubState>(
          builder: (context, state) {
            if (state is EqubSuccess && state.selectedEqub != null) {
              return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    if (state.selectedEqub?.cycles.isNotEmpty == true)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 42,
                            width: 100.sw,
                            child: SingleChildScrollView(
                              padding: EdgeInsets.zero,
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  for (var cycle in state.selectedEqub!.cycles)
                                    EqubCycleWidget(
                                      equbCycleModel: cycle,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Divider(
                            color: ColorName.grey[50],
                          ),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        TextWidget(
                          text:
                              'All Members (${state.selectedEqub?.members.length})',
                          fontSize: 16,
                        ),
                        const Spacer(),
                        const TextWidget(
                          text: 'Paid',
                          fontSize: 13,
                          color: ColorName.green,
                        ),
                        const SizedBox(width: 13),
                        const TextWidget(
                          text: 'Unpaid',
                          fontSize: 13,
                          color: ColorName.red,
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),
                    if (state.selectedEqub?.members.isEmpty == true)
                      const Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: TextWidget(
                          text: 'No Member Found',
                          type: TextType.small,
                          weight: FontWeight.w300,
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (state.selectedEqub?.members.length ??
                            0), // Example list item count
                        itemBuilder: (context, index) {
                          return FutureBuilder(
                              future: getMemberContactInfo(
                                equbUser:
                                    state.selectedEqub!.members[index].user!,
                                contacts: _contacts,
                              ),
                              builder: (context, snapshot) {
                                return EqubPaymentCard(
                                  equbInviteeModel: EqubInviteeModel(
                                    id: state.selectedEqub!.members[index]
                                            .userId ??
                                        0,
                                    phoneNumber: snapshot.data?.phoneNumber ??
                                        state.selectedEqub!.members[index]
                                            .username ??
                                        'PENDING USER',
                                    status: state
                                        .selectedEqub!.members[index].status,
                                    name: snapshot.data?.displayName ??
                                        state.selectedEqub!.members[index]
                                            .username ??
                                        'PENDING USER',
                                  ),
                                  index: index,
                                );
                              });
                        },
                      ),
                    const SizedBox(
                      height: 75,
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        Positioned(
          bottom: 0,
          child: Container(
            color: ColorName.white,
            child: SizedBox(
              width: 100.sw - 30,
              child: ButtonWidget(
                onPressed: () => context.pushNamed(
                  RouteName.equbActionCompleted,
                  extra: CompletePageDto(
                    title: "Reminder sent!",
                    description:
                        "You have successfully sent a reminder to all members!",
                    onComplete: () => context.pop(),
                  ),
                ),
                child: const TextWidget(
                  text: 'Send Reminder To All',
                  type: TextType.small,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRequestsContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          ColoredBox(
            color: const Color(0xFFF6F6F6),
            child: TabBar(
              padding: EdgeInsets.zero,
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              tabs: [
                Tab(
                  child: TextWidget(
                    text: 'Join Requests',
                    fontSize: 14,
                    color: requestIndex == 0 ? ColorName.primaryColor : null,
                  ),
                ),
                Tab(
                  child: TextWidget(
                    text: 'Leave Requests',
                    fontSize: 14,
                    color: requestIndex == 1 ? ColorName.primaryColor : null,
                  ),
                ),
              ],
              controller: _requestTabController,
              onTap: (value) {
                setState(() {
                  requestIndex = value;
                });
              },
            ),
          ),
          if (requestIndex == 0)
            const Column(
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    TextWidget(
                      text: 'All Members (0)',
                      fontSize: 16,
                    ),
                    Spacer(),
                    TextWidget(
                      text: 'Accept',
                      fontSize: 13,
                      color: ColorName.green,
                    ),
                    SizedBox(width: 16),
                    TextWidget(
                      text: 'Reject',
                      fontSize: 13,
                      color: ColorName.red,
                    ),
                    SizedBox(width: 5),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            )
          else
            const Column(
              children: [
                SizedBox(height: 10),
                Row(
                  children: [
                    TextWidget(
                      text: 'All Members (0)',
                      fontSize: 16,
                    ),
                    Spacer(),
                    TextWidget(
                      text: 'Accept',
                      fontSize: 13,
                      color: ColorName.green,
                    ),
                    SizedBox(width: 16),
                    TextWidget(
                      text: 'Reject',
                      fontSize: 13,
                      color: ColorName.red,
                    ),
                    SizedBox(width: 5),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
