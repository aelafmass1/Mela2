import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/bloc/equb/equb_bloc.dart';
import 'package:transaction_mobile_app/core/utils/get_member_contact_info.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/equb_detail_model.dart';
import 'package:transaction_mobile_app/data/models/invitee_model.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/equb_member_tile.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';

import '../../../bloc/equb_member/equb_member_bloc.dart';
import '../../../config/routing.dart';
import '../../../core/utils/show_consent.dart';
import '../../../gen/assets.gen.dart';
import '../../../gen/colors.gen.dart';
import '../../widgets/text_widget.dart';

class EqubMemberDetailScreen extends StatefulWidget {
  final EqubDetailModel equbDetailModel;
  const EqubMemberDetailScreen({super.key, required this.equbDetailModel});

  @override
  State<EqubMemberDetailScreen> createState() => _EqubMemberDetailScreenState();
}

class _EqubMemberDetailScreenState extends State<EqubMemberDetailScreen> {
  bool isPending = false;
  bool blurTexts = false;
  List<Contact> _contacts = [];

  int round = -1;

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
    }
  }

  showSucessDialog() {
    showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: ((_) => Dialog(
              child: Container(
                width: 100.sw,
                height: 55.sh,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    20,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    SvgPicture.asset(Assets.images.svgs.completeLogo),
                    const SizedBox(height: 20),
                    const TextWidget(
                      text: 'Request Sent',
                      color: ColorName.primaryColor,
                      fontSize: 24,
                    ),
                    const SizedBox(height: 20),
                    TextWidget(
                      text:
                          'You have successfully sent a request to join “${widget.equbDetailModel.name}”',
                      color: ColorName.grey,
                      textAlign: TextAlign.center,
                      fontSize: 14,
                    ),
                  ],
                ),
              ),
            )));
  }

  @override
  void initState() {
    context.read<EqubBloc>().add(
          FetchEqub(
            equbId: widget.equbDetailModel.id,
          ),
        );
    _fetchContacts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EqubBloc, EqubState>(
      listener: (context, state) {
        if (state is EqubSuccess) {
          if (state.selectedEqub != null) {
            final cycle =
                state.selectedEqub!.cycles.where((c) => c.status == 'CURRENT');
            if (cycle.isNotEmpty) {
              setState(() {
                round = cycle.first.cycleNumber;
              });
            } else {
              setState(() {
                round = 1;
              });
            }
          }
        }
      },
      child: Scaffold(
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
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTop(),
                      _buildMembers(),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: BlocConsumer<EqubMemberBloc, EqubMemberState>(
                  listener: (context, state) async {
                    if (state is SendEqubRequestSuccess) {
                      context.read<EqubBloc>().add(FetchAllEqubs());

                      setState(() {
                        isPending = true;
                      });
                      context.pop();
                      // showSucessDialog();
                    } else if (state is SendEqubRequestFail) {
                      showSnackbar(
                        context,
                        description: state.reason,
                      );
                    }
                  },
                  builder: (context, state) {
                    return ButtonWidget(
                      onPressed: isPending
                          ? null
                          : () async {
                              final agreed = await showConsent(context);
                              if (agreed) {
                                context.read<EqubMemberBloc>().add(
                                      AcceptJoinRequest(
                                        equbId: widget.equbDetailModel.id,
                                      ),
                                    );
                              }
                            },
                      child: state is SendEqubRequestLoading
                          ? const LoadingWidget()
                          : TextWidget(
                              text: isPending ? 'Pending' : 'Accept',
                              type: TextType.small,
                              color: Colors.white,
                            ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
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
                      color: Colors.black,
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
                    blurTexts
                        ? Blur(
                            blur: 10,
                            overlay: Container(
                              color: ColorName.grey[50],
                              height: 50,
                            ),
                            child: TextWidget(
                              text:
                                  '\$${widget.equbDetailModel.contributionAmount}',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          )
                        : TextWidget(
                            text:
                                '\$${widget.equbDetailModel.contributionAmount}',
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
                    blurTexts
                        ? Blur(
                            blur: 10,
                            overlay: Container(
                              color: ColorName.grey[50],
                              height: 50,
                            ),
                            child: TextWidget(
                              text:
                                  '\$${(widget.equbDetailModel.numberOfMembers * widget.equbDetailModel.contributionAmount).toStringAsFixed(2)}',
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          )
                        : TextWidget(
                            text:
                                '\$${(widget.equbDetailModel.numberOfMembers * widget.equbDetailModel.contributionAmount).toStringAsFixed(2)}',
                            fontSize: 14,
                            color: Colors.black,
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

  _buildMembers() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(top: 25, bottom: 20),
          alignment: Alignment.centerLeft,
          child: TextWidget(
            text: 'All Members (${widget.equbDetailModel.members.length})',
          ),
        ),
        for (var member in widget.equbDetailModel.members)
          FutureBuilder(
              future: getMemberContactInfo(
                equbUser: member.user!,
                contacts: _contacts,
              ),
              builder: (context, snapshot) {
                return EqubMemberTile(
                  trailingWidget: const SizedBox.shrink(),
                  equbInviteeModel: EqubInviteeModel(
                      id: member.userId ?? 0,
                      phoneNumber: snapshot.data?.phoneNumber ??
                          member.username ??
                          'PENDING USER',
                      status: member.status,
                      name: snapshot.data?.displayName ??
                          member.username ??
                          'PENDING USER'),
                );
              })
      ],
    );
  }
}
