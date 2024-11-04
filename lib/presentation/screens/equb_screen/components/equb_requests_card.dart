import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/bloc/equb_member/equb_member_bloc.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/equb_request_model.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class EqubRequestsCard extends StatefulWidget {
  final EqubRequestModel equbRequestModel;
  final Function() onSuccess;

  const EqubRequestsCard({
    required this.equbRequestModel,
    required this.onSuccess,
    super.key,
  });

  @override
  State<EqubRequestsCard> createState() => _EqubRequestsCardState();
}

class _EqubRequestsCardState extends State<EqubRequestsCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: 50,
              height: 50,
              color: ColorName.primaryColor,
              alignment: Alignment.center,
              child: TextWidget(
                text: widget.equbRequestModel.user.firstName != null &&
                        widget.equbRequestModel.user.firstName?.isNotEmpty ==
                            true
                    ? widget.equbRequestModel.user.firstName![0] ?? ''
                    : '',
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextWidget(
                  text:
                      "${widget.equbRequestModel.user.firstName} ${widget.equbRequestModel.user.lastName}",
                  fontSize: 16,
                  weight: FontWeight.w400,
                ),
                const SizedBox(
                  height: 5,
                ),
                TextWidget(
                  text: widget.equbRequestModel.user.countryCode == null
                      ? widget.equbRequestModel.status
                      : '+${widget.equbRequestModel.user.countryCode}${widget.equbRequestModel.user.phoneNumber}',
                  type: TextType.small,
                  fontSize: 14,
                  weight: FontWeight.w300,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          BlocConsumer<EqubMemberBloc, EqubMemberState>(
            listener: (context, state) {
              if (state is ApproveJoinRequestFail) {
                showSnackbar(
                  context,
                  description: state.reason,
                );
              } else if (state is ApproveJoinRequestSuccess) {
                showSnackbar(
                  context,
                  description:
                      'Join request approved and user added as member.',
                );
                widget.onSuccess();
              }
            },
            builder: (context, state) {
              if (state is ApproveJoinRequestLoading) {
                return const LoadingWidget(
                  size: 20,
                  color: ColorName.green,
                );
              }
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  context.read<EqubMemberBloc>().add(
                        ApproveJoinRequest(
                          requestId: widget.equbRequestModel.id,
                        ),
                      );
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorName.green,
                      width: 2.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.check, // Empty circle when unchecked
                    color: ColorName.green,
                    size: 15,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 35),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              //
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: ColorName.red,
                  width: 2.0,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close, // "X" icon for reject
                color: ColorName.red,
                size: 15,
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
