import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transaction_mobile_app/core/extensions/int_extensions.dart';
import 'package:transaction_mobile_app/core/utils/show_snackbar.dart';
import 'package:transaction_mobile_app/data/models/equb_member_model.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/loading_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

import '../../../../bloc/equb_member/equb_member_bloc.dart';

class EqubPaymentTile extends StatefulWidget {
  final EqubMemberModel equbMemberModel;
  final int cycleId;
  final bool isActive;
  const EqubPaymentTile({
    required this.equbMemberModel,
    required this.cycleId,
    required this.isActive,
    super.key,
  });

  @override
  State<EqubPaymentTile> createState() => _EqubPaymentTileState();
}

class _EqubPaymentTileState extends State<EqubPaymentTile> {
  bool isActive = false;
  bool isReminderClicked = false;

  @override
  void initState() {
    setState(() {
      isActive = widget.isActive;
    });
    super.initState();
  }

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
              child: const TextWidget(
                text: "",
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
                      widget.equbMemberModel.user?.firstName ?? 'PENDING USER',
                  fontSize: 16,
                  weight: FontWeight.w400,
                ),
                const SizedBox(
                  height: 5,
                ),
                TextWidget(
                  text:
                      '+${widget.equbMemberModel.user?.countryCode}${widget.equbMemberModel.user?.phoneNumber}',
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
          if (!isActive)
            BlocConsumer<EqubMemberBloc, EqubMemberState>(
              listener: (context, state) {
                if (state is EqubReminderFail && isReminderClicked) {
                  showSnackbar(
                    context,
                    description: state.reason,
                  );
                  setState(() {
                    isReminderClicked = false;
                  });
                } else if (state is EqubReminderSuccess && isReminderClicked) {
                  showSnackbar(
                    context,
                    description: 'Reminder Sent',
                  );
                  setState(() {
                    isReminderClicked = false;
                  });
                }
              },
              builder: (context, state) {
                if (state is EqubReminderLoading && isReminderClicked) {
                  return const LoadingWidget(
                    color: ColorName.primaryColor,
                  );
                }
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      isReminderClicked = true;
                    });
                    context.read<EqubMemberBloc>().add(
                          SendReminder(
                            memberId: widget.equbMemberModel.id,
                          ),
                        );
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                    decoration: BoxDecoration(
                      color: ColorName.white,
                      border: Border.all(
                        color: ColorName.red,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextWidget(
                      text: "Remind",
                      fontSize: 13,
                      color: ColorName.red,
                    ),
                  ),
                );
              },
            ),
          BlocConsumer<EqubMemberBloc, EqubMemberState>(
            listener: (context, state) {
              if (state is SetMemberAsPaidSuccess && isReminderClicked) {
                setState(() {
                  isActive = true;
                  isReminderClicked = false;
                });
              } else if (state is SetMemberAsPaidFail && isReminderClicked) {
                showSnackbar(
                  context,
                  description: state.reason,
                );
                setState(() {
                  isReminderClicked = false;
                });
              }
            },
            builder: (context, state) {
              if (state is SetMemberAsPaidLoading && isReminderClicked) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 13),
                  child: LoadingWidget(
                    color: ColorName.green,
                    size: 20,
                  ),
                );
              }
              return Checkbox(
                value: isActive,
                checkColor: ColorName.green,
                fillColor: WidgetStateProperty.resolveWith<Color?>(
                    (Set<WidgetState> states) {
                  return ColorName.green.shade100;
                }),
                side: BorderSide.none,
                onChanged: (value) {
                  setState(() {
                    isReminderClicked = true;
                  });
                  context.read<EqubMemberBloc>().add(
                        SetMemberAsPaid(
                          cycleId: widget.cycleId,
                          memberId: widget.equbMemberModel.id,
                        ),
                      );
                },
              );
            },
          ),
          Checkbox(
            value: !isActive,
            checkColor: ColorName.red,
            fillColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              return ColorName.red.shade100;
            }),
            side: BorderSide.none,
            onChanged: (value) {
              setState(() {
                isActive = false;
              });
            },
          ),
        ],
      ),
    );
  }
}
