import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/equb/equb_bloc.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/core/extensions/int_extensions.dart';
import 'package:transaction_mobile_app/data/models/invitee_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/main.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/components/equb_payment_card.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/components/equb_requests_card.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/components/equb_winners_card.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/dto/complete_page_dto.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/equb_member_tile.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../core/utils/get_user_by_phone_number.dart';
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
  int activeIndex = -1;

  final numberOfMembersController = TextEditingController();
  final searchingController = TextEditingController();

  List<Contact> _contacts = [];
  List<Contact> selectedContacts = [];
  List<Contact> filteredContacts = [];

  bool isPermissionDenied = false;
  bool isSearching = false;
  bool isJoin = false;

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

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTop(),
            _buildReminder(
                'Please select the winner for the second round in August.'),
            const SizedBox(height: 15),
            _buildTitle(),
            const SizedBox(height: 10),
            _buildTabs(),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 15),
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
                              'Created at ${DateTime.now().day.toString().padLeft(2, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().year}',
                          color: Colors.white,
                          fontSize: 10,
                          weight: FontWeight.w400,
                        ),
                      ],
                    ),
                    const Expanded(child: SizedBox()),
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                        ),
                        onPressed: () {
                          // setState(() {
                          //   index = 0;
                          // });
                          context.pushNamed(RouteName.equbEdit);
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
                        ))
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
                        const TextWidget(
                          text: "Admin",
                          fontSize: 14,
                          color: Color(0xfF6D6D6D),
                        ),
                        const Expanded(child: SizedBox()),
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
                          color: const Color(0xfF6D6D6D),
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
                          color: const Color(0xfF6D6D6D),
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
                              '\$${widget.equbDetailModel.contributionAmount}',
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
                              '\$${(widget.equbDetailModel.numberOfMembers * widget.equbDetailModel.contributionAmount).toStringAsFixed(2)}',
                          fontSize: 14,
                          color: const Color(0xfF6D6D6D),
                        ),
                      ],
                    ),
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
    return const Column(
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
    );
  }

  Widget _buildTabs() {
    return Expanded(
      child: Column(
        children: [
          // TabBar to display the tabs
          TabBar(
            controller: _tabController,
            labelColor: ColorName.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: ColorName.primaryColor,
            isScrollable: true,
            tabAlignment: TabAlignment.start,

            // labelPadding: const EdgeInsets.only(right: 15),
            tabs: [
              const Tab(text: 'Members'),
              _buildTabWithNotification("Winners"),
              _buildTabWithNotification("Payment"),
              _buildTabWithNotification("Requests", count: 10),
            ],
          ),
          // TabBarView to handle tab content switching
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
        ],
      ),
    );
  }

  Widget _buildTabWithNotification(String text, {int count = 0}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            Tab(text: text),
            if (count != 0)
              Container(
                margin: const EdgeInsets.only(left: 3),
                padding:
                    const EdgeInsets.symmetric(vertical: 2.5, horizontal: 4),
                decoration: BoxDecoration(
                  color: ColorName.yellow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 10,
                    color: ColorName.white,
                  ),
                ),
              ),
          ],
        ),
        if (count == 0)
          Positioned(
            top: 15,
            right: -10, // You can adjust this based on your design
            child: Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMembersContent() {
    return SingleChildScrollView(
      child: BlocBuilder<EqubBloc, EqubState>(
        builder: (context, state) {
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
                for (var member in state.selectedEqub!.members)
                  FutureBuilder(
                      future: getUserByPhoneNumber(
                        phoneNumber: member.username,
                        contacts: _contacts,
                      ),
                      builder: (context, snapshot) {
                        return EqubMemberTile(
                          onOptionPressed: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (_) => Wrap(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                leading: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Container(
                                                    width: 35,
                                                    height: 35,
                                                    color: ColorName.green,
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                      Icons.person_add,
                                                      color: ColorName.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                                title: const TextWidget(
                                                  text: "Make Co-Admin",
                                                  type: TextType.small,
                                                ),
                                                onTap: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const TextWidget(
                                                        text:
                                                            "Are you sure you want to promote to co-admin?"),
                                                    actions: [
                                                      MaterialButton(
                                                        child: const Text(
                                                            "Cancel"),
                                                        onPressed: () =>
                                                            context.pop(),
                                                      ),
                                                      MaterialButton(
                                                        child: const Text(
                                                            "Promote"),
                                                        onPressed: () =>
                                                            context.pop(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                leading: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Container(
                                                    width: 35,
                                                    height: 35,
                                                    color: ColorName.green,
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                      Icons.person_remove,
                                                      color: ColorName.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                                title: const TextWidget(
                                                  text: "Remove Co-Admin",
                                                  type: TextType.small,
                                                ),
                                                onTap: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const TextWidget(
                                                        text:
                                                            "Are you sure you want to remove this co-admin?"),
                                                    actions: [
                                                      MaterialButton(
                                                        child: const Text(
                                                            "Cancel"),
                                                        onPressed: () =>
                                                            context.pop(),
                                                      ),
                                                      MaterialButton(
                                                        child: const Text(
                                                            "Remove"),
                                                        onPressed: () =>
                                                            context.pop(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              ListTile(
                                                leading: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                  child: Container(
                                                    width: 35,
                                                    height: 35,
                                                    color: ColorName.red,
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                      Icons.close,
                                                      color: ColorName.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                                title: const TextWidget(
                                                  text: "Remove from equb",
                                                  type: TextType.small,
                                                ),
                                                onTap: () => showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                    title: const TextWidget(
                                                        text:
                                                            "Are you sure you want to remove this member?"),
                                                    actions: [
                                                      MaterialButton(
                                                        child: const Text(
                                                            "Cancel"),
                                                        onPressed: () =>
                                                            context.pop(),
                                                      ),
                                                      MaterialButton(
                                                        child: const Text(
                                                            "Remove"),
                                                        onPressed: () =>
                                                            context.pop(),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ));
                          },
                          equbInviteeModel: EqubInviteeModel(
                              id: member.userId,
                              phoneNumber:
                                  snapshot.data?.phoneNumber ?? member.username,
                              status: member.status,
                              name: snapshot.data?.displayName ??
                                  member.username),
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
                        TextButton(
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
                          onPressed: () {
                            //
                          },
                        ),
                      ],
                    ),
                    for (int i = 0;
                        i < (state.selectedEqub?.members ?? []).length;
                        i++)
                      FutureBuilder(
                          future: getUserByPhoneNumber(
                            phoneNumber:
                                state.selectedEqub!.members[i].username,
                            contacts: _contacts,
                          ),
                          builder: (context, snapshot) {
                            return EqubMemberTile(
                              trailingWidget: SizedBox(
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
                                                  color: ColorName.primaryColor,
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
                                id: state.selectedEqub!.members[i].userId,
                                phoneNumber: snapshot.data?.phoneNumber ??
                                    state.selectedEqub!.members[i].username,
                                status: state.selectedEqub!.members[i].status,
                                name: snapshot.data?.displayName ??
                                    state.selectedEqub!.members[i].username,
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
              child: ButtonWidget(
                color: activeIndex != -1
                    ? ColorName.primaryColor
                    : ColorName.grey.shade200.withOpacity(0.5),
                onPressed: () => activeIndex != -1
                    ? context.pushNamed(RouteName.win, extra: [
                        '4th',
                        EqubInviteeModel(
                          id: -1,
                          phoneNumber: '+251910101010',
                          status: '',
                          name: 'Abebe Kebede',
                        ),
                      ])
                    : null,
                child: const TextWidget(
                  text: 'Confirm',
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

  Widget _buildPaymentContent() {
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 10),
              const Row(
                children: [
                  TextWidget(
                    text: 'All Members (10)',
                    fontSize: 16,
                  ),
                  Spacer(),
                  TextWidget(
                    text: 'Paid',
                    fontSize: 13,
                    color: ColorName.green,
                  ),
                  SizedBox(width: 22),
                  TextWidget(
                    text: 'Unpaid',
                    fontSize: 13,
                    color: ColorName.red,
                  ),
                  SizedBox(width: 5),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 9, // Example list item count
                itemBuilder: (context, index) {
                  return EqubPaymentCard(
                    index: index,
                  );
                },
              ),
              const SizedBox(
                height: 75,
              ),
            ],
          ),
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
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => setState(() {
                    isJoin = false;
                  }),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    decoration: BoxDecoration(
                      color: isJoin ? ColorName.white : ColorName.primaryColor,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "Leave Request",
                      style: TextStyle(
                        color:
                            isJoin ? ColorName.primaryColor : ColorName.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 15,
                ),
                GestureDetector(
                  onTap: () => setState(() {
                    isJoin = true;
                  }),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                    decoration: BoxDecoration(
                      color: isJoin ? ColorName.primaryColor : ColorName.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      "Join Request",
                      style: TextStyle(
                        color:
                            isJoin ? ColorName.white : ColorName.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          if (isJoin)
            Column(
              children: [
                const SizedBox(height: 10),
                const Row(
                  children: [
                    TextWidget(
                      text: 'All Requests (10)',
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
                if (members.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: requests.length, // Example list item count
                    itemBuilder: (context, index) {
                      return EqubRequestsCard(
                        index: requests[index],
                        onAccept: (int rerquestId) {
                          setState(() {
                            requests.remove(rerquestId);
                          });
                        },
                      );
                    },
                  ),
                if (members.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Assets.images.equbImage.image(height: 150),
                        const SizedBox(height: 20),
                        const TextWidget(
                          text: 'oops, You don’t have any requests.',
                          type: TextType.small,
                          weight: FontWeight.w500,
                        ),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
          if (!isJoin)
            Column(
              children: [
                const SizedBox(height: 10),
                const Row(
                  children: [
                    TextWidget(
                      text: 'All Members (10)',
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
                if (members.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: members.length, // Example list item count
                    itemBuilder: (context, index) {
                      return EqubRequestsCard(
                        index: members[index],
                        onAccept: (int memberId) {
                          setState(() {
                            members.remove(memberId);
                          });
                        },
                      );
                    },
                  ),
                if (members.isEmpty && isJoin)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Assets.images.equbImage.image(height: 150),
                        const SizedBox(height: 20),
                        const TextWidget(
                          text: 'oops, You don’t have any requests.',
                          type: TextType.small,
                          weight: FontWeight.w500,
                        ),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                if (members.isEmpty && !isJoin)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Assets.images.equbImage.image(height: 150),
                        const SizedBox(height: 20),
                        const TextWidget(
                          text: 'oops, You don’t have any requests.',
                          type: TextType.small,
                          weight: FontWeight.w500,
                        ),
                        const SizedBox(height: 35),
                      ],
                    ),
                  ),
                const SizedBox(
                  height: 15,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
