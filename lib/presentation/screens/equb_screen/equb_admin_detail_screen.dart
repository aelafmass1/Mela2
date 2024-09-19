import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/config/routing.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/components/equb_member_card.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/components/equb_payment_card.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/components/equb_requests_card.dart';
import 'package:transaction_mobile_app/presentation/screens/equb_screen/components/equb_winners_card.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../data/models/equb_detail_model.dart';

class EqubAdminDetailScreen extends StatefulWidget {
  final EqubDetailModel equbDetailModel;
  const EqubAdminDetailScreen({super.key, required this.equbDetailModel});

  @override
  State<EqubAdminDetailScreen> createState() => _EqubAdminDetailScreenState();
}

class _EqubAdminDetailScreenState extends State<EqubAdminDetailScreen>
    with TickerProviderStateMixin {
  // Create a TabController to manage the TabBar and TabBarView
  late TabController _tabController;
  int activeIndex = -1;

  @override
  void initState() {
    _tabController = TabController(length: 4, vsync: this);
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
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTop(),
                  const SizedBox(height: 20),
                  _buildTitle(),
                  const SizedBox(height: 10),
                  _buildTabs(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildTop() {
    return Container(
      width: 100.sw,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                      text: '\$${widget.equbDetailModel.contributionAmount}',
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
    );
  }

  _buildReviewTop(BuildContext context) {
    return Container(
      width: 100.sw,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
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
                  child: const Center(
                    child: true
                        ? TextWidget(
                            text: "AB",
                            color: Colors.white,
                            fontSize: 14,
                          )
                        : SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TextWidget(
                      text: "Name",
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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
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
                    const TextWidget(
                      text: 'Members : 10',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
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
                    const TextWidget(
                      text: '7-7-7',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
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
                    const TextWidget(
                      text: 'Monthly',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
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
                    const TextWidget(
                      text: '\$10',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
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
                    const TextWidget(
                      text: '7',
                      fontSize: 14,
                      color: Color(0xfF6D6D6D),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
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
            tabs: const [
              Tab(text: 'Members'),
              Tab(text: 'Winners'),
              Tab(text: 'Payment'),
              Tab(text: 'Requests'),
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

  Widget _buildMembersContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TextWidget(
                  text: 'All Members (10)',
                  fontSize: 16,
                ),
                TextButton(
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
                    onPressed: () {
                      // setState(() {
                      //   index = 1;
                      //   sliderWidth = 60.sw;
                      // });
                    })
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9, // Example list item count
              itemBuilder: (context, index) {
                return EqubMemberCard(
                  index: index + 1, // Example widget for each list item
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnersContent() {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const TextWidget(
                      text: 'All Members (10)',
                      fontSize: 16,
                    ),
                    TextButton(
                        child: const Row(
                          children: [
                            Icon(
                              Icons.gamepad_outlined,
                              size: 20,
                              color: ColorName.green,
                            ),
                            SizedBox(width: 5),
                            TextWidget(
                              text: 'Auto Pick',
                              fontSize: 13,
                              color: ColorName.green,
                            ),
                          ],
                        ),
                        onPressed: () {
                          // setState(() {
                          //   index = 1;
                          //   sliderWidth = 60.sw;
                          // });
                        })
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 9, // Example list item count
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          debugPrint("Selected index - $index");
                          activeIndex = index;
                        });
                      },
                      child: EqubWinnersCard(
                        index: index,
                        isActive: index == activeIndex,
                      ),
                    );
                  },
                ),
                const SizedBox(
                  height: 75,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          child: SizedBox(
            width: 89.sw,
            child: ButtonWidget(
              color: activeIndex != -1
                  ? ColorName.primaryColor
                  : ColorName.grey.shade200,
              onPressed: () {},
              child: const TextWidget(
                text: 'Confirm',
                type: TextType.small,
                color: Colors.white,
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  children: [
                    const TextWidget(
                      text: 'All Members (10)',
                      fontSize: 16,
                    ),
                    const Spacer(),
                    TextButton(
                      child: const TextWidget(
                        text: 'Paid',
                        fontSize: 13,
                        color: ColorName.green,
                      ),
                      onPressed: () {
                        // setState(() {
                        //   index = 1;
                        //   sliderWidth = 60.sw;
                        // });
                      },
                    ),
                    TextButton(
                      child: const TextWidget(
                        text: 'Unpaid',
                        fontSize: 13,
                        color: ColorName.red,
                      ),
                      onPressed: () {
                        // setState(() {
                        //   index = 1;
                        //   sliderWidth = 60.sw;
                        // });
                      },
                    )
                  ],
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 9, // Example list item count
                  itemBuilder: (context, index) {
                    return const EqubPaymentCard();
                  },
                ),
                const SizedBox(
                  height: 75,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          child: SizedBox(
            width: 89.sw,
            child: ButtonWidget(
              onPressed: () {},
              child: const TextWidget(
                text: 'Send Reminder To All',
                type: TextType.small,
                color: Colors.white,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildRequestsContent() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                const TextWidget(
                  text: 'All Members (10)',
                  fontSize: 16,
                ),
                const Spacer(),
                TextButton(
                  child: const TextWidget(
                    text: 'Accept',
                    fontSize: 13,
                    color: ColorName.green,
                  ),
                  onPressed: () {
                    // setState(() {
                    //   index = 1;
                    //   sliderWidth = 60.sw;
                    // });
                  },
                ),
                TextButton(
                  child: const TextWidget(
                    text: 'Reject',
                    fontSize: 13,
                    color: ColorName.red,
                  ),
                  onPressed: () {
                    // setState(() {
                    //   index = 1;
                    //   sliderWidth = 60.sw;
                    // });
                  },
                )
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9, // Example list item count
              itemBuilder: (context, index) {
                return const EqubRequestsCard();
              },
            ),
            const SizedBox(
              height: 75,
            ),
          ],
        ),
      ),
    );
  }
}
