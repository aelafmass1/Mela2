import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/presentation/widgets/equb_member_tile.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../bloc/equb/equb_bloc.dart';

class SendInvitationScreen extends StatefulWidget {
  const SendInvitationScreen({super.key});

  @override
  State<SendInvitationScreen> createState() => _SendInvitationScreenState();
}

class _SendInvitationScreenState extends State<SendInvitationScreen> {
  List invitedMembers = [];
  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        context.read<EqubBloc>().add(FetchAllEqubs());
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 80,
          title: const TextWidget(
            text: 'Send Invitation',
          ),
          leading: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.close),
          ),
        ),
        body: BlocBuilder<EqubBloc, EqubState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 15,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 85.sw,
                        child: const TextWidget(
                          text:
                              'Unable to find the following users. Please send them an invitation to join the Equb.',
                          weight: FontWeight.w300,
                          type: TextType.small,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (state is EqubSuccess && state.invitees != null)
                            for (var invitee in state.invitees!)
                              EqubMemberTile(
                                equbInviteeModel: invitee.copyWith(
                                  status: invitedMembers
                                          .contains(invitee.phoneNumber)
                                      ? 'Pending'
                                      : null,
                                ),
                                onSuccessInvite: () {
                                  invitedMembers.add(invitee.phoneNumber);
                                  setState(() {
                                    invitedMembers = invitedMembers;
                                  });
                                },
                              ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
