import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:transaction_mobile_app/data/models/invitee_model.dart';
import 'package:transaction_mobile_app/gen/assets.gen.dart';
import 'package:transaction_mobile_app/gen/colors.gen.dart';
import 'package:transaction_mobile_app/presentation/widgets/button_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/card_widget.dart';
import 'package:transaction_mobile_app/presentation/widgets/equb_member_tile.dart';
import 'package:transaction_mobile_app/presentation/widgets/text_widget.dart';

class WinScreen extends StatefulWidget {
  final String round;
  final EqubInviteeModel equbInviteeModel;
  const WinScreen(
      {super.key, required this.equbInviteeModel, required this.round});

  @override
  State<WinScreen> createState() => _WinScreenState();
}

class _WinScreenState extends State<WinScreen> {
  ConfettiController confettiController = ConfettiController();
  @override
  void initState() {
    confettiController.play();
    super.initState();
  }

  @override
  void dispose() {
    confettiController.stop();
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 100,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                Assets.images.reward.image(),
                const SizedBox(height: 15),
                TextWidget(
                  text: '${widget.round} Round Pick',
                  color: ColorName.yellow,
                  fontSize: 24,
                  weight: FontWeight.w700,
                ),
                const SizedBox(height: 15),
                TextWidget(
                  text:
                      "You've successfully selected your ${widget.round} round winner.",
                  textAlign: TextAlign.center,
                  fontSize: 14,
                ),
                const SizedBox(height: 30),
                CardWidget(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  width: 100.sw,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: '${widget.round} Round Pick',
                        fontSize: 14,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Divider(
                          height: 1,
                          color: Colors.grey[300],
                        ),
                      ),
                      EqubMemberTile(
                        equbInviteeModel: widget.equbInviteeModel,
                        trailingWidget:
                            SvgPicture.asset(Assets.images.svgs.checkmarkIcon),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            width: 100.sw,
            height: 100.sh,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: confettiController,
                shouldLoop: false,
                numberOfParticles: 6,
                emissionFrequency: 0.03,
                blastDirectionality: BlastDirectionality.explosive,
              ),
            ),
          ),
          Positioned(
            bottom: 5,
            left: 15,
            right: 15,
            child: ButtonWidget(
              onPressed: () {
                context.pop();
              },
              child: const TextWidget(
                text: 'Done',
                color: Colors.white,
                type: TextType.small,
              ),
            ),
          )
        ],
      ),
    );
  }
}
